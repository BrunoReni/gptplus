#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXANLSCUSTOCC.CH"

REGISTER EXTRACTOR HLS

#DEFINE COSTCENTER 1
#DEFINE COST       2
#DEFINE QUANTITY   3
#DEFINE REALIZED	4	
#DEFINE PRODUCED	5
#DEFINE MOEDA		6
#DEFINE PERIOD		7

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAnlsCustoCC
As informa��es do fluxo principal s�o  filtradas utilizando a compara��o 
de menor ou igual entre a data da digita��o do item e a data final do per�odo 
informado. As medidas s�o acumuladas para os centros de custo.
	
@author  BI TEAM
@since   23/09/2010
/*/
//-------------------------------------------------------------------
class BIXAnlsCustoCC from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
endClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Marcia Junko
@since   25/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXAnlsCustoCC
	Local cMapHLS	:= ""
	
	// Tratamento diferenciado para fatos com mais de uma tabela no fluxo (SD1, SD2 e SD3)
	If !Empty(xFilial("SD1"))
		cMapHLS := "SD1"
	ElseIf !Empty(xFilial("SD2"))
		cMapHLS := "SD2" 
	ElseIf !Empty(xFilial("SD3"))
		cMapHLS := "SD3" 
	Else
		cMapHLS := "SD1" 
	EndIf

	_Super:New( FACT, "HLS", STR0001, cMapHLS, { PRODUCAO } ) //"Analise de Custo por Centro de Custo"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   25/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXAnlsCustoCC 
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLS_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLS_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLS_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HLS_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HLS_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HLS_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HLS_DATA"  , "D", 8, 0 )
	oModel:AddField( "HLS_VCUSTO", "N", 16, 4 )
	oModel:AddField( "HLS_VCSPRV", "N", 16, 2 )
	oModel:AddField( "HLS_VCSTOT", "N", 16, 2 )
	oModel:AddField( "HLS_VCSPAD", "N", 16, 2 )
	oModel:AddField( "HLS_QHRPRO", "N", 16, 4 )
	oModel:AddField( "HLS_QHRDSP", "N", 16, 4 )
	oModel:AddField( "HLS_QHRPAD", "N", 16, 4 )
	oModel:AddField( "HLS_QHRREP", "N", 16, 4 )

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

@author  Marcia Junko
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXAnlsCustoCC
	Local aMoeda		:= {}
	Local aInterval	:= {} 	
	Local aCostCenter	:= {}
	Local nInterval	:= 0
	Local nMoeda     	:= 0
	Local nCostCenter	:= 0
	Local nQuantity	:= 0
	Local nCost 		:= 0
	Local nRealized	:= 0
	Local nProduced	:= 0
	Local cMoeda     	:= ""
	Local cCC 			:= ""

   	Private cRetAlias	:= ""

	aMoeda 	:= BIXGetMxF( ::cEntity )
	aInterval	:= BIXInterval( cFrom, cTo, .T. ) 	

	For nInterval := 1 To Len( aInterval ) 	
		aCostCenter	:= {}

		//-------------------------------------------------------------------
		// Cria a �rea de trabalho tempor�ria. 
		//------------------------------------------------------------------- 	  	  	 
		cRetAlias := ::Flow( aInterval[nInterval][1], aInterval[nInterval][2] ) 
	
		//-------------------------------------------------------------------
		// Itera por todos os registros do fluxo principal. 
		//-------------------------------------------------------------------   	
	 	While ! (cRetAlias)->( Eof() ) 
	 		For nMoeda := 1 To Len( aMoeda ) 
	 			cMoeda 	:= aMoeda[nMoeda][2]
				cCC 		:= (cRetAlias)->CC
				nQuantity	:= (cRetAlias)->QUANT
				nCost 		:= &( "(cRetAlias)->CUSTO" + aMoeda[nMoeda][1] )
				nRealized	:= 0
				nProduced	:= 0				

				//-------------------------------------------------------------------
				// Normaliza o tamanho do centro de custo. 
				//------------------------------------------------------------------- 				
				cCC := Padr( cCC, 32 )
				
				//-------------------------------------------------------------------
				// Tratamento para campos num�ricos n�o receberem valor Null.				
				//-------------------------------------------------------------------
				nCost := iif(nCost == Nil, 0, nCost)
				nQuantity := iif(nQuantity == Nil, 0, nQuantity)
	
	  			If ( (cRetAlias)->TABELA == "SD3" )
	  				//-------------------------------------------------------------------
					// Para o preenchimento dos indicadores Qtde Horas Produzidas e Qtde Horas 
					// Reportadas � necess�rio verificar se o lan�amento de movimenta��o interna n�o 
					// foi estornado (D3_ESTORNO <> S), se � um movimento de requisi��o (D3_CF = RE)
					// e se trata-se de uma movimenta��o de  m�o de obra (IsProdMod(D3_COD).
					//-------------------------------------------------------------------
					If ( IsProdMod( (cRetAlias)->COD ) .And. ! (cRetAlias)->ESTORNO == "S" .And. (cRetAlias)->CF == "RE" )
						//-------------------------------------------------------------------
						// O fluxo de dados referente � tabela SD3 sofre altera��o em suas informa��es 
						// quando o item de produto � do tipo m�o de obra (IsProdMod). Esta altera��o 
						// refere-se ao c�digo do centro de custo que ser� utilizado como agrupador dos 
						// valores. Quando trata-se de um movimento interno de produto m�o de obra o 
						// centro de custo considerado � o centro de custo referente a m�o de obra (B1_CCCUSTO ou Substr(D3_COD)) 
						// e n�o mais o centro de custo da movimenta��o (D3_CC).					
						//-------------------------------------------------------------------
						If ( Substr( (cRetAlias)->COD , 1, 3 ) == "MOD" )
							cCC := Padr( Substr( (cRetAlias)->COD, 4 ), 32 )
						Else
							cCC := Padr( Posicione( "SB1", 1, xFilial("SB1") + (cRetAlias)->COD, "B1_CCCUSTO" ), 32 )
						Endif

						nRealized 	:= (cRetAlias)->QUANT     
						nProduced	:= If ( Empty( (cRetAlias)->OP ), 0, (cRetAlias)->QUANT )
					EndIf 

					//-------------------------------------------------------------------
					// Acumula os indicadores por centro de custo. 
					//------------------------------------------------------------------- 
					nCostCenter := aScan( aCostCenter, {|x| x[COSTCENTER] == cCC .And. x[MOEDA] == cMoeda } )			
					
					
					
		  			If ( nCostCenter == 0 )
		  				aAdd( aCostCenter, { cCC, nCost, nQuantity,  nRealized, nProduced, cMoeda, aInterval[nInterval][2] } )
		  			Else
		  			 	aCostCenter[nCostCenter][COST] 	+= nCost
		  				aCostCenter[nCostCenter][QUANTITY] += nQuantity  	
		  				aCostCenter[nCostCenter][REALIZED] += nRealized 
		  				aCostCenter[nCostCenter][PRODUCED] += nProduced 
		  			EndIf	
				Else	
					aAdd( aCostCenter, { cCC, nCost, nQuantity,  nRealized, nProduced, cMoeda, aInterval[nInterval][2] } )	
				EndIf
			Next nMoeda
			
	 		(cRetAlias)->( DBSkip() ) 
	 	EndDo 
	
		//-------------------------------------------------------------------
		// Grava os valores acumulados. 
		//-------------------------------------------------------------------  
	 	For nCostCenter := 1 To Len( aCostCenter ) 
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customiza��o.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "CTT_CUSTO"		, aCostCenter[nCostCenter][1] )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HLS_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HLS_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HLS_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 
			oRecord:SetValue( "HLS_CCUSTO", oSeeker:Seek( "HJ5", { aCostCenter[nCostCenter][1] } ) ) 
			oRecord:SetValue( "HLS_MOEDA" , oSeeker:Seek( "HJ6", { aCostCenter[nCostCenter][MOEDA] } ) ) 
			oRecord:SetValue( "HLS_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
	 		
			//-------------------------------------------------------------------
			// Atributos.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HLS_DATA", SToD( aCostCenter[nCostCenter][PERIOD] ) )

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HLS_VCUSTO", Round( ( aCostCenter[nCostCenter][COST] / aCostCenter[nCostCenter][QUANTITY] ), 2) ) // Grava o Vl Custo M�dio.  
			oRecord:SetValue( "HLS_VCSTOT", Round( aCostCenter[nCostCenter][COST], 2) ) // Grava o Vl Custo Total.                 
			oRecord:SetValue( "HLS_QHRREP", aCostCenter[nCostCenter][REALIZED] ) // Grava a Qtds Horas Reportadas. 
			oRecord:SetValue( "HLS_QHRPRO", aCostCenter[nCostCenter][PRODUCED] ) // Grava a Qtde Horas Produzidas. 
			oRecord:SetValue( "HLS_VCSPRV", 0 ) // Grava o Vl Custo Previsto. 
			oRecord:SetValue( "HLS_VCSPAD", 0 ) // Grava o Vl Custo Padr�o. 
			oRecord:SetValue( "HLS_QHRDSP", 0 ) // Grava a Qtde Horas Disponiveis. 
			oRecord:SetValue( "HLS_QHRPAD", 0 ) // Grava a Qtde Horas Padr�o. 

			//-------------------------------------------------------------------
			// Envia o registro para o pool de grava��o. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nCostCenter
		
		//-------------------------------------------------------------------
		// Fecha a �rea de trabalho tempor�ria. 
		//-------------------------------------------------------------------  		  
	 	(cRetAlias)->( DBCloseArea() ) 
	Next nInterval

	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
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

@author  Marcia Junko
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXAnlsCustoCC
	Local cFlow 	:= ""  

	cFlow += " SELECT" 
	cFlow += " 	CC," 
	cFlow += " 	SUM( QUANT  ) QUANT," 
	cFlow += " 	SUM( CUSTO1 ) CUSTO1,"
	cFlow += " 	SUM( CUSTO2 ) CUSTO2,"
	cFlow += " 	SUM( CUSTO3 ) CUSTO3,"
	cFlow += " 	SUM( CUSTO4 ) CUSTO4,"
	cFlow += " 	SUM( CUSTO5 ) CUSTO5,"
	cFlow += " 	' '  COD,"
	cFlow += " 	' '  ESTORNO,"
	cFlow += " 	' '  CF,"
	cFlow += " 	' '  OP,"	
	cFlow += " 	' '  TABELA"	
	cFlow += " FROM " 
	cFlow += " ( " 
	cFlow += " 	SELECT" 
	cFlow += " 		SD1.D1_CC 		CC," 
	cFlow += " 		SD1.D1_QUANT 	QUANT," 
	cFlow += " 		SD1.D1_CUSTO	CUSTO1,"
	cFlow += " 		SD1.D1_CUSTO2	CUSTO2,"
	cFlow += " 		SD1.D1_CUSTO3	CUSTO3,"
	cFlow += " 		SD1.D1_CUSTO4	CUSTO4,"
	cFlow += " 		SD1.D1_CUSTO5	CUSTO5,"
	cFlow += " 		' '				COD,"
	cFlow += " 		' '				ESTORNO,"
	cFlow += " 		' '				CF,"
	cFlow += " 		' '				OP,"	
	cFlow += " 		' '				TABELA"	
	cFlow += " 	FROM " + RetSQLName("SD1") + " SD1" 	
	cFlow += " 	WHERE "  
	cFlow += "			SD1.D1_FILIAL = '" + xFilial("SD1") + "'"
	cFlow += "			AND"                 
	cFlow += "			SD1.D1_DTDIGIT BETWEEN '" + cFrom + "' AND '" + cTo + "'" 
	cFlow += "			AND" 
	cFlow += "			SD1.D_E_L_E_T_ = ' '"   
	
	cFlow += " 	UNION "
	
	cFlow += " 	SELECT" 
	cFlow += " 		SD2.D2_CCUSTO CC," 
	cFlow += " 		SD2.D2_QUANT	QUANT," 
	cFlow += " 		SD2.D2_CUSTO1	CUSTO1,"
	cFlow += " 		SD2.D2_CUSTO2	CUSTO2,"
	cFlow += " 		SD2.D2_CUSTO3	CUSTO3,"
	cFlow += " 		SD2.D2_CUSTO4	CUSTO4,"
	cFlow += " 		SD2.D2_CUSTO5	CUSTO5,"
	cFlow += " 		' '				COD,"
	cFlow += " 		' '				ESTORNO,"
	cFlow += " 		' '				CF,"
	cFlow += " 		' '				OP,"	
	cFlow += " 		' '				TABELA"	
	cFlow += " 	FROM " + RetSQLName("SD2") + " SD2" 	
	cFlow += " 	WHERE "  
	cFlow += "			SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
	cFlow += "			AND"                 
	cFlow += "			SD2.D2_EMISSAO BETWEEN '" + cFrom + "' AND '" + cTo + "'" 
	cFlow += "			AND" 
	cFlow += "			SD2.D_E_L_E_T_ = ' '" 
	cFlow += " ) X"
	cFlow += " GROUP BY X.CC"
		
	cFlow += " UNION "	
	
	cFlow += " SELECT" 
	cFlow += " 	SD3.D3_CC 				CC," 
	cFlow += " 	SUM( SD3.D3_QUANT  )	QUANT," 
	cFlow += " 	SUM( SD3.D3_CUSTO1 )	CUSTO1,"
	cFlow += " 	SUM( SD3.D3_CUSTO2 )	CUSTO2,"
	cFlow += " 	SUM( SD3.D3_CUSTO3 )	CUSTO3,"
	cFlow += " 	SUM( SD3.D3_CUSTO4 )	CUSTO4,"
	cFlow += " 	SUM( SD3.D3_CUSTO5 )	CUSTO5,"
	cFlow += " 	SD3.D3_COD			COD," 
	cFlow += " 	SD3.D3_ESTORNO 	ESTORNO," 
	cFlow += " 	SD3.D3_CF		 	CF," 
	cFlow += " 	SD3.D3_OP		 	OP,	" 
	cFlow += " 	'SD3'				TABELA"	
	cFlow += " FROM " + RetSQLName("SD3") + " SD3" 	
	cFlow += " WHERE "  
	cFlow += "		SD3.D3_FILIAL = '" + xFilial("SD3") + "'"
	cFlow += "		AND"                 
	cFlow += "		SD3.D3_EMISSAO BETWEEN '" + cFrom + "' AND '" + cTo + "'" 
	cFlow += "		AND" 
	cFlow += "		SD3.D_E_L_E_T_ = ' '"  
	cFlow += " GROUP BY SD3.D3_CC, SD3.D3_COD, SD3.D3_ESTORNO, SD3.D3_CF, SD3.D3_OP"
	
	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cFlow := ChangeQuery( cFlow )  

	//-------------------------------------------------------------------
	// Abre a �rea de trabalho tempor�ria. cFlow
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,cFlow ), ::cFlow := GetNextAlias(), .T., .F. )  
Return ::cFlow