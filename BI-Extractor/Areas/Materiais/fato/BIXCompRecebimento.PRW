#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCOMPRECEBIMENTO.CH"

REGISTER EXTRACTOR HKM

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCompRecebimento
Classe do extrator da fato Recebimento de Compras do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   31/08/2010
/*/
//-------------------------------------------------------------------
Class BIXCompRecebimento from BIXEntity
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
Method New() Class BIXCompRecebimento
	_Super:New( FACT, "HKM", STR0001, "SD1", { MATERIAIS } ) // "Recebimento de Compras" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   23/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXCompRecebimento
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HKM_FORNEC", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HKM_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HKM_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HKM_TRANSP", "C", 32, 0, .T., "HJ2" )
	oModel:AddField( "HKM_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HKM_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HKM_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HKM_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HKM_CMPRDR", "C", 32, 0, .T., "HJZ" )
	oModel:AddField( "HKM_CONDPG", "C", 32, 0, .T., "HJA" )	
	oModel:AddField( "HKM_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HKM_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HKM_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HKM_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HKM_CFOP"  , "C", 32, 0, .T., "HG0" )
	oModel:AddField( "HKM_NATOPR", "C", 32, 0, .T., "HJ9" )
	oModel:AddField( "HKM_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HKM_GRPFOR", "C", 32, 0, .T., "HGE" )
	oModel:AddField( "HKM_SITCMP", "C", 32, 0, .T., "HQG" )
	oModel:AddField( "HKM_NATCMP", "C", 32, 0, .T., "HQH" )
	oModel:AddField( "HKM_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HKM_UNITEM", "C", 32, 0, .T., "HHW" ) 
	oModel:AddField( "HKM_NUMNF" , "C", 35, 0 )
	oModel:AddField( "HKM_SERNF" , "C", 8, 0)
	oModel:AddField( "HKM_EMERG" , "C", 1, 0 )
	oModel:AddField( "HKM_SEQCIA", "C", 10, 0 )
	oModel:AddField( "HKM_REMITO", "C", 13, 0 )	
	oModel:AddField( "HKM_SERREM", "C", 3, 0 )
	oModel:AddField( "HKM_ITEREM", "C", 4, 0 )	
	oModel:AddField( "HKM_ORDEM" , "C", 10, 0 )
	oModel:AddField( "HKM_PEDIDO", "C", 10, 0 )
	oModel:AddField( "HKM_DATA"  , "D", 8, 0 )
	oModel:AddField( "HKM_DATANF", "D", 8, 0 )
	oModel:AddField( "HKM_DTEORD", "D", 8, 0 )
	oModel:AddField( "HKM_DTEPED", "D", 8, 0 )
	oModel:AddField( "HKM_DTPREV", "D", 8, 0 )
	oModel:AddField( "HKM_QDIAAN", "N", 4, 0 )
	oModel:AddField( "HKM_QDIAAT", "N", 4, 0 )
	oModel:AddField( "HKM_NUMPRG", "N", 4, 0 )
	oModel:AddField( "HKM_QRECAN", "N", 4, 0 )
	oModel:AddField( "HKM_QRECAT", "N", 4, 0 )
	oModel:AddField( "HKM_QRECDT", "N", 4, 0 )
	oModel:AddField( "HKM_QRECUN", "N", 4, 0 )
	oModel:AddField( "HKM_QRECEB", "N", 16, 4 )
	oModel:AddField( "HKM_QRECFM", "N", 16, 4 )
	oModel:AddField( "HKM_VRECEB", "N", 16, 2 )

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXCompRecebimento
	Local oRegion	:= nil
	Local aMoedas  := {}
	Local cMoeda   := ""     
	Local nInd     := 1     
	Local nDiasAnt := 0
	Local nDiasAtr := 0     
	Local lPos     := .F.
	Local nTxMoeda := 0
	Local lTxMoeda := .F.
	Local lFindSA2 := .F.

	aMoedas := BIXGetMxF( ::cEntity )
	lTxMoeda := LoadTxMoeda() //Define a utilização da taxa negociada na conversão de moeda.
	oRegion	:= BIXRegiao():New()
	
	DbSelectArea("SD1")         // Itens das NF de Entrada
	SD1->( dbSetOrder(6) ) // D1_FILIAL + DTOS(D1_DTDIGIT) + D1_NUMSEQ 
	
	DbSelectArea("SB1")         // Produto (Item)
	SB1->( dbSetOrder(1) )       
	
	DbSelectArea("SF1")         // Cabecalho das NF de Entrada    
	SF1->( dbSetOrder(1) ) // F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA + F1_TIPO	
	
	DbSelectArea("SA2")         // Fornecedor    
	SA2->( dbSetOrder(1) ) 	      
	
	DbSelectArea("SC7")         // Pedidos de Compra 
	SC7->( dbSetOrder(1) )   
	
	DbSelectArea("SC1") 
	SC1->( dbSetOrder(1) )    
	
	DbSelectArea("ACV")          
	ACV->( dbSetOrder(5) ) // ACV_FILIAL + ACV_CODPRO + ACV_CATEGO 
    
	DbSelectArea("SF4") 
	SF4->( dbSetOrder(1) )

	SD1->( dbSeek( xFilial("SD1") + cFrom, .T.) )	  
	
	While SD1->(! EoF() ) .And. SD1->D1_FILIAL == xFilial("SD1") .And. 	SD1->D1_DTDIGIT <= StoD(cTo)     
		If !(SD1->D1_ORIGLAN == 'LF') .And. !(SD1->D1_TIPO $ 'D*B'  )
			If ! SF4->(MsSeek(xFilial("SF4") + SD1->D1_TES)) .Or. SF4->F4_PODER3 == 'D'
				SD1->(DbSkip())
				Loop
			EndIf    		
		  
			nTxMoeda := 0			
			lPos := .F.
			nDiasAnt := 0
			nDiasAtr := 0
			lFindSA2 := .F.
							 	
			If SA2->( dbSeek( xFilial("SA2") + SD1->D1_FORNECE + SD1->D1_LOJA ) )
				lFindSA2 := .T.
			EndIf
										 	
			ACV->( dbSeek( xFilial("ACV") + SD1->D1_COD ) )
			SB1->( dbSeek( xFilial("SB1") + SD1->D1_COD ) )

			If SF1->( dbSeek( xFilial("SF1") + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA ) )
				//-------------------------------------------------------------------
				// No Mercado internacional, as tabelas SC5, SC7, SF1, SF2, SE1, 
				// SE5 e SE2 utilizam o campo ??_TXMOEDA (TAXA NEGOCIADA) que define
				// a taxa usada para a operação, caso seja ZERO deve ser considerada 
				// a cotação da moeda para o dia.
				//-------------------------------------------------------------------	
				If cPaisLoc != "BRA" .Or. lTxMoeda
					nTxMoeda := SF1->F1_TXMOEDA
				EndIf
			Endif
			
			If SC7->( dbSeek( xFilial("SC7") + SD1->D1_PEDIDO + SD1->D1_ITEMPC ) )
				lPos := .T.
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
				oRecord:SetValue( "D1_FILIAL" , SD1->D1_FILIAL )
				oRecord:SetValue( "D1_DOC" 	  , SD1->D1_DOC )
				oRecord:SetValue( "D1_SERIE"  , SD1->D1_SERIE )
				oRecord:SetValue( "D1_FORNECE", SD1->D1_FORNECE )
				oRecord:SetValue( "D1_LOJA"	  , SD1->D1_LOJA )
				oRecord:SetValue( "D1_ITEM"	  , SD1->D1_ITEM )
				
				oRecord:SetValue( "A2_FILIAL" , SA2->A2_FILIAL )
				oRecord:SetValue( "A2_COD"	  , SD1->D1_FORNECE )
				oRecord:SetValue( "A2_LOJA"	  , SD1->D1_LOJA )
				oRecord:SetValue( "CTT_CUSTO" , SD1->D1_CC  )	
				oRecord:SetValue( "F4_CODIGO" , SD1->D1_TES )
				oRecord:SetValue( "A4_COD"	  , SF1->F1_TRANSP )
				oRecord:SetValue( "B1_FILIAL" , SB1->B1_FILIAL)
				oRecord:SetValue( "B1_COD"	  , SD1->D1_COD )
				oRecord:SetValue( "E4_CODIGO" , SF1->F1_COND )
				oRecord:SetValue( "ACU_COD"   , ACV->ACV_CATEGO )
				oRecord:SetValue( "BM_GRUPO"  , SB1->B1_GRUPO )
				oRecord:SetValue( "Y1_COD"    , SC7->C7_COMPRA )
				oRecord:SetValue( "AH_UNIMED" , SD1->D1_UM )

				//-------------------------------------------------------------------
				// Lookups.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "HKM_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
				oRecord:SetValue( "HKM_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HKM_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
				oRecord:SetValue( "HKM_FORNEC", oSeeker:Seek( "HKJ", { SD1->D1_FORNECE, SD1->D1_LOJA } ) ) 
				oRecord:SetValue( "HKM_TRANSP", oSeeker:Seek( "HJ2", { SF1->F1_TRANSP } ) ) 
				oRecord:SetValue( "HKM_FAMMAT", oSeeker:Seek( "HG2", { SB1->B1_TIPO } ) ) 
				oRecord:SetValue( "HKM_FAMCOM", oSeeker:Seek( "HG1", { ACV->ACV_CATEGO } ) )
				oRecord:SetValue( "HKM_GRPEST", oSeeker:Seek( "HG3", { SB1->B1_GRUPO } ) ) 
				oRecord:SetValue( "HKM_ITEM"  , oSeeker:Seek( "HJ8", { SD1->D1_COD } ) )
				oRecord:SetValue( "HKM_CMPRDR", oSeeker:Seek( "HJZ", { SC7->C7_COMPRA } ) ) 
				oRecord:SetValue( "HKM_CONDPG", oSeeker:Seek( "HJA", { SF1->F1_COND } ) ) 
				oRecord:SetValue( "HKM_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
				oRecord:SetValue( "HKM_CCUSTO", oSeeker:Seek( "HJ5", { SD1->D1_CC } ) )
				oRecord:SetValue( "HKM_CFOP"  , oSeeker:Seek( "HG0", { SD1->D1_CF } ) )
				oRecord:SetValue( "HKM_NATOPR", oSeeker:Seek( "HJ9", { SD1->D1_TES } ) )
				oRecord:SetValue( "HKM_UNITEM", oSeeker:Seek( "HHW", { SD1->D1_UM } ) )
				oRecord:SetValue( "HKM_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HKM_NATCMP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HKM_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
				
				If lFindSA2
					oRecord:SetValue( "HKM_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( SA2->A2_EST, SA2->A2_COD_MUN, SA2->A2_PAIS ) } ) ) 
					oRecord:SetValue( "HKM_GRPFOR", oSeeker:Seek( "HGE", { SA2->A2_GRUPO } ) ) 
				Else
					oRecord:SetValue( "HKM_REGIAO", oSeeker:oKey:GetKey( { UNDEFINED } ) )
					oRecord:SetValue( "HKM_GRPFOR", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				EndIf
								
				If lPos       
					oRecord:SetValue( "HKM_SITCMP", oSeeker:Seek( "HQG", { SC7->C7_TPOP } ) )
					If SC7->C7_QUJE > 0 .And. SC7->C7_QUJE < SC7->C7_QUANT
						oRecord:SetValue( "HKM_SITCMP", oSeeker:Seek( "HQG", { "R" } ) )
					ElseIf SC7->C7_QUJE >= SC7->C7_QUANT                           
						oRecord:SetValue( "HKM_SITCMP", oSeeker:Seek( "HQG", { "I" } ) )
					EndIf
				Else
					oRecord:SetValue( "HKM_SITCMP" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
				endIf
				
				//-------------------------------------------------------------------
				// Atributos.
				//-------------------------------------------------------------------
				oRecord:SetValue( "HKM_PEDIDO" , SD1->D1_PEDIDO )
				oRecord:SetValue( "HKM_SEQCIA" , SD1->D1_ITEM )
				oRecord:SetValue( "HKM_DATANF" , IIf( !Empty( SD1->D1_EMISSAO), SD1->D1_EMISSAO, DATE_EMPTY) )
				oRecord:SetValue( "HKM_DATA" , IIf( !Empty( SD1->D1_DTDIGIT), SD1->D1_DTDIGIT, DATE_EMPTY) )
				oRecord:SetValue( "HKM_DTEORD" , DATE_EMPTY )
				oRecord:SetValue( "HKM_NUMNF", SD1->D1_DOC )
				oRecord:SetValue( "HKM_SERNF", SerieNFID("SD1", 2, "D1_SERIE") )
				oRecord:SetValue( "HKM_EMERG", " ")
				oRecord:SetValue( "HKM_REMITO", SD1->D1_REMITO )
		       oRecord:SetValue( "HKM_SERREM", SerieNFID("SD1", 2, "D1_SERIREM") )
		       oRecord:SetValue( "HKM_ITEREM", SD1->D1_ITEMREM )
				
				If lPos       
					If SC1->( dbSeek(xFilial("SC1") + SC7->C7_NUMSC + SC7->C7_ITEMSC) )
						oRecord:SetValue( "HKM_DTEORD" , SC1->C1_EMISSAO )
					EndIf
					
					oRecord:SetValue( "HKM_ORDEM" , SC7->C7_NUMSC )
					oRecord:SetValue( "HKM_DTEPED" , IIf( !Empty(SC7->C7_EMISSAO), SC7->C7_EMISSAO, DATE_EMPTY) )
					oRecord:SetValue( "HKM_DTPREV" , IIf( !Empty( SC7->C7_DATPRF), SC7->C7_DATPRF, DATE_EMPTY) )
				Else
					oRecord:SetValue( "HKM_ORDEM" , " " )
					oRecord:SetValue( "HKM_DTEPED" , DATE_EMPTY )
					oRecord:SetValue( "HKM_DTPREV" , DATE_EMPTY )
				EndIf
							
				//-------------------------------------------------------------------
				// Indicadores.
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HKM_QRECEB", SD1->D1_QUANT )
				oRecord:SetValue( "HKM_VRECEB", BIXValue(SD1->D1_TOTAL, SF1->F1_MOEDA, cMoeda, SD1->D1_DTDIGIT, nTxMoeda) )
				oRecord:SetValue( "HKM_QRECFM", 0 )

				oRecord:SetValue( "HKM_NUMPRG" , 0 )
					
				If lPos       
					If Empty(SC7->C7_DATPRF) .Or. Empty(SD1->D1_DTDIGIT)
						nDiasAnt := 0
					ElseIf SD1->D1_DTDIGIT > SC7->C7_DATPRF
						nDiasAnt := 0
					Else
						nDiasAnt := ( SC7->C7_DATPRF - SD1->D1_DTDIGIT )
						
						If ( Abs( nDiasAnt ) > 9999 )
							nDiasAnt := 9999
						EndIf
					EndIf   
					oRecord:SetValue( "HKM_QDIAAN" , nDiasAnt )
					
					If Empty(SC7->C7_DATPRF) .Or. Empty(SD1->D1_DTDIGIT)
						nDiasAtr := 0
					ElseIf SC7->C7_DATPRF > SD1->D1_DTDIGIT 
						nDiasAtr := 0
					Else
						nDiasAtr := ( SD1->D1_DTDIGIT - SC7->C7_DATPRF )
					
						If ( Abs( nDiasAtr ) > 9999 )
							nDiasAtr := 9999
						EndIf					
					EndIf 
					oRecord:SetValue( "HKM_QDIAAT" , nDiasAtr )
					
					If nDiasAnt > 0
						oRecord:SetValue( "HKM_QRECAN" , 1 )
					Else
						oRecord:SetValue( "HKM_QRECAN" , 0 )
					EndIf            
					
					If nDiasAtr < 0
						oRecord:SetValue( "HKM_QRECAT" , 1 )
					Else
						oRecord:SetValue( "HKM_QRECAT" , 0 )
					EndIf 
					
					If nDiasAnt == 0 .And. nDiasAtr == 0
						oRecord:SetValue( "HKM_QRECDT" , 1 )
					Else
						oRecord:SetValue( "HKM_QRECDT" , 0 )
					EndIf 
					
					If SD1->D1_QUANT >= SC7->C7_QUANT
						oRecord:SetValue( "HKM_QRECUN" , 1 )
					Else
						oRecord:SetValue( "HKM_QRECUN" , 0 )
					EndIf
				Else
					oRecord:SetValue( "HKM_QDIAAN" , 0 )
					oRecord:SetValue( "HKM_QDIAAT" , 0 )
					oRecord:SetValue( "HKM_QRECAN" , 0 )
					oRecord:SetValue( "HKM_QRECAT" , 0 )
					oRecord:SetValue( "HKM_QRECDT" , 0 )
					oRecord:SetValue( "HKM_QRECUN" , 0 )
				EndIf

				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
			Next nInd	
		EndIf   
		SD1->( dbSkip() )
	EndDo
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
Return nil
