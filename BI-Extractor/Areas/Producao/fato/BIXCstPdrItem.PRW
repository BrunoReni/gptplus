#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCSTPDRITEM.CH"

REGISTER EXTRACTOR HKU

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCstPdrItem
Classe do extrator para a tabela fato Custo Padrão por Item do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   23/09/2010
/*/
//-------------------------------------------------------------------
Class BIXCstPdrItem from BIXEntity
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
Method New() Class BIXCstPdrItem
	_Super:New( FACT, "HKU", STR0001, "SB1", { PRODUCAO } ) //"Custo Padrão por Item"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   26/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXCstPdrItem
	Local oModel := BIXModel():Build( Self )

	//-------------------------------------------------------------------
	// Converte o período de extração informado para o primeio até o 
	// último dia do mês anterior
	//---------------------------------------
	oModel:SetPeriod ( PERIOD_MONTH_CURRENT )
	
	oModel:AddField( "HKU_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HKU_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HKU_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HKU_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HKU_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HKU_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HKU_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HKU_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HKU_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HKU_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HKU_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HKU_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HKU_DATA"  , "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HKU_DTEXTR", "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HKU_CNCUST", "N", 4, 0 )
	oModel:AddField( "HKU_VCSPDR", "N", 16, 2 )
	oModel:AddField( "HKU_VCSPDM", "N", 16, 2 )
	oModel:AddField( "HKU_VCSPMO", "N", 16, 2 )
	oModel:AddField( "HKU_VCSPGF", "N", 16, 2 )

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXCstPdrItem
	Local aMoedas  	:= {}
	Local cMoeda   	:= ""
	Local nMoeda	:= 1	
	Local lCatego 	:= .F.
	Local cTipITM	:= ""

	aMoedas  := BIXGetMxF(::cEntity)
	
	DbSelectArea("ACV")
	ACV->( dbSetOrder(5) ) // Filial + ACV_CODPRO + ACV_CATEGO

	DbSelectArea("SG1")
	SG1->( dbSetOrder(1) ) // Filial + G1_COD + G1_COMP + G1_TRT

	DbSelectArea("SB1")	
	SB1->( dbSetOrder(1) ) // Filial + B1_COD
   
	SB1->( dbSeek(xFilial("SB1")) ) 
	While SB1->(! Eof() ) .And. SB1->B1_FILIAL == xFilial("SB1")
		lCatego := .F.
		cTipITM	:= ""
	
		If ACV->( MSSeek( xFilial("ACV") + SB1->B1_COD ) )
			lCatego := .T.
		EndIf

		If SG1->( MsSeek( xFilial("SG1") + SB1->B1_COD) )
			If SB1->B1_TIPO == "MP" // Matéria Prima
				cTipITM := "3"
			Else
				cTipITM := "2" // Fabricado
			EndIf
		Else
			cTipITM := "1" // Comprado
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
			oRecord:SetValue( "B1_COD"		, SB1->B1_COD )
			oRecord:SetValue( "ACU_COD"		, ACV->ACV_CATEGO )
			oRecord:SetValue( "BM_GRUPO"	, SB1->B1_GRUPO )			
			oRecord:SetValue( "AH_UNIMED"	, SB1->B1_UM )
		
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HKU_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HKU_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HKU_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HKU_ITEM"  , oSeeker:Seek( "HJ8", { SB1->B1_COD  } ) ) 
			oRecord:SetValue( "HKU_FAMMAT", oSeeker:Seek( "HG2", { SB1->B1_TIPO } ) ) 
			oRecord:SetValue( "HKU_FAMCOM", oSeeker:Seek( "HG1", { ACV->ACV_CATEGO } ) ) 
			oRecord:SetValue( "HKU_GRPEST", oSeeker:Seek( "HG3", { SB1->B1_GRUPO } ) ) 
			oRecord:SetValue( "HKU_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nMoeda][2] } ) ) 
			oRecord:SetValue( "HKU_TIPITM", oSeeker:Seek( "HGC", { cTipITM } ) ) 
			oRecord:SetValue( "HKU_UNITEM", oSeeker:Seek( "HHW", { SB1->B1_UM } ) )
			oRecord:SetValue( "HKU_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HKU_LINHAP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			
			//-------------------------------------------------------------------
			// Atributos.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKU_DATA", LastDay( Date() ) ) // Dimensão Periodo (Data do Custo do Item)
			oRecord:SetValue( "HKU_DTEXTR", LastDay(date())  )	

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HKU_VCSPDR", Round( RetCostStd(1, 1, SB1->B1_COD, LastDay( Date() ),  , cMoeda), 2) ) // Custo Padrão
			oRecord:SetValue( "HKU_VCSPDM", Round( RetCostStd(1, 2, SB1->B1_COD, LastDay( Date() ),  , cMoeda), 2) ) // Custo Padrão de Material
			oRecord:SetValue( "HKU_VCSPMO", Round( RetCostStd(1, 3, SB1->B1_COD, LastDay( Date() ), 1, cMoeda), 2) ) // Custo Padrão de Mão de Obra (1 - Com roteiro de operação)
			oRecord:SetValue( "HKU_VCSPGF", 0 )       // Custo Padrão de GGF   
			oRecord:SetValue( "HKU_CNCUST", 0 )       // Dimensão Cenário de Custo

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
Return NIL
