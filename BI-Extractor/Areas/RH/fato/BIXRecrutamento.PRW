#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXRECRUTAMENTO.CH"

REGISTER EXTRACTOR HLG

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXRecrutamento
Apresenta informações das requisições de aumento de quadro como dos 
recrutamentos realizados e em andamento, em quantidades dos 
colaboradores e valores .

@author  BI TEAM
@since   31/08/2010
@param aParam, parâmetros necessário à execução deste extrator
	aParam[1] -> empresa a ser utilizada
	aParam[2] -> filial a ser utilizada
	aParam[3] -> Pesquisa De
	aParam[4] -> Pesquisa Ate
/*/
//-------------------------------------------------------------------
Class BIXRecrutamento from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
	Method Flow()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   28/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXRecrutamento
	_Super:New( FACT, "HLG", STR0001, "SRA", { RH } ) //"Recrutamento"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   28/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXRecrutamento
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLG_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLG_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLG_COLABR", "C", 32, 0, .T., "HJM" )
	oModel:AddField( "HLG_GRAINS", "C", 32, 0, .T., "HK9" )
	oModel:AddField( "HLG_NIVHIE", "C", 32, 0, .T., "HG5" )
	oModel:AddField( "HLG_SINDIC", "C", 32, 0, .T., "HJV" )
	oModel:AddField( "HLG_SECAO" , "C", 32, 0, .T., "HQ0" )
	oModel:AddField( "HLG_STAREQ", "C", 32, 0, .T., "HQE" )
	oModel:AddField( "HLG_TIPREQ", "C", 32, 0, .T., "HQD" )
	oModel:AddField( "HLG_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HLG_DATA"  , "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HLG_DTPREV", "D", 8, 0 )
	oModel:AddField( "HLG_DTABRQ", "D", 8, 0 )
	oModel:AddField( "HLG_NUMREQ", "C", 10, 0 )
	oModel:AddField( "HLG_QTDIAC", "N", 16, 4 )
	oModel:AddField( "HLG_VLSAL" , "N", 16, 2 )
	oModel:AddField( "HLG_QPOTDV", "N", 16, 4 )

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXRecrutamento
	Local aMoedas   := {}
	Local cMoeda    := "" 
	Local nInd      := 1 	
	Local cFlow		:= ""
	Local cStaReq	:= ""

	aMoedas := BIXGetMxF(::cEntity)

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo )

	While (cFlow)->(! EoF() )
		// Dimensão Status Requisição
		If (cFlow)->QS_NRVAGA > (cFlow)->QS_VAGAFEC
			cStaReq := "A"
		Else
			cStaReq := "F"
		EndIf
		
		For nInd := 1 To Len(aMoedas)
			cMoeda  := aMoedas[nInd][1]
			
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "RA_MAT" , (cFlow)->RA_MAT )
			oRecord:SetValue( "RCE_CODIGO" , (cFlow)->RA_SINDICA )
			oRecord:SetValue( "QB_DEPTO"   , (cFlow)->RA_DEPTO )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HLG_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HLG_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HLG_COLABR", oSeeker:Seek( "HJM", { (cFlow)->RA_MAT } ) ) 
			oRecord:SetValue( "HLG_GRAINS", oSeeker:Seek( "HK9", { (cFlow)->RA_GRINRAI } ) ) 
			oRecord:SetValue( "HLG_SINDIC", oSeeker:Seek( "HJV", { (cFlow)->RA_SINDICA } ) ) 
			oRecord:SetValue( "HLG_SECAO" , oSeeker:Seek( "HQ0", { (cFlow)->RA_DEPTO } ) ) 
			oRecord:SetValue( "HLG_STAREQ", oSeeker:Seek( "HQE", { cStaReq } ) )  
			oRecord:SetValue( "HLG_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
			oRecord:SetValue( "HLG_NIVHIE", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HLG_TIPREQ", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			
			//-------------------------------------------------------------------
			// Atributo.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HLG_NUMREQ", (cFlow)->QG_VAGA )                                                              // Numero de Requisição
			
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HLG_DATA", IIf(!Empty(StoD((cFlow)->RA_ADMISSA)), StoD((cFlow)->RA_ADMISSA), DATE_EMPTY) )	// Data de Admissão
			oRecord:SetValue( "HLG_DTABRQ", IIf(!Empty(StoD((cFlow)->QS_DTABERT)), StoD((cFlow)->QS_DTABERT), DATE_EMPTY) )	// Data de Abertura da Requisição
			oRecord:SetValue( "HLG_QTDIAC", BIXVldValor(oRecord:GetValue( "HLG_DTABRQ"), oRecord:GetValue( "HLG_DATA"), 3) )   	// Qtde de Dias para Contratação ???
			oRecord:SetValue( "HLG_VLSAL", BIXValue((cFlow)->RA_SALARIO, 1, cMoeda, oRecord:GetValue( "HLG_DATA" ) ) ) 	// Valor Salário
			oRecord:SetValue( "HLG_QPOTDV", 0 )             // Potencial Desenvolvimento
			oRecord:SetValue( "HLG_DTPREV", DATE_EMPTY )	// Data Prevista

			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nInd

		(cFlow)->( dbSkip() )

	EndDo
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()
Return NIL

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

@author  Marcia Junko
@since   28/05/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo ) Class BIXRecrutamento
	Local cQuery    := ""

	Local cBlqCV	:= SuperGetMv("MV_BLQCV",,"1") 

	cQuery := " SELECT SRA.RA_MAT, SRA.RA_GRINRAI, SRA.RA_SINDICA, SRA.RA_DEPTO, SRA.RA_ADMISSA, SRA.RA_SALARIO, SRA.R_E_C_N_O_ AS RECNO_, "
	cQuery += " SQG.QG_VAGA, SQS.QS_DTABERT, SQS.QS_NRVAGA, SQS.QS_VAGAFEC "
	cQuery += " FROM " + RetSqlName("SRA") + " SRA "
	cQuery += " INNER JOIN " + RetSqlName("SQG") + " SQG ON (SQG.QG_FILIAL = '" + xFilial("SQG") + "' AND "
	cQuery += "		SQG.QG_MAT = SRA.RA_MAT AND "
	cQuery += "		SQG.D_E_L_E_T_ = ' ') "
	cQuery += " INNER JOIN " + RetSqlName("SQS") + " SQS ON (SQS.QS_FILIAL = '" + xFilial("SQS") + "' AND "
	cQuery += "		SQS.QS_VAGA = SQG.QG_VAGA AND "
	cQuery += "		SQS.D_E_L_E_T_ = ' ') "
	cQuery += " WHERE SRA.RA_ADMISSA >= '" + cFrom + "' AND "
	cQuery += "		SRA.RA_ADMISSA <= '" + cTo + "' AND "
	cQuery += "		SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND "
	cQuery += "		SRA.D_E_L_E_T_ = ' ' AND "
	IF cBlqCV == "2" ///BLOQUEAR O CV POR NAO ACEITE DO TERMO DE CONSENTIMENTO
		cQuery += "		SQG.QG_ACEITE = '2' AND "
	ENDIF
	if SQG->(FieldPos("QG_ACTRSP")) > 0
		cQuery += "		SQG.QG_ACTRSP <> '1' AND "
	ENDIF
	cQuery += "		SQG.QG_SITUAC = '002' "

	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cQuery := ChangeQuery(cQuery)

	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária. 
	//-------------------------------------------------------------------  	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), ::cFlow := GetNextAlias(), .T., .F.)
Return ::cFlow
