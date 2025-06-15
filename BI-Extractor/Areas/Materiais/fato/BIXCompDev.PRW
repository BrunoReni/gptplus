#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCOMPDEV.CH"

REGISTER EXTRACTOR HKL

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCompDev
Classe do extrator da fato Devolução de Compras do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   31/08/2010
/*/
//-------------------------------------------------------------------
Class BIXCompDev from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   23/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXCompDev
	_Super:New( FACT, "HKL", STR0001, "SD2", { MATERIAIS } ) // "Devolução de Compras" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   23/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXCompDev
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HKL_FORNEC"	, "C", 	32, 0, .T., "HKJ" )			
	oModel:AddField( "HKL_EMPRES"	, "C", 	32, 0, .T., "HJ4" )
	oModel:AddField( "HKL_ESTABL"	, "C", 	32, 0, .T., "HKK" )
	oModel:AddField( "HKL_TRANSP"	, "C", 	32, 0, .T., "HJ2" )
	oModel:AddField( "HKL_FAMMAT"	, "C", 	32, 0, .T., "HG2" )
	oModel:AddField( "HKL_FAMCOM"	, "C", 	32, 0, .T., "HG1" )	
	oModel:AddField( "HKL_GRPEST"	, "C", 	32, 0, .T., "HG3" ) 
	oModel:AddField( "HKL_ITEM"		, "C", 	32, 0, .T., "HJ8" )
	oModel:AddField( "HKL_CMPRDR"	, "C", 	32, 0, .T., "HJZ" )
	oModel:AddField( "HKL_CONDPG"	, "C", 	32, 0, .T., "HJA" )	
	oModel:AddField( "HKL_REGIAO"	, "C", 	32, 0, .T., "HJB" )
	oModel:AddField( "HKL_MOEDA"	, "C", 	32, 0, .T., "HJ6" )
	oModel:AddField( "HKL_CCUSTO"	, "C", 	32, 0, .T., "HJ5" )
	oModel:AddField( "HKL_UNDNEG"	, "C", 	32, 0, .T., "HJ1" )
	oModel:AddField( "HKL_CFOP"		, "C", 	32, 0, .T., "HG0" )
	oModel:AddField( "HKL_NATOPR"	, "C", 	32, 0, .T., "HJ9" )
	oModel:AddField( "HKL_PLCCST"	, "C", 	32, 0, .T., "HKF" )
	oModel:AddField( "HKL_SITCMP"	, "C", 	32, 0, .T., "HQG" )
	oModel:AddField( "HKL_NATCMP"	, "C", 	32, 0, .T., "HQH" )
	oModel:AddField( "HKL_GRPFOR"	, "C", 	32, 0, .T., "HGE" )
	oModel:AddField( "HKL_REFER"	, "C", 	32, 0, .T., "HJH" )
	oModel:AddField( "HKL_UNITEM"	, "C",  32, 0, .T., "HHW" ) 
	oModel:AddField( "HKL_DATA"		, "D", 	8, 0 )		
	oModel:AddField( "HKL_ORDEM"	, "C", 	10, 0 )		
	oModel:AddField( "HKL_PEDIDO"	, "C", 	10, 0 )		
	oModel:AddField( "HKL_SERNF"	, "C", 	8, 0 )		
	oModel:AddField( "HKL_NUMNF"	, "C", 	35, 0 )		
	oModel:AddField( "HKL_EMERG"	, "C", 	1, 0 )		
	oModel:AddField( "HKL_SEQCIA"	, "C", 	10, 0 )		
	oModel:AddField( "HKL_REMITO"	, "C", 	13, 0 )	
	oModel:AddField( "HKL_SERREM"	, "C", 	3, 0 )	
	oModel:AddField( "HKL_ITEREM"	, "C", 	4, 0 )	
	oModel:AddField( "HKL_NUMPRG"	, "N", 	4, 0 )		
	oModel:AddField( "HKL_QDEVOL"	, "N", 	16,	4 )
	oModel:AddField( "HKL_QDVFMT"	, "N", 	16,	4 )
	oModel:AddField( "HKL_VDEVOL"	, "N", 	16,	2 )
	oModel:AddField( "HKL_QORDDV"	, "N", 	16,	4 )

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
@since   23/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXCompDev
	Local oRegion	:= NIL
	Local aMoedas	:= {}
	Local cMoeda	:= ""
	Local nInd      := 1
	Local nMoedaAux := 1
	Local lValid    := .F.
	Local nTxMoeda 	:= 0
	Local lTxMoeda 	:= .F.

	aMoedas := BIXGetMxF( ::cEntity )
	lTxMoeda := LoadTxMoeda() //Define a utilização da taxa negociada na conversão de moeda.
	oRegion	:= BIXRegiao():New()
	
	DbSelectArea("SD2") // Itens de Venda da NF
	SD2->( dbSetOrder(5) ) // D2_FILIAL + DTOS(D2_EMISSAO) + D2_NUMSEQ

	DbSelectArea("ACV")
	ACV->( dbSetOrder(5) )

	DbSelectArea("SA2") // Fornecedor
	SA2->( dbSetOrder(1) )

	DbSelectArea("SF1") // Cabecalho das NF de Entrada
	SF1->( dbSetOrder(1) )

	DbSelectArea("SF2") // Cabecalho das NF de Saída
	SF2->( dbSetOrder(2) )

	DbSelectArea("SD1") // Itens das NF de Entrada
	SD1->( dbSetOrder(2) )

	DbSelectArea("SB1") // Produto (Item)
	SB1->( dbSetOrder(1) ) // B1_FILIAL+B1_COD

	DbSelectArea("SC7")
	SC7->( dbSetOrder(1) ) // C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN

	DbSelectArea("SC1")
	SC1->( dbSetOrder(1) ) // C1_FILIAL+C1_NUM+C1_ITEM

	SD2->( dbSeek( xFilial("SD2") + cFrom, .T.) )

	While SD2->(! EoF() ) .And.	SD2->D2_FILIAL == xFilial("SD2") .And.	SD2->D2_EMISSAO <= StoD(cTo)
		If !(SD2->D2_ORIGLAN == 'LF') .And. SD2->D2_TIPO == 'D'
			lValid := .F.                          
			nTxMoeda := 0
			nMoedaAux := 1
			oRegion	:= BIXRegiao():New()
			
			If SD1->( dbSeek( xFilial("SD1") + SD2->D2_COD + SD2->D2_NFORI + SD2->D2_SERIORI + SD2->D2_CLIENTE + SD2->D2_LOJA  ) )
				lValid := .T.
			EndIf

			SA2->( dbSeek( xFilial("SA2") + SD2->D2_CLIENTE + SD2->D2_LOJA ))
			ACV->( dbSeek( xFilial("ACV") + SD2->D2_COD ) )
			SF1->( dbSeek( xFilial("SF1") + SD2->D2_NFORI + SD2->D2_SERIORI + SD2->D2_CLIENTE + SD2->D2_LOJA ) )
			SB1->( dbSeek( xFilial("SB1") + SD2->D2_COD ) )

			If SF2->( dbSeek( xFilial("SF2") + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_DOC + SD2->D2_SERIE ) ) .And. SF2->F2_MOEDA > 0
				nMoedaAux := SF2->F2_MOEDA
				
				//-------------------------------------------------------------------
				// No Mercado internacional, as tabelas SC5, SC7, SF1, SF2, SE1, 
				// SE5 e SE2 utilizam o campo ??_TXMOEDA (TAXA NEGOCIADA) que define
				// a taxa usada para a operação, caso seja ZERO deve ser considerada 
				// a cotação da moeda para o dia.
				//-------------------------------------------------------------------					
				If cPaisLoc != "BRA" .Or. lTxMoeda
					nTxMoeda := SF2->F2_TXMOEDA
				Endif				
			EndIf

			For nInd := 1 To Len(aMoedas)
				cMoeda := aMoedas[nInd][1]

				//-------------------------------------------------------------------
				// Inicializa o registro. 
				//------------------------------------------------------------------- 				
				oRecord:Init()

				//-------------------------------------------------------------------
				// Customização.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "D2_FILIAL" , SD2->D2_FILIAL )
				oRecord:SetValue( "D2_DOC" 	  , SD2->D2_DOC )
				oRecord:SetValue( "D2_SERIE"  , SD2->D2_SERIE )
				oRecord:SetValue( "D2_CLIENTE", SD2->D2_CLIENTE )
				oRecord:SetValue( "D2_LOJA"   , SD2->D2_LOJA )
				oRecord:SetValue( "A2_FILIAL" , SA2->A2_FILIAL )
				oRecord:SetValue( "A2_COD"	  , SD2->D2_CLIENTE )
				oRecord:SetValue( "A2_LOJA"	  , SD2->D2_LOJA )
				oRecord:SetValue( "BM_GRUPO"  , SB1->B1_GRUPO )
				oRecord:SetValue( "CTT_CUSTO" , SD1->D1_CC  )	
				oRecord:SetValue( "F4_CODIGO" , SD2->D2_TES )
				oRecord:SetValue( "A4_COD"	  , SF1->F1_TRANSP )
				oRecord:SetValue( "B1_FILIAL" , SB1->B1_FILIAL)
				oRecord:SetValue( "B1_COD"	  , SD2->D2_COD )
				oRecord:SetValue( "E4_CODIGO" , SF1->F1_COND )
				oRecord:SetValue( "ACU_COD", ACV->ACV_CATEGO )
				oRecord:SetValue( "AH_UNIMED" , SD2->D2_UM )

				//-------------------------------------------------------------------
				// Lookups.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "HKL_EMPRES"	, oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
				oRecord:SetValue( "HKL_UNDNEG"	, oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HKL_ESTABL"	, oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
				oRecord:SetValue( "HKL_FORNEC"	, oSeeker:Seek( "HKJ", { SD2->D2_CLIENTE, SD2->D2_LOJA } ) ) 
				oRecord:SetValue( "HKL_TRANSP"	, oSeeker:Seek( "HJ2", { SF1->F1_TRANSP } ) ) 
				oRecord:SetValue( "HKL_FAMMAT"	, oSeeker:Seek( "HG2", { SB1->B1_TIPO } ) ) 
				oRecord:SetValue( "HKL_FAMCOM"	, oSeeker:Seek( "HG1", { ACV->ACV_CATEGO } ) ) 
				oRecord:SetValue( "HKL_GRPEST"	, oSeeker:Seek( "HG3", { SB1->B1_GRUPO } ) ) 
				oRecord:SetValue( "HKL_ITEM"	, oSeeker:Seek( "HJ8", { SD2->D2_COD } ) ) 
				oRecord:SetValue( "HKL_CONDPG"	, oSeeker:Seek( "HJA", { SF1->F1_COND } ) ) 
				oRecord:SetValue( "HKL_REGIAO"	, oSeeker:Seek( "HJB", { oRegion:Key( SA2->A2_EST, SA2->A2_COD_MUN, SA2->A2_PAIS ) } ) ) 
				oRecord:SetValue( "HKL_MOEDA"	, oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
				oRecord:SetValue( "HKL_CCUSTO"	, oSeeker:Seek( "HJ5", { SD1->D1_CC } ) )	
				oRecord:SetValue( "HKL_CFOP"	, oSeeker:Seek( "HG0", { SD2->D2_CF } ) )
				oRecord:SetValue( "HKL_NATOPR"	, oSeeker:Seek( "HJ9", { SD2->D2_TES } ) )
				oRecord:SetValue( "HKL_SITCMP"	, oSeeker:Seek( "HQG", { "D" } ) )
				oRecord:SetValue( "HKL_GRPFOR"	, oSeeker:Seek( "HGE", { SA2->A2_GRUPO } ) ) 
				oRecord:SetValue( "HKL_UNITEM"	, oSeeker:Seek( "HHW", { SD2->D2_UM } ) ) 
				oRecord:SetValue( "HKL_CMPRDR"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HKL_PLCCST"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HKL_NATCMP"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HKL_REFER"	, oSeeker:oKey:GetKey( { UNDEFINED } ) )

				//-------------------------------------------------------------------
				// Atributos.
				//-------------------------------------------------------------------
				oRecord:SetValue( "HKL_NUMNF"	, SD2->D2_DOC )
				oRecord:SetValue( "HKL_SERNF"	, SerieNFID("SD2", 2, "D2_SERIE") )
				oRecord:SetValue( "HKL_REMITO"	, SD2->D2_REMITO )
				oRecord:SetValue( "HKL_SERREM"	, SerieNFID("SD2", 2, "D2_SERIREM") )
				oRecord:SetValue( "HKL_ITEREM"	, SD2->D2_ITEMREM )
				oRecord:SetValue( "HKL_DATA"	, IIf( !Empty( SD2->D2_EMISSAO), SD2->D2_EMISSAO, DATE_EMPTY) )
				oRecord:SetValue( "HKL_EMERG"	, " " )

				If lValid
					oRecord:SetValue( "HKL_PEDIDO"	, SD1->D1_PEDIDO )
					oRecord:SetValue( "HKL_SEQCIA"	, SD1->D1_ITEMPC )

					If SC7->( dbSeek( xFilial("SC7") + SD1->D1_PEDIDO + SD1->D1_ITEMPC  ) )
						If SC1->( dbSeek( xFilial("SC1") + SC7->C7_NUMSC + SC7->C7_ITEMSC  ) )
							oRecord:SetValue( "HKL_ORDEM", SC1->C1_NUM )
						EndIf
					EndIf
				EndIf
				
				//-------------------------------------------------------------------
				// Indicadores.
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HKL_QDEVOL"	, SD2->D2_QUANT )
				oRecord:SetValue( "HKL_VDEVOL"	, BIXValue( SD2->D2_TOTAL, nMoedaAux, cMoeda, SD2->D2_EMISSAO, nTxMoeda)  )
				oRecord:SetValue( "HKL_QORDDV"	, 1 )
				oRecord:SetValue( "HKL_QDVFMT"	, 0 )
				oRecord:SetValue( "HKL_NUMPRG"	, 0 )

				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
			Next nInd
		EndIf
		SD2->( dbSkip() )
	EndDo
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
Return nil