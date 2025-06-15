#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMOBREALIZADO.CH"

REGISTER EXTRACTOR HKX

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMOBRealizado
Classe do extrator para a tabela fato Mão de Obra Realizada  Extrator TOTVS B.I.

@author  BI TEAM
@since   23/09/2010
/*/
//-------------------------------------------------------------------
Class BIXMOBRealizado from BIXEntity
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
Method New() Class BIXMOBRealizado
	_Super:New( FACT, "HKX", STR0001, "SC2", { PRODUCAO } ) //"Mão-de-Obra - Realizada"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   26/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXMOBRealizado
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HKX_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HKX_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HKX_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HKX_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HKX_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HKX_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HKX_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HKX_PLANEJ", "C", 32, 0, .T., "HJX" )
	oModel:AddField( "HKX_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HKX_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HKX_GRPMAQ", "C", 32, 0, .T., "HJY" )
	oModel:AddField( "HKX_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HKX_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HKX_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HKX_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HKX_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HKX_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HKX_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HKX_MOBDIR", "C", 32, 0, .T., "HGH" )
	oModel:AddField( "HKX_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HKX_DATA"  , "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HKX_PEDIDO", "C", 12, 0 )
	oModel:AddField( "HKX_SEQCIA", "C", 10, 0 )
	oModel:AddField( "HKX_ORDEM" , "C", 13, 0 )
	oModel:AddField( "HKX_QHRMOB", "N", 16, 4 )
	oModel:AddField( "HKX_VCSMOB", "N", 16, 2 )

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXMOBRealizado
	Local oRegion	:= NIL
	Local aMoedas   := {}
	Local lFindACV := .F.
	Local lFindSA1 := .F.
	Local cTipITM := ""
	Local nQHRMOB := 0
	Local nVCSMOB := 0
	Local prevAlias  := GetArea()
	Local cMoeda     := ""
	Local cSC2Filter := ""                    
	Local cSD3Filter := ""
	Local nInd       := 1 

	aMoedas := BIXGetMxF(::cEntity)
	oRegion	:= BIXRegiao():New()
	
	DbSelectArea("SD3")
	SD3->( dbSetOrder(1) ) // Filial + ...
	
	cSD3Filter := "D3_FILIAL == '" + xFilial("SD3") + "' "
	cSD3Filter += ".AND. SUBSTRING(D3_CF,1,2) = 'RE' "
	cSD3Filter += ".AND. D3_OP <> ' ' "
	cSD3Filter += ".AND. D3_ESTORNO <> 'S' "
	
	SD3->( DBSetFilter ( {|| &cSD3Filter}, cSD3Filter) )
	SD3->( dbGoTop() )

	DbSelectArea("SC2")
	SC2->( dbSetOrder(1) ) // Filial + C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD
	
	// Filtrar periodo
	cSC2Filter := "C2_FILIAL == '" + xFilial("SC2") + "' "	
	cSC2Filter += " .AND. DTOS(C2_EMISSAO) >= '" + cFrom + "' "
	cSC2Filter += " .AND. DTOS(C2_EMISSAO) <= '" + cTo + "' "
	
	SC2->( DBSetFilter ( {|| &cSC2Filter}, cSC2Filter) )
	SC2->( dbGoTop() )
	
	DbSelectArea("SC5")	
	SC5->( dbSetOrder(1) ) // Filial + C5_NUM

	DbSelectArea("ACV")     
	ACV->( dbSetOrder(5) ) // Filial + ACV_CODPRO + ACV_CATEGO

	DbSelectArea("SG1")
	SG1->( dbSetOrder(1) ) // Filial + G1_COD + G1_COMP + G1_TRT

	While SC2->(! Eof() ) 
		lFindACV := .F.
		lFindSA1 := .F.
		cTipITM := ""
		nQHRMOB := 0
		nVCSMOB := 0

		If SB1->( MsSeek( xFilial("SB1") + SC2->C2_PRODUTO ) ) 
			cNumOp 	:= (SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + SC2->C2_ITEMGRD)	
			
			//-------------------------------------------------------------------
			// Verifica a integridade referencial das dimensões.  
			//------------------------------------------------------------------- 
			If SC5->( MsSeek( xFilial("SC5") + SC2->C2_PEDIDO ) )
				If SA1->( MsSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI  ) )
					lFindSA1 := .T.
				EndIf		
			EndIf 
 			
			If ACV->( MsSeek( xFilial("ACV") + SC2->C2_PRODUTO ) )
				lFindACV := .T.
			EndIf

			If SG1->( MsSeek( xFilial("SG1") + SB1->B1_COD) )
				If SB1->B1_TIPO == "MP"
					cTipITM := "3" // Matéria Prima
				Else
					cTipITM := "2" // Fabricado
				EndIf
			Else
				cTipITM := "1" // Comprado
			EndIf 
			
			For nInd := 1 To Len(aMoedas)
				nQHRMOB := 0
				nVCSMOB := 0
				cMoeda := aMoedas[nInd][1]
		
				//-------------------------------------------------------------------
				// Inicializa o registro. 
				//------------------------------------------------------------------- 				
				oRecord:Init()
				
				//-------------------------------------------------------------------
				// Customização.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "C2_NUM"  , SC2->C2_NUM )
				oRecord:SetValue( "C2_ITEM"  , SC2->C2_ITEM )
				oRecord:SetValue( "C2_SEQUEN"  , SC2->C2_SEQUEN )
				oRecord:SetValue( "CTT_CUSTO"  , SC2->C2_CC )
				oRecord:SetValue( "ACU_COD"    , ACV->ACV_CATEGO )			
				oRecord:SetValue( "A1_COD"     , SC5->C5_CLIENTE )
				oRecord:SetValue( "A1_LOJA"    , SC5->C5_LOJACLI )
				oRecord:SetValue( "B1_COD"     , SC2->C2_PRODUTO )
				oRecord:SetValue( "BM_GRUPO"   , SB1->B1_GRUPO )
				oRecord:SetValue( "AH_UNIMED"  , SC2->C2_UM )
				
				//-------------------------------------------------------------------
				// Lookups.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "HKX_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
				oRecord:SetValue( "HKX_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
				oRecord:SetValue( "HKX_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HKX_FAMMAT", oSeeker:Seek( "HG2", { SB1->B1_TIPO } ) ) 
				oRecord:SetValue( "HKX_GRPEST", oSeeker:Seek( "HG3", { SB1->B1_GRUPO } ) ) 
				oRecord:SetValue( "HKX_ITEM"  , oSeeker:Seek( "HJ8", { SC2->C2_PRODUTO } ) ) 
				oRecord:SetValue( "HKX_CCUSTO", oSeeker:Seek( "HJ5", { SC2->C2_CC } ) ) 
				oRecord:SetValue( "HKX_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
				oRecord:SetValue( "HKX_TIPITM", oSeeker:Seek( "HGC", { cTipITM } ) ) 
				oRecord:SetValue( "HKX_UNITEM", oSeeker:Seek( "HHW", { SC2->C2_UM } ) ) 
				
				If lFindACV
					oRecord:SetValue( "HKX_FAMCOM", oSeeker:Seek( "HG1", { ACV->ACV_CATEGO } ) ) 
				Else
					oRecord:SetValue( "HKX_FAMCOM", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				EndIf

				If lFindSA1
					oRecord:SetValue( "HKX_CLIENT", oSeeker:Seek( "HJ7", { SC5->C5_CLIENTE, SC5->C5_LOJACLI} ) )
					oRecord:SetValue( "HKX_GRPCLI", oSeeker:Seek( "HJ0", { SA1->A1_TIPO } ) )
					oRecord:SetValue( "HKX_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( SA1->A1_EST, SA1->A1_COD_MUN, SA1->A1_PAIS ) } ) )
				Else
					oRecord:SetValue( "HKX_CLIENT", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
					oRecord:SetValue( "HKX_GRPCLI", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
					oRecord:SetValue( "HKX_REGIAO", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				EndIf			
				
				oRecord:SetValue( "HKX_LINHAP", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HKX_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HKX_MOBDIR", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HKX_PLANEJ", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HKX_GRPMAQ", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HKX_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )	

				//-------------------------------------------------------------------
				// Atributos.
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HKX_PEDIDO", SC2->C2_PEDIDO ) // Dimensão Numero do Pedido
				oRecord:SetValue( "HKX_SEQCIA", SC2->C2_SEQUEN ) // Sequência da Ordem 
				oRecord:SetValue( "HKX_ORDEM" , cNumOp         ) // Ordem de Produção

				//-------------------------------------------------------------------
				// Indicadores.
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HKX_DATA"  , SC2->C2_EMISSAO ) // Data do Movimento do Item de Produção
				
				SD3->( MsSeek(xFilial("SD3") + cNumOp))
				While SD3->(!Eof()) .And. SD3->D3_FILIAL == SC2->C2_FILIAL .And. SD3->D3_OP == cNumOp
					// Considera apenas produtos que são Mão de Obra	
					If !IsProdMod(SD3->D3_COD)
						SD3->( dbSkip() )
						Loop
					EndIf					

					nQHRMOB += SD3->D3_QUANT                // Qtde Horas MOB
					nVCSMOB += &("SD3->D3_CUSTO" + cMoeda ) // Vl Custo Hora MOB
					
					SD3->( dbSkip() )
				EndDo

				oRecord:SetValue( "HKX_QHRMOB", nQHRMOB ) // Qtde Horas MOB
				oRecord:SetValue( "HKX_VCSMOB", nVCSMOB ) // Vl Custo Hora MOB

				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
			Next nInd
		EndIf
		SC2->( dbSkip() )
	EndDo
	
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	

	SD3->( DBClearFilter() ) // Remove filtro
	SC2->( DBClearFilter() ) // Remove filtro
	RestArea(prevAlias)
Return NIL