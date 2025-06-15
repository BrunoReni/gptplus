#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXFOLHAPAG.CH"

REGISTER EXTRACTOR HLP

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXFolhaPag
Apresenta informações relacionadas aos cálculos da folha de pagamento 
dos colaboradores.

@author  BI TEAM
@since   31/08/2010
/*/
//-------------------------------------------------------------------
Class BIXFolhaPag from BIXEntity
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
Method New() Class BIXFolhaPag
	_Super:New( FACT, "HLP", STR0001, "SRA", { RH } ) //"Folha de Pagamento"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   28/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXFolhaPag
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLP_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLP_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLP_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HLP_SINDIC", "C", 32, 0, .T., "HJV" )
	oModel:AddField( "HLP_TURNO" , "C", 32, 0, .T., "HJU" )
	oModel:AddField( "HLP_EVENTO", "C", 32, 0, .T., "HJR" )
	oModel:AddField( "HLP_TIPMOB", "C", 32, 0, .T., "HJQ" )
	oModel:AddField( "HLP_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HLP_COLABR", "C", 32, 0, .T., "HJM" )
	oModel:AddField( "HLP_CARGO" , "C", 32, 0, .T., "HJP" )
	oModel:AddField( "HLP_NIVHIE", "C", 32, 0, .T., "HG5" )
	oModel:AddField( "HLP_FXASAL", "C", 32, 0, .T., "HKG" )
	oModel:AddField( "HLP_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HLP_CATSAL", "C", 32, 0, .T., "HJT" )
	oModel:AddField( "HLP_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HLP_ESTCIV", "C", 32, 0, .T., "HKE" )
	oModel:AddField( "HLP_FXAETA", "C", 32, 0, .T., "HK8" )
	oModel:AddField( "HLP_GRAINS", "C", 32, 0, .T., "HK9" )
	oModel:AddField( "HLP_TPCASA", "C", 32, 0, .T., "HKH" )
	oModel:AddField( "HLP_TPCARG", "C", 32, 0, .T., "HKI" )
	oModel:AddField( "HLP_RELTRB", "C", 32, 0, .T., "HKD" )
	oModel:AddField( "HLP_SITCLB", "C", 32, 0, .T., "HKA" )
	oModel:AddField( "HLP_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HLP_SECAO" , "C", 32, 0, .T., "HQ0" )
	oModel:AddField( "HLP_LOCALI", "C", 32, 0, .T., "HQO" )
	oModel:AddField( "HLP_PRESRV", "C", 32, 0, .T., "HQQ" )
	oModel:AddField( "HLP_PLOTAC", "C", 32, 0, .T., "HQP" )
	oModel:AddField( "HLP_ULOTAC", "C", 32, 0, .T., "HQT" )
	oModel:AddField( "HLP_DATA"  , "D",  8, 0, .F., "HK2" )
	oModel:AddField( "HLP_QDEPEN", "N", 4, 0 )
	oModel:AddField( "HLP_QCBCAL", "N", 4, 0 )
	oModel:AddField( "HLP_QCBNCA", "N", 4, 0 )
	oModel:AddField( "HLP_QHRPRV", "N", 16, 4 )	
	oModel:AddField( "HLP_QHREXT", "N", 16, 4 )	
	oModel:AddField( "HLP_QHRTRB", "N", 16, 4 )	
	oModel:AddField( "HLP_VDESFP", "N", 16, 2 )	
	oModel:AddField( "HLP_VHREXT", "N", 16, 2 )	
	oModel:AddField( "HLP_VHRTRB", "N", 16, 2 )	
	oModel:AddField( "HLP_VENCEM", "N", 16, 2 )	
	oModel:AddField( "HLP_VENCCB", "N", 16, 2 )	
	oModel:AddField( "HLP_VBENEM", "N", 16, 2 )	
	oModel:AddField( "HLP_VBENCB", "N", 16, 2 )	
	oModel:AddField( "HLP_VFLHPG", "N", 16, 2 )	
	oModel:AddField( "HLP_VEVESP", "N", 16, 2 )	

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXFolhaPag
	Local oRegion	:= NIL
	Local aMoedas   := {}
	Local aInterval		 := BIXInterval( cFrom, cTo ) 

	Local cMoeda		 := ""
	Local nInd      	 := 1           
	Local lRHR			 := AliasInDic("RHR")
	Local nI			 := 0
	Local nQHREXT 		 := 0
	Local nQHRTRB 		 := 0
	Local nVHREXT 		 := 0
	Local nVHRTRB 		 := 0
	Local nVENCEM		 := 0
	Local nVENCCB		 := 0
	Local nVFLHPG		 := 0
	Local nVDESFP		 := 0
	Local nVBENCB		 := 0
	Local nVBENEM		 := 0
	Local nQHRPRE		 := 0
	Local nQDEPEN		 := 0
	Local nQCBCAL		 := 0
	Local nQCBNCA		 := 0
	Local aPerA			 := {}
	Local aPerF			 := {}
	Local cCodFol148 	 := "" 
	Local cCodFol229 	 := "" 
	Local cCodFol943 	 := ""
	Local cCodFol973 	 := ""
	Local cCodFol064 	 := "" 
	Local cCodFol065 	 := ""
	Local cCodFol066 	 := ""
	Local cCodFol067 	 := ""
	Local cCodFol070 	 := ""
	Local cCodFol071 	 := ""
	Local cFXASAL		 := ""
	Local cFXAETA		 := ""
	Local cTPCASA		 := ""
	Local cTPCARG 		 := ""
	Local cRAMatAnterior := ""
	Local cSINDICA		 := ""
	Local cTNOTRAB		 := ""
	Local cCC		 	 := ""
	Local cCODFUNC		 := ""
	Local cCATFUNC		 := ""
	Local cESTCIVI		 := ""
	Local cGRINRAI		 := ""
	Local cTIPOADM		 := ""
	Local cSITFOLH		 := ""
	Local cDEPTO		 := ""
	Local cPD			 := ""
	Local lRHS			 := AliasInDic("RHS")
	Local lRHP 			 := AliasInDic("RHP")
	Local lRG2 			 := AliasInDic("RG2")
	Local lRIR 			 := AliasInDic("RIR")
	Local lTemFolha		 := .F.
	Local aFXSal 		 := {}
	Local aFxEta 		 := {}
	Local aTpCasa 		 := {}
	Local aTpCarg 		 := {}
	Local lFindSRJ 		 := .F.
	Local cRegiao		 := ""
	Local cFlow			 := ""
	
	aMoedas := BIXGetMxF(::cEntity)
	oRegion := BIXRegiao():New()
	
	if lRHR
		dbSelectArea("RHR")
		RHR->( dbSetOrder(1) )
	else
    	BIXSysOut('BIXFolhaPag', STR0002, WARNING) // "Tabela RHR não encontrada para extração da fato"
    endif	

	if lRHS
		dbSelectArea("RHS")
		RHS->( dbSetOrder(1) )
	else
    	BIXSysOut('BIXFolhaPag', I18n( STR0003, {"RHS"}) , WARNING) //"Tabela #1 não encontrada para extração da fato"     
    endif	

	if lRHP
		dbSelectArea("RHP")
		RHP->( dbSetOrder(1) )
	else
    	BIXSysOut('BIXFolhaPag', I18n( STR0003, {"RHP"}) , WARNING) //"Tabela #1 não encontrada para extração da fato"     
    endif	
	
	if lRG2
		dbSelectArea("RG2")
		RG2->( dbSetOrder(5) )
	else
    	BIXSysOut('BIXFolhaPag', I18n( STR0003, {"RG2"}) , WARNING) //"Tabela #1 não encontrada para extração da fato"     
	endif	
	
	if lRIR
		dbSelectArea("RIR")
		RIR->( dbSetOrder(1) )
	else
    	BIXSysOut('BIXFolhaPag', I18n( STR0003, {"RIR"}) , WARNING) //"Tabela #1 não encontrada para extração da fato"     
	endif	

	cCodFol148 := FGETCODFOL('0148') 
	cCodFol229 := FGETCODFOL('0229') 
	cCodFol943 := FGETCODFOL('0943')
	cCodFol973 := FGETCODFOL('0973')
	cCodFol064 := FGETCODFOL('0064') 
	cCodFol065 := FGETCODFOL('0065')
	cCodFol066 := FGETCODFOL('0066')
	cCodFol067 := FGETCODFOL('0067')
	cCodFol070 := FGETCODFOL('0070')
	cCodFol071 := FGETCODFOL('0071')
	
	aFXSal := aBIToken( BIXParInfo( "FXSALA", "C", "" ), ";", .F. )	
	aFXEta := aBIToken( BIXParInfo( "FXAETA", "C", "" ), ";", .F. )
	aTpCasa := aBIToken( BIXParInfo( "TPCASA", "C", "" ), ";", .F. )
	aTpCarg := aBIToken( BIXParInfo( "TPCARG", "C", "" ), ";", .F. )

	For nI := 1 to len(aInterval)
		aPerA	:= {}
		aPerF	:= {}
		nPos	:= 0
		
		//-------------------------------------------------------------------
		// Carrega os perídos abertos e fechados 
		//-------------------------------------------------------------------
		fRetPerComp( Month2Str(aInterval[nI][1]) , Year2Str(aInterval[nI][1]), , , , @aPerA, @aPerF )

		If ( nPos := Ascan( aPerF, {|x| x[8] == "FOL"}) ) > 0 
			cRAMatAnterior := ""
			
			//-------------------------------------------------------------------
			// Recupera o fluxo de dados da fato. 
			//------------------------------------------------------------------- 
			cFlow := ::Flow( aPerf[nPos][1] )

			While (cFlow)->(! EoF() )
				nQHREXT := 0
				nQHRTRB := 0
				nVHREXT := 0
				nVHRTRB := 0
				nVENCEM	:= 0
				nVENCCB	:= 0
				nVFLHPG	:= 0
				nVDESFP	:= 0
				nVBENCB	:= 0
				nVBENEM	:= 0
				nQHRPRE := 0
				nQDEPEN := 0
				nQCBCAL := 0
				nQCBNCA := 0
				lFindSRJ := .F.

				//-------------------------------------------------------------------
				// Preenchimento das dimensões
				//-------------------------------------------------------------------
				cSINDICA := (cFlow)->RA_SINDICA 	//Dimensão Sindicato
				cTNOTRAB := (cFlow)->RA_TNOTRAB 	//Dimensão Turno
				cCC 	 := (cFlow)->RA_CC 			//Dimensão Centro de Custo
				cCODFUNC := (cFlow)->RA_CODFUNC 	//Dimensão Cargo
				cCATFUNC := (cFlow)->RA_CATFUNC 	//Dimensão Categoria Salarial
				cESTCIVI := (cFlow)->RA_ESTCIVI 	//Dimensão Estado Civil
				cGRINRAI := (cFlow)->RA_GRINRAI 	//Dimensão Grau de Instrução
				cTIPOADM := (cFlow)->RA_TIPOADM 	//Dimensão Relação Trabalho
				cSITFOLH := (cFlow)->RA_SITFOLH 	//Dimensão Situação Colaborador
				cDEPTO 	 := (cFlow)->RA_DEPTO 		//Dimensão Seção
				cPD 	 := (cFlow)->RD_PD 			//Dimensão Enveto				
				cRegiao  := (cFlow)->RA_NATURAL		//Dimensão Região Geográfica
				cFXASAL  := BIXParGetFaixa( "FXSALA", (cFlow)->RA_SALARIO, @aFXSal )                                // Dimensão Faixa Salarial
				cFXAETA  := BIXParGetFaixa( "FXAETA", DateDiffYMD((cFlow)->RA_NASC, aInterval[nI][2])[1], @aFxEta )   // Dimensão Faixa Etária
				cTPCASA  := BIXParGetFaixa( "TPCASA", DateDiffYMD((cFlow)->RA_ADMISSA, aInterval[nI][2])[1], @aTpCasa ) // Dimensão Tempo Casa
				cTPCARG  := BIXParGetFaixa( "TPCARG", BIXRetTPCARG((cFlow)->RA_MAT, aInterval[nI][2]), @aTpCarg )      // Dimensão Tempo Cargo

				
				//-------------------------------------------------------------------
				// Dimensão Mão de Obra  
				//-------------------------------------------------------------------
				If SRJ->( MsSeek( xFilial("SRJ") + (cFlow)->RA_CODFUNC) ) .And. !Empty(SRJ->RJ_MAOBRA)
					lFindSRJ := .T.
				Endif				

				//-------------------------------------------------------------------
				// Transformação de indicadores  
				//-------------------------------------------------------------------
				If (cFlow)->RV_HE == 'S'          
					If (cFlow)->RD_TIPO1 == 'H' 
						nQHREXT := (cFlow)->RD_HORAS       // Qtde Horas Extras       
					ElseIf (cFlow)->RD_TIPO1 == 'D' 
						nQHREXT := ((cFlow)->RD_HORAS * 8) // Qtde Horas Extras
					EndIf
						
					nVHREXT := (cFlow)->RD_VALOR			// Vl Horas Extras
				ElseIf (cFlow)->RV_CODFOL == '0031' .Or. (cFlow)->RV_CODFOL == '0032' .Or. (cFlow)->RV_CODFOL == '0033'
					// Qtde Horas Trabalhadas 
					If (cFlow)->RD_TIPO1 == 'H' 
						nQHRTRB := (cFlow)->RD_HORAS
					ElseIf (cFlow)->RD_TIPO1 == 'D' 
						nQHRTRB := ((cFlow)->RD_HORAS * 8)
					EndIf
					    
					nVHRTRB := (cFlow)->RD_VALOR			// Vl Horas Trabalhadas
				EndIf
					
				// Vl Encargos Empresa
				If (cFlow)->RD_PD == cCodFol148 .Or. (cFlow)->RD_PD == cCodFol229 .Or. ;
					(cFlow)->RD_PD == cCodFol943 .Or. (cFlow)->RD_PD == cCodFol973
						nVENCEM := (cFlow)->RD_VALOR
						
				EndIf 
					
				// Vl Encargos Colaborador
				If	(cFlow)->RD_PD == cCodFol064 .Or. (cFlow)->RD_PD  == cCodFol065 .Or. ;
					(cFlow)->RD_PD == cCodFol066 .Or. (cFlow)->RD_PD == cCodFol067 .Or. ;
					(cFlow)->RD_PD == cCodFol070 .Or. (cFlow)->RD_PD == cCodFol071
					
					nVENCCB := (cFlow)->RD_VALOR
				EndIf
				
				// Vl Folha Pagamento
				If (cFlow)->RV_TIPOCOD == '1'
					nVFLHPG := (cFlow)->RD_VALOR 
				ElseIf (cFlow)->RV_TIPOCOD == '2'
					nVFLHPG :=  ((cFlow)->RD_VALOR * -1) 
				EndIf
				
				// Vl Desconto Folha Pagamento
				If (cFlow)->RV_TIPOCOD == '2'
					nVDESFP := (cFlow)->RD_VALOR 
				EndIf

				//-------------------------------------------------------------------
				// Indicadores de preenchimento único para cada colaborador  
				//-------------------------------------------------------------------
				If (cFlow)->RA_MAT <> cRAMatAnterior				
					nQDEPEN := Val((cFlow)->RA_DEPIR)     // Qtde Dependentes
					nQHRPRE := (cFlow)->RA_HRSMES         // Qtde Horas Previstas
				
					// Vl Beneficios 
					If nPos > 0
						//plano de saúde e plano odontológico
						If lRHS .and. RHS->( MsSeek( xFilial("RHS") + (cFlow)->RA_MAT + aPerF[nPos][1]) )
							While RHS->(!Eof()) .And. RHS->RHS_FILIAL == xFilial("RHS") .And. RHS->RHS_MAT == (cFlow)->RA_MAT .And. RHS->RHS_COMPPG == aPerF[nPos][1] 
								nVBENEM += RHS->RHS_VLREMP
								nVBENCB += RHS->RHS_VLRFUN
								
								RHS->( dbSkip() )
							End
						EndIf
							
						//Co-participação plano de saúde e co-participação plano odontologico
						If lRHP .and. RHP->( MsSeek( xFilial("RHP") + (cFlow)->RA_MAT) )
							While RHP->(!Eof()) .And. RHP->RHP_FILIAL == xFilial("RHP") .And. RHP->RHP_MAT == (cFlow)->RA_MAT
								IF RHP->RHP_COMPPG == aPerF[nPos][1]
									nVBENEM += RHP->RHP_VLREMP
									nVBENCB += RHP->RHP_VLRFUN
								EndIf
								RHP->( dbSkip() )
							End
						EndIf
		
						//Vale Transporte/Vale Refeição/Vale Alimentação
						If lRG2 .and. RG2->( MsSeek( xFilial("RG2") + (cFlow)->RA_MAT + aPerF[nPos][1] ) )
							While RG2->(!Eof()) .And. RG2->RG2_FILIAL == xFilial("RG2") .And. RG2->RG2_MAT == (cFlow)->RA_MAT .And. RG2->RG2_PERIOD == aPerF[nPos][1]
								nVBENEM += RG2->RG2_CUSEMP
								nVBENCB += RG2->RG2_CUSFUN
									
								RG2->( dbSkip() )
							End
						EndIf
		
						// Outros benefícios
						If lRIR .and. RIR->( MsSeek( xFilial("RIR") + (cFlow)->RA_MAT) )
							While RIR->(!Eof()) .And. RIR->RIR_FILIAL == xFilial("RIR") .And. RIR->RIR_MAT == (cFlow)->RA_MAT 
								IF RIR->RIR_PERIOD == aPerF[nPos][1]
									nVBENEM += RIR->RIR_VLREMP 
									nVBENCB += RIR->RIR_VLRFUN
								EndIf
								RIR->( dbSkip() )
							End
						EndIf
					EndIf
				EndIf				
				
				//-------------------------------------------------------------------
				// Verifica se houve movimento de folha de pagamento  
				//-------------------------------------------------------------------
				If !lTemFolha	
					lTemFolha := (nVFLHPG != 0 .OR. nVBENCB != 0 .OR. nVDESFP != 0 .OR. nVENCCB != 0 .OR. nVENCEM != 0;
						.OR. nVHREXT != 0 .OR. nVHRTRB != 0)	
				EndIf
				
				//-------------------------------------------------------------------
				// Posiciona no próximo registro para identificação do último registro
				// de cada colaboradorador
				//-------------------------------------------------------------------
				cRAMatAnterior := (cFlow)->RA_MAT
				(cFlow)->( dbSkip() )    
				
				If !(cRAMatAnterior == (cFlow)->RA_MAT)
					//-------------------------------------------------------------------
					// Indicadores de Qtd de Colaboradores Calculados e Não Calculados
					// são preenchidos somente no último registro para cada colaborador  
					//-------------------------------------------------------------------
					If lTemFolha
						nQCBCAL := 1
						nQCBNCA := 0
					Else
						nQCBCAL := 0
						nQCBNCA := 1
					Endif
					lTemFolha := .F.
				Else
					nQCBCAL := 0
					nQCBNCA := 0				
				EndIf     	
		
				//-------------------------------------------------------------------
				// Atribuição dos registros por moeda.
				// O colaborador ativo encontra-se em cRAMatAnterior 
				//-------------------------------------------------------------------			  		
				For nInd := 1 To Len(aMoedas)
					cMoeda := aMoedas[nInd][1]

					//-------------------------------------------------------------------
					// Inicializa o registro. 
					//------------------------------------------------------------------- 				
					oRecord:Init()
					
					//-------------------------------------------------------------------
					// Customização.
					//------------------------------------------------------------------- 
					oRecord:SetValue( "RA_MAT" , cRAMatAnterior )
					oRecord:SetValue( "RCE_CODIGO" , cSINDICA )
					oRecord:SetValue( "R6_TURNO"   , cTNOTRAB )
					oRecord:SetValue( "CTT_CUSTO"  , cCC ) 
					oRecord:SetValue( "RJ_FUNCAO"  , cCODFUNC )
					oRecord:SetValue( "QB_DEPTO"   , cDEPTO )
					oRecord:SetValue( "RV_COD"     , cPD )

					//-------------------------------------------------------------------
					// Lookups.
					//------------------------------------------------------------------- 
					oRecord:SetValue( "HLP_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
					oRecord:SetValue( "HLP_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
					oRecord:SetValue( "HLP_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
					oRecord:SetValue( "HLP_SINDIC", oSeeker:Seek( "HJV", { cSINDICA } ) ) 
					oRecord:SetValue( "HLP_TURNO" , oSeeker:Seek( "HJU", { cTNOTRAB } ) ) 
					oRecord:SetValue( "HLP_EVENTO", oSeeker:Seek( "HJR", { cPD } ) ) 
					oRecord:SetValue( "HLP_CCUSTO", oSeeker:Seek( "HJ5", { cCC } ) )
					oRecord:SetValue( "HLP_COLABR", oSeeker:Seek( "HJM", { cRAMatAnterior } ) ) 
					oRecord:SetValue( "HLP_CARGO" , oSeeker:Seek( "HJP", { cCODFUNC } ) ) 
					oRecord:SetValue( "HLP_FXASAL", oSeeker:Seek( "HKG", { cFXASAL } ) ) 
					oRecord:SetValue( "HLP_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
					oRecord:SetValue( "HLP_CATSAL", oSeeker:Seek( "HJT", { cCATFUNC } ) )
					oRecord:SetValue( "HLP_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( cRegiao ) } ) ) 
					oRecord:SetValue( "HLP_ESTCIV", oSeeker:Seek( "HKE", { cESTCIVI } ) ) 
					oRecord:SetValue( "HLP_FXAETA", oSeeker:Seek( "HK8", { cFXAETA } ) ) 
					oRecord:SetValue( "HLP_GRAINS", oSeeker:Seek( "HK9", { cGRINRAI } ) ) 
					oRecord:SetValue( "HLP_TPCASA", oSeeker:Seek( "HKH", { cTPCASA } ) ) 
					oRecord:SetValue( "HLP_TPCARG", oSeeker:Seek( "HKI", { cTPCARG } ) ) 
					oRecord:SetValue( "HLP_RELTRB", oSeeker:Seek( "HKD", { cTIPOADM } ) ) 
					oRecord:SetValue( "HLP_SITCLB", oSeeker:Seek( "HKA", { cSITFOLH } ) ) 
					oRecord:SetValue( "HLP_SECAO" , oSeeker:Seek( "HQ0", { cDEPTO } ) ) 
					oRecord:SetValue( "HLP_NIVHIE", oSeeker:oKey:GetKey( { UNDEFINED } ) )
					oRecord:SetValue( "HLP_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
					oRecord:SetValue( "HLP_LOCALI", oSeeker:oKey:GetKey( { UNDEFINED } ) )
					oRecord:SetValue( "HLP_PRESRV", oSeeker:oKey:GetKey( { UNDEFINED } ) )
					oRecord:SetValue( "HLP_PLOTAC", oSeeker:oKey:GetKey( { UNDEFINED } ) )
					oRecord:SetValue( "HLP_ULOTAC", oSeeker:oKey:GetKey( { UNDEFINED } ) )

					If lFindSRJ
						oRecord:SetValue( "HLP_TIPMOB", oSeeker:Seek( "HJQ", { SRJ->RJ_MAOBRA } ) )  
					Else
						oRecord:SetValue( "HLP_TIPMOB", oSeeker:oKey:GetKey( { UNDEFINED } ) )
					EndIf
					
					
					//-------------------------------------------------------------------
					// Indicadores.
					//------------------------------------------------------------------- 			
					oRecord:SetValue( "HLP_DATA"  , IIf( !Empty(aPerF[nPos][6]), aPerF[nPos][6], DATE_EMPTY ) ) // Data do Periodo Informado (Mês/Ano)
																						
					// Indicadores
					oRecord:SetValue( "HLP_QDEPEN", nQDEPEN )    										// Qtde Dependentes
					oRecord:SetValue( "HLP_QHRPRV", nQHRPRE )    										// Qtde Horas Previstas
					oRecord:SetValue( "HLP_VEVESP", 0 		)                                           // Vl Eventos Especiais
					oRecord:SetValue( "HLP_QHRTRB", nQHRTRB	)											// Qtde Horas Trabalhadas
					oRecord:SetValue( "HLP_QHREXT", nQHREXT	)											// Qtde Horas Extras
					oRecord:SetValue( "HLP_QCBCAL", nQCBCAL	)											// Qtde Colaboradores Calculados
					oRecord:SetValue( "HLP_QCBNCA", nQCBNCA	)											// Qtde Colaboradores não Calculados
					oRecord:SetValue( "HLP_VHRTRB", BIXValue(nVHRTRB, 1, cMoeda, aPerF[nPos][6] ) ) 	// Vl Horas Trabalhadas
					oRecord:SetValue( "HLP_VHREXT", BIXValue(nVHREXT, 1, cMoeda, aPerF[nPos][6] ) ) 	// Vl Horas Extras
					oRecord:SetValue( "HLP_VDESFP", BIXValue(nVDESFP, 1, cMoeda, aPerF[nPos][6] ) ) 	// Vl Desconto Folha Pagamento
					oRecord:SetValue( "HLP_VFLHPG", BIXValue(nVFLHPG, 1, cMoeda, aPerF[nPos][6] ) ) 	// Vl Folha Pagamento
					oRecord:SetValue( "HLP_VENCEM", BIXValue(nVENCEM, 1, cMoeda, aPerF[nPos][6] ) ) 	// Vl Encargos Empresa
					oRecord:SetValue( "HLP_VENCCB", BIXValue(nVENCCB, 1, cMoeda, aPerF[nPos][6] ) ) 	// Vl Encargos Colaborador
					oRecord:SetValue( "HLP_VBENCB", BIXValue(nVBENCB, 1, cMoeda, aPerF[nPos][6] ) )  // Vl Benefícios Colaborador
					oRecord:SetValue( "HLP_VBENEM", BIXValue(nVBENEM, 1, cMoeda, aPerF[nPos][6] ) )	// Vl Beneficios Empresa
				
					//-------------------------------------------------------------------
					// Envia o registro para o pool de gravação. 
					//-------------------------------------------------------------------				
					oOutput:Send( oRecord ) 
				Next nInd
			EndDo
			(cFlow)->(DbCloseArea())
		EndIf
	Next
	aSize(aMoedas, 0)
	aMoedas := Nil
	aSize(aInterval, 0)
	aInterval := Nil
	aSize(aPerF, 0)
	aPerF := Nil
	aSize(aPerA, 0)
	aPerA := Nil
	aSize(aFXSal, 0)
	aFXSal := Nil
	aSize(aFxEta, 0)
	aFxEta := Nil
	aSize(aTpCasa, 0)
	aTpCasa := Nil
	aSize(aTpCarg, 0)
	aTpCarg := Nil				

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
Method Flow( cPeriodo ) Class BIXFolhaPag
	Local cQuery 	:= ""

	cQuery := "SELECT RA_MAT, RA_SALARIO, RA_NASC, RA_ADMISSA, RA_CODFUNC, RA_HRSMES, " + ;
		"RA_DEPIR, RA_SINDICA, RA_TNOTRAB, RA_CC, RA_CODFUNC, RA_CATFUNC, RA_ESTCIVI, " + ;
		"RA_GRINRAI, RA_TIPOADM, RA_SITFOLH, RA_DEPTO, RA_NATURAL, SRA.R_E_C_N_O_ ID, " + ;
		"RD_PD, RD_TIPO1, RD_HORAS, RD_VALOR, RV_HE, RV_CODFOL, RV_TIPOCOD " + ;
		"FROM " + RetSQLName("SRA") + " SRA " + ;
		"LEFT JOIN (SELECT RD_PD, RD_TIPO1, RD_HORAS, RD_VALOR, RD_FILIAL, RD_MAT, " + ;
		"RD_PERIODO, SRD.D_E_L_E_T_,RV_HE, RV_CODFOL, RV_TIPOCOD " + ;
		"FROM " + RetSQLName("SRD") + " SRD " + ;
		"INNER JOIN " + RetSQLName("SRV") + " SRV " + ;
			"ON RV_FILIAL = '" + xFilial("SRV") + "' "+ ;
			"AND RV_COD = RD_PD AND " + ;
			"RV_TIPOCOD <> '3' AND " + ;
			"SRV.D_E_L_E_T_ = ' ') SUB " + ;
		"ON RD_FILIAL = '" + xFilial("SRD") + "' " + ;
			"AND RD_MAT = RA_MAT " + ;
			"AND RD_PERIODO = '" + cPeriodo + "' " + ;
			"AND SUB.D_E_L_E_T_ = ' ' " + ;
		"WHERE RA_FILIAL = '" + xFilial("SRA") + "' " + ;
			"AND SRA.D_E_L_E_T_ = ' ' " + ;
			"ORDER BY RA_FILIAL, RA_MAT"
	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cQuery := ChangeQuery( cQuery )
	
	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária. 
	//-------------------------------------------------------------------  	
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), ::cFlow := GetNextAlias(), .T., .T.) 
	
	//-------------------------------------------------------------------
	// Converte os campos do tipo data. 
	//-------------------------------------------------------------------  	
	TcSetField( ::cFlow, "RA_NASC"	, "D", 8, 0 ) 		
	TcSetField( ::cFlow, "RA_ADMISSA"	, "D", 8, 0 )
Return ::cFlow