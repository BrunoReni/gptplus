#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXMOBPREVISTO.CH"

REGISTER EXTRACTOR HLX

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXMOBPrevisto
Classe do extrator para a tabela fato Mão de Obra Prevista Extrator TOTVS B.I.

@author  BI TEAM
@version P11 
@since   23/09/2010
/*/
//-------------------------------------------------------------------
Class BIXMOBPrevisto from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
endClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   26/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXMOBPrevisto
	_Super:New( FACT, "HLX", STR0001, "SC2", { PRODUCAO } ) //"Mão-de-Obra Prevista"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   26/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXMOBPrevisto
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLX_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLX_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLX_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HLX_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HLX_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HLX_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HLX_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HLX_PLANEJ", "C", 32, 0, .T., "HJX" )
	oModel:AddField( "HLX_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HLX_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HLX_GRPMAQ", "C", 32, 0, .T., "HJY" )
	oModel:AddField( "HLX_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HLX_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HLX_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HLX_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HLX_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HLX_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HLX_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HLX_MOBDIR", "C", 32, 0, .T., "HGH" )
	oModel:AddField( "HLX_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HLX_DATA"  , "D", 8, 0, .F., "HK2" )		
	oModel:AddField( "HLX_ORDEM" , "C", 13, 0 )
	oModel:AddField( "HLX_PEDIDO", "C", 12, 0 )		
	oModel:AddField( "HLX_SEQCIA", "C", 10, 0 )		
	oModel:AddField( "HLX_QHRMOP", "N", 16, 4 )	
	oModel:AddField( "HLX_VCSMOP", "N", 16,	2 )
	
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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXMOBPrevisto
	Local oRegion	:= NIL
	Local aMoedas   := {}
	Local cMoeda	:= ""
	Local cFilter	:= ""                    
	Local nMoeda    := 1 
	Local cNumOP	:= ""
	Local cTipITM 	:= ""
	Local lFindSA1 	:= .F.
	Local lFindACV 	:= .F.
	Local nQHRMOP := 0
	Local nVCSMOP := 0

	aMoedas := BIXGetMxF(::cEntity)
	oRegion	:= BIXRegiao():New()
	
	DbSelectArea("SD4")	
	SD4->( dbSetOrder(2) ) // Filial + OP...

	DbSelectArea("SB1")
	SB1->( dbSetOrder(1) ) // Filial + B1_COD

	DbSelectArea("SC5")
	SC5->( dbSetOrder(1) ) // Filial + C5_NUM
    
	DbSelectArea("ACV")	
	ACV->( dbSetOrder(5) ) // Filial + ACV_CODPRO + ACV_CATEGO

	DbSelectArea("SB2")
	SB2->( dbSetOrder(1) )

	DbSelectArea("SG1")	
	SG1->( dbSetOrder(1) ) // Filial + G1_COD + G1_COMP + G1_TRT
  	
	DbSelectArea("SC2")	
	SC2->( dbSetOrder(1) ) // Filial + C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD

	//----------------------------------------------------------
	// Filtrar período.
	//----------------------------------------------------------
	cFilter := " C2_FILIAL == '" + xFilial("SC2") + "' "	
	cFilter += " .AND. DTOS(C2_EMISSAO) >= '" + cFrom + "' "
	cFilter += " .AND. DTOS(C2_EMISSAO) <= '" + cTo + "' "
	cFilter += " .AND. C2_QUANT > 0"
	cFilter += " .AND. C2_QUJE = 0"	
	
	

	SC2->( DBSetFilter ( {|| &cFilter}, cFilter) )
	SC2->( dbGoTop() )
	
	

	While SC2->(! Eof() ) 
		If SB1->( MsSeek( xFilial("SB1") + SC2->C2_PRODUTO ) )
			lFindACV := .F.
			lFindSA1 := .F.
			cTipITM := ""
			nQHRMOP := 0
			nVCSMOP := 0
			cNumOp 	:= (SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + SC2->C2_ITEMGRD)
			
			//-------------------------------------------------------------------
			// Verifica a integridade referencial das dimensões.  
			//------------------------------------------------------------------- 
			If SC5->( MsSeek( xFilial("SC5") + SC2->C2_PEDIDO ) )
				If SA1->( MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ))
					lFindSA1 := .T.
				EndIf
			EndIf          
			
			If ACV->( MSSeek( xFilial("ACV") + SC2->C2_PRODUTO ) )
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

			// Determina o roteiro para o cálculo
			If !Empty(SC2->C2_ROTEIRO)
				cOperPad := SC2->C2_ROTEIRO
			Else
				cOperPad := Posicione("SB1", 1, xFilial("SB1") + SC2->C2_PRODUTO, "B1_OPERPAD")
			EndIf 	 
			
			For nMoeda := 1 To Len(aMoedas)
				nQHRMOP := 0
				nVCSMOP := 0

				cMoeda := aMoedas[nMoeda][1]
		
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
				oRecord:SetValue( "AH_UNIMED"  , SB1->B1_UM )

				//-------------------------------------------------------------------
				// Lookups.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "HLX_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
				oRecord:SetValue( "HLX_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
				oRecord:SetValue( "HLX_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HLX_FAMMAT", oSeeker:Seek( "HG2", { SB1->B1_TIPO } ) ) 
				oRecord:SetValue( "HLX_GRPEST", oSeeker:Seek( "HG3", { SB1->B1_GRUPO } ) )
				oRecord:SetValue( "HLX_ITEM"  , oSeeker:Seek( "HJ8", { SC2->C2_PRODUTO } ) ) 
				oRecord:SetValue( "HLX_CCUSTO", oSeeker:Seek( "HJ5", { SC2->C2_CC } ) ) 
				oRecord:SetValue( "HLX_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nMoeda][2] } ) ) 
				oRecord:SetValue( "HLX_TIPITM", oSeeker:Seek( "HGC", { cTipITM } ) ) 
				oRecord:SetValue( "HLX_UNITEM", oSeeker:Seek( "HHW", { SB1->B1_UM } ) ) 
				
				If lFindSA1
					oRecord:SetValue( "HLX_CLIENT", oSeeker:Seek( "HJ7", { SC5->C5_CLIENTE, SC5->C5_LOJACLI} ) )
					oRecord:SetValue( "HLX_GRPCLI", oSeeker:Seek( "HJ0", { SA1->A1_TIPO } ) )
					oRecord:SetValue( "HLX_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( SA1->A1_EST, SA1->A1_COD_MUN, SA1->A1_PAIS ) } ) )
				Else
					oRecord:SetValue( "HLX_CLIENT", oSeeker:oKey:GetKey( { UNDEFINED } ) ) 
					oRecord:SetValue( "HLX_GRPCLI", oSeeker:oKey:GetKey( { UNDEFINED } ) ) 
					oRecord:SetValue( "HLX_REGIAO", oSeeker:oKey:GetKey( { UNDEFINED } ) ) 
				EndIf				
				
				If lFindACV
					oRecord:SetValue( "HLX_FAMCOM", oSeeker:Seek( "HG1", { ACV->ACV_CATEGO } ) ) 
				Else
					oRecord:SetValue( "HLX_FAMCOM", oSeeker:oKey:GetKey( { UNDEFINED } ) ) 
				EndIf
				
				
				oRecord:SetValue( "HLX_PLANEJ", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLX_GRPMAQ", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLX_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLX_LINHAP", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLX_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLX_MOBDIR", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				
				//-------------------------------------------------------------------
				// Atributos.
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HLX_PEDIDO", SC2->C2_PEDIDO ) // Número do Pedido
				oRecord:SetValue( "HLX_SEQCIA", SC2->C2_SEQUEN ) // Sequência da Ordem         
				oRecord:SetValue( "HLX_ORDEM ", cNumOP )         // Ordem de Produção

				//-------------------------------------------------------------------
				// Indicadores.
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HLX_DATA", SC2->C2_EMISSAO ) // Data de Término da Ordem 
                
				// Posiciona nos itens empenhados				                
				SD4->( MsSeek(xFilial("SD4") + cNumOP ))
				While SD4->(! EoF() ) .And. SD4->D4_FILIAL == xFilial("SD4") .And. SD4->D4_OP == cNumOp
					If !IsProdMod(SD4->D4_COD)   
						SD4->( dbSkip() )
						Loop
					EndIf 
					
					If SB1->( MsSeek( xFilial("SB1") + SD4->D4_COD ) ) .And. SB2->( MsSeek( xFilial("SB2") +  SD4->D4_COD + SB1->B1_LOCPAD ))
						nQHRMOP += SD4->D4_QUANT                              
						nVCSMOP += SD4->D4_QUANT * & ("SB2->B2_CM" + cMoeda ) 
					EndIf
					SD4->( dbSkip() )
				EndDo			   
				nVCSMOP += RetCostRoteiro(1, SC2->C2_PRODUTO, If(Empty(cOperPad), "01", cOperPad), cMoeda)[1]
				nQHRMOP += RetCostRoteiro(1, SC2->C2_PRODUTO, If(Empty(cOperPad), "01", cOperPad), cMoeda)[2]				

				oRecord:SetValue( "HLX_VCSMOP", nVCSMOP ) // Vl Custo MOB Padrão						
				oRecord:SetValue( "HLX_QHRMOP", nQHRMOP ) // Qtde Horas MOB Padrão

				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
			Next nMoeda
		EndIf			
		SC2->( dbSkip() )
	EndDo

	SC2->( DBClearFilter() ) // Remove filtro

	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
Return NIL
