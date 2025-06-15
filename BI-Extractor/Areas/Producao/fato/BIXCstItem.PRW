#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCSTITEM.CH"

REGISTER EXTRACTOR HKV

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCstItem
Classe do extrator para a tabela fato Custo por Item do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   23/09/2010
@param aParam, parâmetros necessário à execução deste extrator
	aParam[1] -> empresa a ser utilizada
	aParam[2] -> filial a ser utilizada
	aParam[3] -> Pesquisa De
	aParam[4] -> Pesquisa Ate
/*/
//-------------------------------------------------------------------
Class BIXCstItem from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   26/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXCstItem
	_Super:New( FACT, "HKV", STR0001, "SB1", { PRODUCAO } ) //"Custo por Item"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   26/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXCstItem
	Local oModel := BIXModel():Build( Self )

	//-------------------------------------------------------------------
	// Converte o período de extração informado para o primeio até o 
	// último dia do mês atual
	//-------------------------------------------------------------------	
	oModel:SetPeriod ( PERIOD_MONTH_CURRENT )
	
	oModel:AddField( "HKV_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HKV_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HKV_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HKV_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HKV_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HKV_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HKV_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HKV_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HKV_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HKV_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HKV_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HKV_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HKV_DATA"  , "D", 8 , 0 )
	oModel:AddField( "HKV_DTEXTR", "D", 8 , 0 )
	oModel:AddField( "HKV_CNCUST", "N", 4 , 0 )
	oModel:AddField( "HKV_VCSREA", "N", 16, 2 )
	oModel:AddField( "HKV_VCSRMT", "N", 16, 4 )
	oModel:AddField( "HKV_VCSRMO", "N", 16, 2 )
	oModel:AddField( "HKV_VCSRGF", "N", 16, 2 )

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
@since   26/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXCstItem
	Local prevAlias := GetArea()
	Local aMoedas	:= {}
	Local cMoeda	:= ""	
	Local cTIPITM	:= ""
	Local nMoeda	:= 1	
	Local lCatego 	:= .F.
	Local dLastDate	:= NIL
	
	aMoedas	:= BIXGetMxF(::cEntity)

	DbSelectArea("ACV")
	ACV->( dbSetOrder(5) ) // Filial + ACV_CODPRO + ACV_CATEGO

	DbSelectArea("SG1")
	SG1->( dbSetOrder(1) ) // Filial + G1_COD + G1_COMP + G1_TRT

	DbSelectArea("SB1")	
	SB1->( dbSetOrder(1) ) // Filial + B1_COD

	SB1->( dbSeek(xFilial("SB1")) )
	While SB1->( !Eof() ) .And. SB1->B1_FILIAL == xFilial("SB1")
		lCatego		:= .F.
		cTIPITM 	:= ""
		dLastDate 	:= LastDay( date() )
		
		// Considera apenas produtos que não são Mão de Obra	
		If IsProdMod(SB1->B1_COD)
			SB1->( dbSkip() )
			Loop
		EndIf
	
		If ACV->( MSSeek( xFilial("ACV") + SB1->B1_COD ) )  		
			lCatego	:= .T.
		EndIf

		If SG1->( MsSeek( xFilial("SG1") + SB1->B1_COD) )
			If SB1->B1_TIPO == "MP"
				cTIPITM := "3" // Matéria Prima
			Else
				cTIPITM := "2" // Fabricado
			EndIf
		Else
			cTIPITM := "1" // Comprado
		EndIf
		
		For nMoeda := 1 To Len(aMoedas)
			cMoeda := aMoedas[nMoeda][1]
	
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "B1_COD"	, SB1->B1_COD )
			oRecord:SetValue( "BM_GRUPO"	, SB1->B1_GRUPO )
			oRecord:SetValue( "AH_UNIMED"	, SB1->B1_UM )
			oRecord:SetValue( "ACU_COD"		, ACV->ACV_CATEGO )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HKV_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HKV_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HKV_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HKV_ITEM"  , oSeeker:Seek( "HJ8", { SB1->B1_COD } ) ) 
			oRecord:SetValue( "HKV_FAMMAT", oSeeker:Seek( "HG2", { SB1->B1_TIPO } ) ) 
			oRecord:SetValue( "HKV_GRPEST", oSeeker:Seek( "HG3", { SB1->B1_GRUPO } ) ) 
			oRecord:SetValue( "HKV_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nMoeda][2] } ) ) 
			oRecord:SetValue( "HKV_TIPITM", oSeeker:Seek( "HGC", { cTipITM } ) ) 
			oRecord:SetValue( "HKV_UNITEM", oSeeker:Seek( "HHW", { SB1->B1_UM } ) ) 
			
			If lCatego
				oRecord:SetValue( "HKV_FAMCOM", oSeeker:Seek( "HG1", { ACV->ACV_CATEGO } ) )
			Else
				oRecord:SetValue( "HKV_FAMCOM", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			EndIf

			oRecord:SetValue( "HKV_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKV_LINHAP", oSeeker:oKey:GetKey( { UNDEFINED } ) )

			//-------------------------------------------------------------------
			// Atributos.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKV_DATA", dLastDate )	// Dimensão Periodo (Data do Custo do Item (Mensal))
			oRecord:SetValue( "HKV_DTEXTR"	, dLastDate  ) 

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKV_VCSREA", Round( RetCostStd(2, 1, SB1->B1_COD, dLastDate,  , cMoeda ), 2) )  // Custo Real
			oRecord:SetValue( "HKV_VCSRMT", Round( RetCostStd(2, 2, SB1->B1_COD, dLastDate,  , cMoeda ), 2) )	// Custo Real de Material
			oRecord:SetValue( "HKV_VCSRMO", Round( RetCostStd(2, 3, SB1->B1_COD, dLastDate, 1, cMoeda ), 2) )	// Custo Real de Mão de Obra (1 - Com roteiro de operação)
			oRecord:SetValue( "HKV_VCSRGF", 0 )  // Custo Real de GGF
			oRecord:SetValue( "HKV_CNCUST", 0 )  // Dimensão Cenário de Custo 
			
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nMoeda		
		
		SB1->( dbSkip() )        
		
	EndDo
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
	
	RestArea(prevAlias)
Return NIL
