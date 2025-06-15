#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPREVPRODUCAO.CH"

REGISTER EXTRACTOR HLU

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPrevProducao
Classe do extrator para a tabela fato Produção - Prevista Extrator TOTVS B.I.

@author  BI TEAM
@since   23/09/2010
/*/
//-------------------------------------------------------------------
Class BIXPrevProducao from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   28/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXPrevProducao
	_Super:New( FACT, "HLU", STR0001, "SC2", { PRODUCAO } ) //"Produção - Prevista"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   28/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXPrevProducao
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLU_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLU_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLU_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HLU_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HLU_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HLU_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HLU_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HLU_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HLU_PLANEJ", "C", 32, 0, .T., "HJX" )
	oModel:AddField( "HLU_DEPOSI", "C", 32, 0, .T., "HJD" )
	oModel:AddField( "HLU_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HLU_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HLU_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HLU_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HLU_LINHAP", "C", 32, 0, .T., "HGG" )
	oModel:AddField( "HLU_TIPPRD", "C", 32, 0, .T., "HQU" )
	oModel:AddField( "HLU_REFER" , "C", 32, 0, .T., "HJH" )
	oModel:AddField( "HLU_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HLU_DATA"  , "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HLU_ORDEM" , "C", 13, 0 )		
	oModel:AddField( "HLU_PEDIDO", "C", 12, 0 )		
	oModel:AddField( "HLU_PRIORI", "C", 10, 0 )		
	oModel:AddField( "HLU_SEQCIA", "C", 10, 0 )		
	oModel:AddField( "HLU_QPROGR", "N", 16, 4 )
	oModel:AddField( "HLU_QPGFMT", "N", 16, 4 )
	oModel:AddField( "HLU_QPGFCM", "N", 16, 4 )
	oModel:AddField( "HLU_VGGFPG", "N", 16, 2 )
	oModel:AddField( "HLU_VPROGR", "N", 16, 2 )
	oModel:AddField( "HLU_VMATPG", "N", 16, 2 )
	oModel:AddField( "HLU_VMOBPG", "N", 16, 2 )
	oModel:AddField( "HLU_QORDPG", "N", 16, 4 )

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXPrevProducao
	Local oRegion	 := NIL
	Local aMoedas  := {}
	Local lFindACV := .F.
	Local lFindSA1 := .F.
	Local lFindSC2 := .F.
	Local cTipITM  := ""
	Local nVMOBPG  := 0 
	Local nVMATPG  := 0
	
	Local cLocPad  := ""
	Local cOperPad := ""
	Local cMoeda   := ""
	Local cFilter  := ""                    
	Local cCodOrd  := ""
	Local nMoeda   := 1
	Local cFlow    := ""

	aMoedas := BIXGetMxF(::cEntity)
	oRegion := BIXRegiao():New()

	DbSelectArea("SC2")
	SC2->( dbSetOrder(1) )

	cFilter := " C2_FILIAL == '" + xFilial("SC2") + "' "
	cFilter += " .AND. DTOS(C2_EMISSAO) >= '" + cFrom + "' "
	cFilter += " .AND. DTOS(C2_EMISSAO) <= '" + cTo + "' "
	cFilter += " .AND. C2_QUANT > 0"
	cFilter += " .AND. C2_QUJE = 0"
	
	SC2->( DBSetFilter ( {|| &cFilter}, cFilter) )
	SC2->( dbGoTop() )
	
	DbSelectArea("SC5")
	SC5->( dbSetOrder(1) ) // Filial + C5_NUM
    
	DbSelectArea("SB1")
	SB1->( dbSetOrder(1) ) // Filial + B1_COD

	DbSelectArea("ACV")
	ACV->( dbSetOrder(5) ) // Filial + ACV_CODPRO + ACV_CATEGO

	DbSelectArea("SG1")
	SG1->( dbSetOrder(1) ) // Filial + G1_COD + G1_COMP + G1_TRT
	
	DbSelectArea("SD4")
	SD4->( dbSetOrder(2) )

	While SC2->(! Eof() )         
		If SB1->( dbSeek( xFilial("SB1") + SC2->C2_PRODUTO ) )
			cCodOrd := SC2->( C2_NUM + C2_ITEM + C2_SEQUEN + C2_ITEMGRD )  

			lFindACV := .F.
			lFindSA1 := .F.
			lFindSC2 := .F.
			cTipITM  := ""
			nVMOBPG := 0 
			nVMATPG := 0
			
			//-------------------------------------------------------------------
			// Verifica a integridade referencial das dimensões.  
			//------------------------------------------------------------------- 
			If ACV->( MsSeek( xFilial("ACV") + SC2->C2_PRODUTO ) ) 
				lFindACV := .T.
			Endif
			
           	If SC5->( MsSeek( xFilial("SC5") + SC2->C2_PEDIDO ) )
          		If SA1->( MsSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI ))
					lFindSA1 := .T.
				EndIf
			EndIf 

			If !Empty(SC2->C2_LOCAL)
				lFindSC2 := .T.
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

			If !Empty(SC2->C2_ROTEIRO)
				cOperPad := SC2->C2_ROTEIRO
			Else
				cOperPad := SB1->B1_OPERPAD
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
				oRecord:SetValue( "C2_NUM"     , SC2->C2_NUM )
				oRecord:SetValue( "C2_ITEM"    , SC2->C2_ITEM )
				oRecord:SetValue( "C2_SEQUEN"  , SC2->C2_SEQUEN )
				
				oRecord:SetValue( "ACU_COD"    , ACV->ACV_CATEGO )			
				oRecord:SetValue( "A1_COD"     , SC5->C5_CLIENTE )
				oRecord:SetValue( "A1_LOJA"    , SC5->C5_LOJACLI )
				oRecord:SetValue( "B1_COD"     , SC2->C2_PRODUTO )
				oRecord:SetValue( "BM_GRUPO"   , SB1->B1_GRUPO )
				oRecord:SetValue( "AH_UNIMED"  , SC2->C2_UM )

				//-------------------------------------------------------------------
				// Lookups.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "HLU_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
				oRecord:SetValue( "HLU_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
				oRecord:SetValue( "HLU_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HLU_ITEM"  , oSeeker:Seek( "HJ8", { SC2->C2_PRODUTO } ) ) 
				oRecord:SetValue( "HLU_FAMMAT", oSeeker:Seek( "HG2", { SB1->B1_TIPO } ) ) 
				oRecord:SetValue( "HLU_GRPEST", oSeeker:Seek( "HG3", { SB1->B1_GRUPO } ) ) 
				oRecord:SetValue( "HLU_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nMoeda][2] } ) ) 
				oRecord:SetValue( "HLU_TIPITM", oSeeker:Seek( "HGC", { cTipITM } ) ) 
				oRecord:SetValue( "HLU_TIPPRD", oSeeker:Seek( "HQU", { SC2->C2_TPOP } ) ) 
				oRecord:SetValue( "HLU_UNITEM", oSeeker:Seek( "HHW", { SC2->C2_UM } ) ) 
				oRecord:SetValue( "HLU_PLANEJ", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HLU_REFER" , oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				oRecord:SetValue( "HLU_LINHAP", oSeeker:oKey:GetKey( { UNDEFINED } ) )	

				If lFindACV
					oRecord:SetValue( "HLU_FAMCOM", oSeeker:Seek( "HG1", { ACV->ACV_CATEGO } ) ) 
				Else
					oRecord:SetValue( "HLU_FAMCOM", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				EndIf
				
				If lFindSC2
					oRecord:SetValue( "HLU_DEPOSI", oSeeker:Seek( "HJD", { SC2->C2_LOCAL } ) )
				Else
					oRecord:SetValue( "HLU_DEPOSI", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				EndIf
				
				If lFindSA1
					oRecord:SetValue( "HLU_GRPCLI", oSeeker:Seek( "HJ0", { SA1->A1_TIPO } ) )
					oRecord:SetValue( "HLU_CLIENT", oSeeker:Seek( "HJ7", { SC5->C5_CLIENTE, SC5->C5_LOJACLI} ) )
					oRecord:SetValue( "HLU_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( SA1->A1_EST, SA1->A1_COD_MUN, SA1->A1_PAIS ) } ) ) 
				Else
					oRecord:SetValue( "HLU_GRPCLI", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
					oRecord:SetValue( "HLU_CLIENT", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
					oRecord:SetValue( "HLU_REGIAO", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				EndIf
				
				//-------------------------------------------------------------------
				// Atributos.
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HLU_DATA"  , SC2->C2_DATPRF ) // Dimensão Período (Data de Termino da Ordem)
				oRecord:SetValue( "HLU_PRIORI", SC2->C2_PRIOR  ) // Dimensão Prioridade da Ordem
				oRecord:SetValue( "HLU_SEQCIA", SC2->C2_SEQUEN ) // Dimensão Sequência da Ordem
				oRecord:SetValue( "HLU_PEDIDO", SC2->C2_PEDIDO ) // Dimensão Número do Pedido 
				oRecord:SetValue( "HLU_ORDEM ", cCodOrd )       // Numero da Ordem

				//-------------------------------------------------------------------
				// Indicadores.
				//------------------------------------------------------------------- 			
				If SD4->( MsSeek(xFilial("SD4") + cCodOrd) )
					While SD4->( !Eof() ) .And. SD4->D4_OP == cCodOrd
						cLocPad  := Posicione("SB1", 1, xFilial("SB1") + SD4->D4_COD, "B1_LOCPAD")
					
						SB2->( dbSetOrder(1) )
						If SB2->( MsSeek( xFilial("SB2") + SD4->D4_COD + cLocPad))
							If IsProdMod(SD4->D4_COD)
								nVMOBPG += (SD4->D4_QUANT * &("SB2->B2_CM" + cMoeda))
							Else
								nVMATPG += (SD4->D4_QUANT * &("SB2->B2_CM" + cMoeda))
							EndIf
						EndIf
						SD4->(dbSkip())
					EndDo
				EndIf
                
				nVMOBPG += RetCostRoteiro(1, SC2->C2_PRODUTO, If(Empty(cOperPad), "01", cOperPad), cMoeda)[1]
				
				oRecord:SetValue( "HLU_VMOBPG", nVMOBPG )
				oRecord:SetValue( "HLU_VMATPG", nVMATPG )
				oRecord:SetValue( "HLU_QORDPG", 1       )       // Qtde Ordem Programada
				oRecord:SetValue( "HLU_QPROGR", SC2->C2_QUANT ) // Qtde Programada
				oRecord:SetValue( "HLU_VPROGR", nVMOBPG + nVMATPG )
				oRecord:SetValue( "HLU_QPGFMT", 0 )     // Qtde Programada Familia Material
				oRecord:SetValue( "HLU_QPGFCM", 0 )     // Qtde Programada Familia Comercial
				oRecord:SetValue( "HLU_VGGFPG", 0 )     // Vl GGF Programado
				oRecord:SetValue( "HLU_QORDPG", 0 )     // Qtde Ordem Programada

				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
			Next nMoeda
		EndIf
		SC2->( dbSkip() )
	EndDo 
	
	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()
	
	SC2->( DBClearFilter() ) // Remove filtro
Return NIL