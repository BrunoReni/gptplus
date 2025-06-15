#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMOVTOWMS.CH"

REGISTER EXTRACTOR HOS 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMovtoWMS
A tabela fato Devolução de Vendas apresenta informações relacionadas as 
devoluções das vendas, como valores e quantidades devolvidas e impostos.

@author  Helio Leal
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Class BIXMovtoWMS from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author Helio Leal  
@since   25/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXMovtoWMS
	_Super:New( FACT, "HOS", STR0001, "DCF", { DL } ) //"Movimentações WMS"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author Helio Leal  
@since   25/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXMovtoWMS
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HOS_EMPRES"	,	"C",	32,	 00, .T., "HJ4" ) //"Empresa"
	oModel:AddField( "HOS_ESTABL"	,	"C",	32,	 00, .T., "HKK" ) //"Estabelecimento"
	oModel:AddField( "HOS_DEPOSI"	,	"C",	32,	 00, .T., "HJD" ) //"Depósito"
	oModel:AddField( "HOS_ITEM"		,	"C",	32,	 00, .T., "HJ8" ) //"Item"
	oModel:AddField( "HOS_TIPMOV"	,	"C",	32,	 00, .T., "HK6" ) //"Tipo Movimento"
	oModel:AddField( "HOS_GRPEST"	,	"C",	32,	 00, .T., "HG3" ) //"Grupo de Estoque"	
	oModel:AddField( "HOS_DATA"		, 	"D",	08,	 00, .F., "HK2" ) //"Data Movimentação"
	
	oModel:AddField( "HOS_QTMOVI"	,	"N",	18,	 04 ) //Qtde Movimentação
	oModel:AddField( "HOS_QTPMOV"	,	"N",	18,	 04 ) //Tempo Movimentação
	oModel:AddField( "HOS_QTOCOR"	,	"N",	04,	 00 ) //Qtde Ocorrencias

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
@param oSeeker, objeto, Objeto para validação de integridade referencial.

@author  Helio Leal
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXMovtoWMS
	Local cFlow2 := ""
	Local cQuery := ""
	Local cChave := ""
	Local cTipMov := ""
	Local cGrupoItem := ""
	Local nTempoGas := 0
	Local nPos := 0
	Local nI := 0
	
	Private cFlow := ""
	Private aHOS  := {}

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato.
	//-------------------------------------------------------------------
	cFlow := ::Flow( cFrom, cTo )

	//-------------------------------------------------------------------
	// Itera por todos os registros do fluxo principal.
	// Será montado a estrutura dos dados antes da inclusão
	//-------------------------------------------------------------------
 	While ! ( cFlow )->( Eof() ) 
		
		// Tipo de Movimentação
		If (cFlow)->DCF_ORIGEM $ "SD1.SD2.DAS.SCM"
			cTipMov := "2" // Entrada
		ElseIf (cFlow)->DCF_ORIGEM $ "SC9.SD4.SCN.DBN"
			cTipMov := "3" // Saída
		ElseIf (cFlow)->DCF_ORIGEM $ "DCF.SD3"
			cTipMov := "4" // Movimentos Internos
		EndIf
		
		// Grupo do Item/Estoque
		cGrupoItem := Posicione("SB1",1,xFilial("SB1")+(cFlow)->DCF_CODPRO,"B1_GRUPO")
		
		// Deposito+Tipo Movimento+Grupo do Item+Item+Data Movimentação
		cChave := (cFlow)->DCF_LOCAL + cTipMov + cGrupoItem + (cFlow)->DCF_CODPRO + DToS( (cFlow)->DCF_DATA )
		
		// Caso a chave ja exista no array, apenas atualiza as quantidades, sem criar um novo registro
		nPos := aScan( aHOS, {|x| AllTrim( x[1]+x[2]+x[3]+x[4]+DToS(x[5]) ) == AllTrim(cChave) } )
		
		nI := 0
		If nPos == 0
			aAdd( aHOS, Array(12) )
			nI := Len(aHOS)
			
			aHOS[nI][1] := (cFlow)->DCF_LOCAL
			aHOS[nI][2] := cTipMov
			aHOS[nI][3] := cGrupoItem
			aHOS[nI][4] := (cFlow)->DCF_CODPRO
			aHOS[nI][5] := (cFlow)->DCF_DATA
			aHos[nI][6] := (cFlow)->DCF_DOCTO
			aHos[nI][7] := SerieNFID(cFlow, 2, "DCF_SERIE") 
			aHos[nI][8] := (cFlow)->DCF_CLIFOR
			aHos[nI][9] := (cFlow)->DCF_LOJA
			aHOS[nI][10] := 0
			aHOS[nI][11] := 0
			aHOS[nI][12] := 1
		EndIf
		
		cQuery := " SELECT SDB.DB_DATA, "
		cQuery += "        SDB.DB_HRINI, "
		cQuery += "        SDB.DB_DATAFIM, "
		cQuery += "        SDB.DB_HRFIM "
		cQuery += "   FROM " + RetSqlName("SDB")+" SDB "
		cQuery += "  WHERE SDB.DB_FILIAL = '" + xFilial("SDB") + "' "
		cQuery += "    AND SDB.D_E_L_E_T_ = '' "
		cQuery += "    AND SDB.DB_ESTORNO <> 'S' "
		cQuery += "    AND SDB.DB_ATUEST = 'N' "
		cQuery += "    AND SDB.DB_NUMSEQ = '"+AllTrim((cFlow)->DCF_NUMSEQ)+"' "
		
		cQuery := ChangeQuery( cQuery )
		cFlow2	:= GetNextAlias()
		DBUseArea( .T., "TOPCONN", TCGenQry( ,,cQuery ), cFlow2, .T., .F. )
		
		TcSetField( cFlow2, "DB_DATA", "D", 8, 0 )
		TcSetField( cFlow2, "DB_DATAFIM", "D", 8, 0 )
		
		// Cálculo do Tempo de Movimentação em horas
		nTempoGas := 0
		While !( cFlow2 )->( Eof() )
			nTempoGas += WMSCALTIME((cFlow2)->DB_DATA,;
										(cFlow2)->DB_HRINI,;
										(cFlow2)->DB_DATAFIM,;
										(cFlow2)->DB_HRFIM)
			(cFlow2)->( dbSkip() )
			
		EndDo
		
		( cFlow2 )->( DBCloseArea() )
		
		If nPos > nI
			nI := nPos
		EndIf
		
		// Qtde Movimentação
		aHOS[nI][10] += 1
		
		// Tempo Movimentação
		aHOS[nI][11] += nTempoGas
		
		// A cada novo documento adiciona uma ocorrencia
		// Documento+Serie+Cliente/Fornecedor+Loja
		If AllTrim( aHos[nI][6] + aHos[nI][7] + aHos[nI][8] + aHos[nI][9] ) != AllTrim( (cFlow)->DCF_DOCTO + SerieNFId( cFlow, 2, "DCF_SERIE") + (cFlow)->DCF_CLIFOR + (cFlow)->DCF_LOJA )
			// Quantidade de ocorrências
			aHOS[nI][12] += 1
		EndIf
		
		(cFlow)->( DBSkip() )
	EndDo

	For nI := 1 To Len( aHOS ) 
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//------------------------------------------------------------------- 
		oRecord:Init()

		//-------------------------------------------------------------------
		// Customização.
		//------------------------------------------------------------------- 
		oRecord:SetValue( "B2_LOCAL", aHOS[nI][1] )
		oRecord:SetValue( "BM_GRUPO", aHOS[nI][3] )	
		oRecord:SetValue( "B1_COD"	, aHOS[nI][4] )	

		//-------------------------------------------------------------------
		// Lookups.
		//-------------------------------------------------------------------
		oRecord:SetValue( "HOS_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) )
		oRecord:SetValue( "HOS_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
		oRecord:SetValue( "HOS_DEPOSI" 	, oSeeker:Seek( "HJD", { aHOS[nI][1] } ) )
		oRecord:SetValue( "HOS_ITEM" 	, oSeeker:Seek( "HJ8", { aHOS[nI][4] } ) )
		oRecord:SetValue( "HOS_GRPEST" 	, oSeeker:Seek( "HG3", { aHOS[nI][3]} ) )
		
		oRecord:SetValue( "HOS_TIPMOV"	, aHOS[nI][2] )
		oRecord:SetValue( "HOS_DATA" 	, aHOS[nI][5] )
		oRecord:SetValue( "HOS_QTMOVI"	, aHOS[nI][10] )
		oRecord:SetValue( "HOS_QTPMOV"	, aHOS[nI][11] )
		oRecord:SetValue( "HOS_QTOCOR"	, aHOS[nI][12] )
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de gravação. 
		//-------------------------------------------------------------------				
		oOutput:Send( oRecord ) 
	Next nI
	
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------
	oOutput:Release()
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
@return cRetAlias, Alias temporário. 

@author  Helio Leal
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXMovtoWMS
	Local cDML := ""

	cDML := " SELECT DCF.DCF_NUMSEQ, "
	cDML +=        " DCF.DCF_CODPRO, "
	cDML +=        " DCF.DCF_LOCAL, "
	cDML +=        " DCF.DCF_ORIGEM, "
	cDML +=        " DCF.DCF_DATA, "
	cDML +=        " DCF.DCF_DOCTO, "
	cDML +=        " DCF.DCF_SERIE, "
	cDML +=        " DCF.DCF_CLIFOR, "
	cDML +=        " DCF.DCF_LOJA, "
	cDML +=        " DCF.DCF_QUANT "
	cDML +=   " FROM " + RetSqlName("DCF") + " DCF "
	cDML +=  " WHERE DCF.D_E_L_E_T_ = '' "
	cDML +=    " AND DCF.DCF_FILIAL = '" + xFilial("DCF") + "' "
	cDML +=    " AND DCF.DCF_STSERV = '3' "
	cDML +=    " AND DCF.DCF_DATA BETWEEN '" + cFrom + "' AND '" + cTo + "' "
	cDML +=    " AND NOT EXISTS (SELECT 1 "
	If SuperGetMv("MV_WMSNEW",.F.,.F.)
		cDML +=  " FROM " + RetSqlName("D12") + " D12 "
		cDML += " WHERE D12.D_E_L_E_T_ = '' "
		cDML +=   " AND D12.D12_FILIAL = '" + xFilial("D12") + "' "
		cDML +=   " AND D12.D12_STATUS NOT IN ('1','A','M') "
		cDML +=   " AND D12.D12_IDDCF "
	Else
		cDML +=  " FROM " + RetSqlName("SDB") + " SDB "
		cDML += " WHERE SDB.D_E_L_E_T_ = '' "
		cDML +=   " AND SDB.DB_FILIAL = '" + xFilial("SDB") + "' "
		cDML +=   " AND SDB.DB_ATUEST = 'N' "
		cDML +=   " AND SDB.DB_ESTORNO <> 'S' "
		cDML +=   " AND SDB.DB_STATUS NOT IN ('1','A','M') "
		cDML +=   " AND SDB.DB_IDDCF "
	EndIf
	cDML += " IN (SELECT DCR.DCR_IDORI "
	cDML +=       " FROM " + RetSqlName("DCR") + " DCR "
	cDML +=      " WHERE DCR.D_E_L_E_T_ = '' "
	cDML +=        " AND DCR.DCR_FILIAL = '" + xFilial("DCR") + "' "
	cDML +=        " AND DCR.DCR_IDDCF = DCF.DCF_ID) ) "

	//-------------------------------------------------------------------
	// Transforma o DML em ANSI. 
	//-------------------------------------------------------------------  	
	cDML := ChangeQuery( cDML ) 

	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cDML), ::cFlow := GetNextAlias() , .T., .T.)

	//-------------------------------------------------------------------
	// Converte os campos do tipo data.
	//-------------------------------------------------------------------
	TcSetField( ::cFlow, "DCF_DATA", "D", 8, 0 )	
Return ::cFlow