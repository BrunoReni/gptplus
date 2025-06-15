#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCONSMATPRMA.CH"

REGISTER EXTRACTOR HLR

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXConsMatPrma
Classe do extrator para a tabela fato Matéria-Prima - Consumida Extrator TOTVS B.I.

@author  BI TEAM
@since   23/09/2010
/*/
//-------------------------------------------------------------------
Class BIXConsMatPrma from BIXEntity
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
Method New() Class BIXConsMatPrma
	_Super:New( FACT, "HLR", STR0001, "SD3", { PRODUCAO } ) //"Matéria-Prima - Consumida"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   26/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXConsMatPrma
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLR_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLR_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLR_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HLR_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HLR_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HLR_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HLR_PLANEJ", "C", 32, 0, .T., "HJX" )
	oModel:AddField( "HLR_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HLR_DEPOSI", "C", 32, 0, .T., "HJD" )
	oModel:AddField( "HLR_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HLR_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HLR_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HLR_ITMPAI", "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HLR_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HLR_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HLR_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HLR_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HLR_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HLR_DATA"  , "D", 8, 0 )
	oModel:AddField( "HLR_PEDIDO", "C", 12, 0 )		
	oModel:AddField( "HLR_SEQCIA", "C", 10, 0 )		
	oModel:AddField( "HLR_ORDEM" , "C", 13, 0 )		
	oModel:AddField( "HLR_TIPSOB", "C", 30, 0 )		
	oModel:AddField( "HLR_QCONSU", "N", 16, 4 )	
	oModel:AddField( "HLR_QCSFMT", "N", 16, 4 )	
	oModel:AddField( "HLR_QCSFCM", "N", 16, 4 )	
	oModel:AddField( "HLR_VCONMP", "N", 16, 2 )	

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXConsMatPrma
	Local oRegion    := NIL
	Local aMoedas    := {}
	Local prevAlias  := GetArea()
	Local cMoeda     := ""
	Local cSC2Filter := ""                    
	Local cSD3Filter := ""
	Local nInd       := 1
	Local lFindCli   := .F.
	Local lCatego    := .F.
	Local lLocal     := .F.
	Local cTIPITM    := ""
	
	aMoedas := BIXGetMxF(::cEntity)
	oRegion	:= BIXRegiao():New()

	      
	DbSelectArea("SD3")
	SD3->( dbSetOrder(1) ) // Filial + ...
	
	cSD3Filter := " D3_FILIAL == '" + xFilial("SD3") + "' " 
	cSD3Filter += " .AND. SUBSTRING(D3_CF, 1, 2) = 'RE' "
	cSD3Filter += " .AND. D3_ESTORNO <> 'S' "
	cSD3Filter += " .AND. D3_OP <> ' ' "

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
	
	While SD3->(! Eof() )
		cTIPITM  := ""
		lFindCli := .F.
		lLocal   := .F.
		lCatego  := .F.

		// Considera apenas produtos que não são Mão de Obra	
		If IsProdMod(SD3->D3_COD)
			SD3->( dbSkip() )
			Loop
		EndIf	   
		
		If SB1->( MsSeek( xFilial("SB1") + SD3->D3_COD ) ) .And. SC2->( MsSeek( xFilial("SC2") + SD3->D3_OP ) )
			If SC5->( MsSeek( xFilial("SC5") + SC2->C2_PEDIDO ) )
	  			If SA1->( MsSeek( xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ))
					lFindCli := .T.
				EndIf
			EndIf

			If ACV->( MsSeek( xFilial("ACV") + SC2->C2_PRODUTO ) )           
				lCatego := .T.
			EndIf
			
			If !Empty(SC2->C2_LOCAL)
				lLocal := .T.
			EndIf  			

			If SG1->( dbSeek( xFilial("SG1") + SB1->B1_COD) )
				If SB1->B1_TIPO == "MP"
					cTIPITM := "3" // Matéria Prima
				Else
					cTIPITM := "2" // Fabricado
				EndIf
			Else
				cTIPITM := "1" // Comprado
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
				oRecord:SetValue( "D3_OP"		, SD3->D3_OP )
				oRecord:SetValue( "D3_COD"		, SD3->D3_COD )
				oRecord:SetValue( "D3_LOCAL"	, SD3->D3_LOCAL )
				
				oRecord:SetValue( "ACU_COD"		, ACV->ACV_CATEGO )
				oRecord:SetValue( "A1_COD"		, SC5->C5_CLIENTE )
				oRecord:SetValue( "A1_LOJA"		, SC5->C5_LOJACLI )
				oRecord:SetValue( "B1_COD"		, SD3->D3_COD )
				oRecord:SetValue( "BM_GRUPO"	, SB1->B1_GRUPO )
				oRecord:SetValue( "AH_UNIMED"	, SD3->D3_UM )

				//-------------------------------------------------------------------
				// Lookups.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "HLR_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
				oRecord:SetValue( "HLR_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HLR_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
				oRecord:SetValue( "HLR_FAMMAT", oSeeker:Seek( "HG2", { SB1->B1_TIPO } ) ) 
				oRecord:SetValue( "HLR_GRPEST", oSeeker:Seek( "HG3", { SB1->B1_GRUPO } ) ) 
				oRecord:SetValue( "HLR_ITEM"  , oSeeker:Seek( "HJ8", { SD3->D3_COD } ) )
				oRecord:SetValue( "HLR_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
				oRecord:SetValue( "HLR_ITMPAI", oSeeker:Seek( "HJ8", { SC2->C2_PRODUTO } ) ) 
				oRecord:SetValue( "HLR_UNITEM", oSeeker:Seek( "HHW", { SD3->D3_UM } ) ) 
				oRecord:SetValue( "HLR_TIPITM", oSeeker:Seek( "HGC", { cTipITM } ) )
				
				If lFindCli
					oRecord:SetValue( "HLR_CLIENT", oSeeker:Seek( "HJ7", { SC5->C5_CLIENTE, SC5->C5_LOJACLI } ) )
					oRecord:SetValue( "HLR_GRPCLI", oSeeker:Seek( "HJ0", { SA1->A1_TIPO } ) )
					oRecord:SetValue( "HLR_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( SA1->A1_EST, SA1->A1_COD_MUN, SA1->A1_PAIS ) } ) ) 
				Else
					oRecord:SetValue( "HLR_CLIENT", oSeeker:oKey:GetKey( { UNDEFINED } ) )
					oRecord:SetValue( "HLR_GRPCLI", oSeeker:oKey:GetKey( { UNDEFINED } ) )
					oRecord:SetValue( "HLR_REGIAO", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				EndIf

				If lCatego
					oRecord:SetValue( "HLR_FAMCOM", oSeeker:Seek( "HG1", { ACV->ACV_CATEGO } ) ) 
				Else
					oRecord:SetValue( "HLR_FAMCOM", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				EndIf

				If lLocal
					oRecord:SetValue( "HLR_DEPOSI", oSeeker:Seek( "HJD", { SC2->C2_LOCAL } ) ) 
				Else
					oRecord:SetValue( "HLR_DEPOSI", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				EndIF
				
				oRecord:SetValue( "HLR_LINHAP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLR_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLR_PLANEJ", oSeeker:oKey:GetKey( { UNDEFINED } ) )

				//-------------------------------------------------------------------
				// Atributos.
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HLR_PEDIDO", SC2->C2_PEDIDO ) // Dimensão Numero do Pedido
				oRecord:SetValue( "HLR_SEQCIA", SC2->C2_SEQUEN ) // Sequência da Ordem 
				oRecord:SetValue( "HLR_ORDEM", SD3->D3_OP     ) // Ordem de Produção
				oRecord:SetValue( "HLR_DATA", 	SD3->D3_EMISSAO )              // Data de Movimento do Item da Ordem

				//-------------------------------------------------------------------
				// Indicadores.
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HLR_QCONSU", SD3->D3_QUANT   )              // Qtde Consumida
				oRecord:SetValue( "HLR_VCONMP", &("SD3->D3_CUSTO" + cMoeda ) ) // Vl Consumido Matéria Prima
				oRecord:SetValue( "HLR_QCSFMT", 0 )                     // Qtde Consumida UN FM
				oRecord:SetValue( "HLR_QCSFCM", 0 )                     // Qtde Consumida UN FC
				
				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
			Next nInd
		Endif	
		SD3->( dbSkip() )
	EndDo
	
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	

	SD3->( DBClearFilter() ) // Remove filtro
	SC2->( DBClearFilter() ) // Remove filtro
	RestArea(prevAlias)
Return NIL
