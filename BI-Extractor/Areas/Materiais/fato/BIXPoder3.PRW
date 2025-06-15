#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPODER3.CH"

REGISTER EXTRACTOR HQZ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXPoder3
Classe do extrator para a tabela fato Estoque - Poder de Terceiro do Projeto Extrator TOTVS B.I.

@author  BI TEAM
@since   11/11/2010
@param aParam, parâmetros necessário à execução deste extrator
	aParam[1] -> empresa a ser utilizada
	aParam[2] -> filial a ser utilizada
	aParam[3] -> Pesquisa De
	aParam[4] -> Pesquisa Ate
/*/
//-------------------------------------------------------------------
Class BIXPoder3 from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   25/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXPoder3
	_Super:New( FACT, "HQZ", STR0001, "SB6", { MATERIAIS } ) // "Estoque - Poder Terceiro" 
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   25/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXPoder3
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HQZ_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HQZ_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HQZ_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HQZ_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HQZ_DEPOSI", "C", 32, 0, .T., "HJD" )
	oModel:AddField( "HQZ_TIPITM", "C", 32, 0, .T., "HGC" )
	oModel:AddField( "HQZ_ITEM"  , "C", 32, 0, .T., "HJ8" )
	oModel:AddField( "HQZ_GRPEST", "C", 32, 0, .T., "HG3" )
	oModel:AddField( "HQZ_FAMCOM", "C", 32, 0, .T., "HG1" )
	oModel:AddField( "HQZ_FAMMAT", "C", 32, 0, .T., "HG2" )
	oModel:AddField( "HQZ_TPODER", "C", 32, 0, .T., "HQX" )
	oModel:AddField( "HQZ_GRPCLI", "C", 32, 0, .T., "HJ0" )
	oModel:AddField( "HQZ_CLIENT", "C", 32, 0, .T., "HJ7" )
	oModel:AddField( "HQZ_GRPFOR", "C", 32, 0, .T., "HGE" )
	oModel:AddField( "HQZ_FORNEC", "C", 32, 0, .T., "HKJ" )
	oModel:AddField( "HQZ_TIPMOV", "C", 32, 0, .T., "HK6" )
	oModel:AddField( "HQZ_UNITEM", "C", 32, 0, .T., "HHW" )
	oModel:AddField( "HQZ_NUMDOC", "C", 40, 0 )		
	oModel:AddField( "HQZ_SERDOC", "C", 8, 0 )		
	oModel:AddField( "HQZ_DATA"  , "D", 8, 0 )		
	oModel:AddField( "HQZ_QTPODE", "N", 16, 4 )
	oModel:AddField( "HQZ_QDPODE", "N", 16, 4 )
	oModel:AddField( "HQZ_VLPODE", "N", 16, 2 )

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
@since   25/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXPoder3
	Local aAreaSB6   := {}
	Local aMoedas    := {}
	Local cMoeda     := ""   
	Local cMsg       := ""              
	Local cFilter    := ""  
	Local nInd       := 1 
	Local dDataDigit := CToD("//")
	
	Local cTipItm := ""
	Local cTPoder := ""
	Local cTipMov := ""
	
	aMoedas    := BIXGetMxF(::cEntity)  
	
	DbSelectArea("SB6")         // Saldo em Poder de Terceiros 
	SB6->( dbSetOrder(1) ) // B6_FILIAL + B6_PRODUTO + B6_CLIFOR + B6_LOJA + B6_IDENT    
	
	cFilter += " B6_FILIAL == '" + xFilial("SB6") + "' "	    
	cFilter += " .AND. DTOS(B6_EMISSAO) >= '" + cFrom + "' "
	cFilter += " .AND. DTOS(B6_EMISSAO) <= '" + cTo + "' "
	
	SB6->( DBSetFilter ( {|| &cFilter}, cFilter) )
	SB6->( dbGoTop() )
	
	DbSelectArea("SA1")         // Cliente
	SA1->( dbSetOrder(1) ) // A1_FILIAL + A1_COD + A1_LOJA
	
	DbSelectArea("SA2")         // Fornecedor
	SA2->( dbSetOrder(1) ) // A2_FILIAL + A2_COD + A2_LOJA
	
	DbSelectArea("ACV")         // Categoria X Grupo ou Produto
	ACV->( dbSetOrder(5) ) //// ACV_FILIAL + ACV_CODPRO + ACV_CATEGO 
	
	DbSelectArea("SB1")         // Descrição Genérica do Produto
	SB1->( dbSetOrder(1) ) // B1_FILIAL + B1_COD

	While SB6->(! EoF() ) 
		dDataDigit := CToD("//")
		cTipItm := ""
		cTPoder := ""
		cTipMov := ""
		
		ACV->(DbSeek( xFilial("ACV") + SB6->B6_PRODUTO ) )		

		// Dimensão Tipo Item
		If SB1->(DbSeek( xFilial("SB1") + SB6->B6_PRODUTO ) ) .And. SB1->B1_TIPO == "MP"
			oRecord:SetValue( "HQZ_FAMMAT", oSeeker:Seek( "HG2", { SB1->B1_TIPO } ) ) 
			cTipItm := "3"
		Else
			oRecord:SetValue( "HQZ_FAMMAT", oSeeker:Seek( "HG2", { SB6->B6_PRODUTO } ) ) 
			If SG1->( MsSeek( xFilial("SG1") + SB6->B6_PRODUTO ))
				cTipItm := "2" 			
			Else
				cTipItm := "1"
			EndIf 
		EndIf
		
		If SB6->B6_TIPO == "D"
			oRecord:SetValue( "HQZ_TPODER", "1" ) 
		ElseIf SB6->B6_TIPO == "E"
			oRecord:SetValue( "HQZ_TPODER", "2" ) 
		EndIf	  		
		
		// Dimensão Tipo Movimento                   
		Do Case
			Case SB6->B6_TIPO == "D" .And. SB6->B6_PODER3 == "R"                       
				cTipMov  := "3"
			Case SB6->B6_TIPO == "D" .And. SB6->B6_PODER3 == "D"
				cTipMov  := "2"
			Case SB6->B6_TIPO == "E" .And. SB6->B6_PODER3 == "R"
				cTipMov  := "3"
			Case SB6->B6_TIPO == "E" .And. SB6->B6_PODER3 == "D"
				cTipMov  := "2"     
		EndCase
				
		If SB6->B6_TPCF == "C"  
		   	If SA1->(DbSeek( xFilial("SA1") + SB6->B6_CLIFOR + SB6->B6_LOJA ) ) 
				oRecord:SetValue( "HQZ_CLIENT", oSeeker:Seek( "HJ7", { SB6->B6_CLIFOR, SB6->B6_LOJA } ) ) 
				oRecord:SetValue( "HQZ_GRPCLI", oSeeker:Seek( "HJ0", { SA1->A1_TIPO } ) ) 
			Else
				oRecord:SetValue( "HQZ_GRPCLI", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			EndIf			
		Else 
			If SA2->(DbSeek( xFilial("SA2") + SB6->B6_CLIFOR + SB6->B6_LOJA ) )
				oRecord:SetValue( "HQZ_FORNEC", oSeeker:Seek( "HKJ", { SB6->B6_CLIFOR, SB6->B6_LOJA } ) ) 
				oRecord:SetValue( "HQZ_GRPFOR", oSeeker:Seek( "HGE", { SA2->A2_GRUPO } ) ) 
			Else
				oRecord:SetValue( "HQZ_GRPFOR",  oSeeker:oKey:GetKey( { UNDEFINED } ) )
			EndIf
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
			oRecord:SetValue( "A2_COD" 		, SB6->B6_CLIFOR )
			oRecord:SetValue( "A2_LOJA"		, SB6->B6_LOJA )
			oRecord:SetValue( "A1_COD" 		, SB6->B6_CLIFOR )
			oRecord:SetValue( "A1_LOJA"		, SB6->B6_LOJA )
			oRecord:SetValue( "ACU_COD"		, ACV->ACV_CATEGO )
			oRecord:SetValue( "B1_COD" 		, SB6->B6_PRODUTO )
			oRecord:SetValue( "BM_GRUPO" 	, SB1->B1_GRUPO )
			oRecord:SetValue( "AH_UNIMED"	, SB6->B6_UM )
			
			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HQZ_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HQZ_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HQZ_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) ) 	
			oRecord:SetValue( "HQZ_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
			oRecord:SetValue( "HQZ_DEPOSI", oSeeker:Seek( "HJD", { SB6->B6_LOCAL } ) ) 
			oRecord:SetValue( "HQZ_TIPITM", oSeeker:Seek( "HGC", { cTipItm } ) ) 
			oRecord:SetValue( "HQZ_ITEM"  , oSeeker:Seek( "HJ8", { SB6->B6_PRODUTO } ) ) 
			oRecord:SetValue( "HQZ_GRPEST", oSeeker:Seek( "HG3", { SB1->B1_GRUPO } ) ) 
			oRecord:SetValue( "HQZ_FAMCOM", oSeeker:Seek( "HG1", { ACV->ACV_CATEGO } ) ) 
			oRecord:SetValue( "HQZ_TPODER", oSeeker:Seek( "HQX", { cTPoder } ) ) 
			oRecord:SetValue( "HQZ_TIPMOV", oSeeker:Seek( "HK6", { cTipMov } ) ) 
			oRecord:SetValue( "HQZ_UNITEM", oSeeker:Seek( "HHW", { SB6->B6_UM } ) ) 
			oRecord:SetValue( "HQZ_FAMMAT", oSeeker:Seek( "HG2", { SB1->B1_TIPO } ) )
			oRecord:SetValue( "HQZ_GRPCLI", oSeeker:Seek( "HJ0", { SA1->A1_TIPO } ) )
			oRecord:SetValue( "HQZ_CLIENT", oSeeker:Seek( "HJ7", { SB6->B6_CLIFOR, SB6->B6_LOJA } ) )
			oRecord:SetValue( "HQZ_GRPFOR", oSeeker:Seek( "HGE", { SA2->A2_GRUPO } ) ) 
			oRecord:SetValue( "HQZ_FORNEC", oSeeker:Seek( "HKJ", { SB6->B6_CLIFOR, SB6->B6_LOJA } ) )

			//-------------------------------------------------------------------
			// Atributos.
			//-------------------------------------------------------------------
			oRecord:SetValue( "HQZ_DATA", IIf(!Empty(SB6->B6_DTDIGIT),SB6->B6_DTDIGIT,DATE_EMPTY) )   // Data do Movimento do Estoque      
			oRecord:SetValue( "HQZ_NUMDOC", SB6->B6_IDENT )   // Número do Documento 
			oRecord:SetValue( "HQZ_SERDOC", " " )        // Série do Documento
						
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HQZ_QTPODE", SB6->B6_QUANT )     // Qtde. Poder
			oRecord:SetValue( "HQZ_VLPODE", BIXValue( SB6->B6_CUSTO1  , 1 , cMoeda, SB6->B6_DTDIGIT ) ) // Vl Custo Unitário   
			
			// Tempo Poder  
			If SB6->B6_TIPO == "E"
				If (SB6->B6_TIPO == "D" .And. SB6->B6_PODER3 == "R") .OR. ;
				   (SB6->B6_TIPO == "E" .And. SB6->B6_PODER3 == "R")
				   oRecord:SetValue( "HQZ_QDPODE", 0 )
				Else
					dDataDigit := SB6->B6_DTDIGIT
					aAreaSB6 := SB6->(GetArea())
					
					SB6->(DbSetOrder(3)) 
					If SB6->( dbSeek( xFilial("SB6") + SB6->B6_IDENT + SB6->B6_PRODUTO + "D" ))
						oRecord:SetValue( "HQZ_QDPODE", SB6->B6_DTDIGIT - dDataDigit )
					EndIf   
					
					RestArea(aAreaSB6)
				EndIf
			Else
				If (SB6->B6_TIPO == "D" .And. SB6->B6_PODER3 == "D") .OR. ;
				   (SB6->B6_TIPO == "E" .And. SB6->B6_PODER3 == "D")
				   oRecord:SetValue( "HQZ_QDPODE", 0 )
				Else
					dDataDigit := SB6->B6_DTDIGIT
					aAreaSB6 := SB6->(GetArea())
					
					SB6->(DbSetOrder(3)) 
					If SB6->( dbSeek( xFilial("SB6") + SB6->B6_IDENT + SB6->B6_PRODUTO + "R" ))
						oRecord:SetValue( "HQZ_QDPODE", SB6->B6_DTDIGIT - dDataDigit )
					EndIf   
					
					RestArea(aAreaSB6)
				EndIf
			EndIf
		
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nInd
		SB6->( dbSkip() )               
	EndDo         

	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()	
	
	SB6->( DBClearFilter() ) 
Return nil
