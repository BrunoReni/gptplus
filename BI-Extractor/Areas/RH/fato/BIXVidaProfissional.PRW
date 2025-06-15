#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXVIDAPROFISSIONAL.CH"

REGISTER EXTRACTOR HLQ

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXVidaProfissional
Apresenta informações relacionadas a vida profissional dos colaboradores.

@author  BI TEAM
@since   31/08/2010
@param aParam, parâmetros necessário à execução deste extrator
	aParam[1] -> empresa a ser utilizada
	aParam[2] -> filial a ser utilizada
	aParam[3] -> Pesquisa De
	aParam[4] -> Pesquisa Ate
/*/
//-------------------------------------------------------------------
Class BIXVidaProfissional from BIXEntity
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
@since   29/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXVidaProfissional
	_Super:New( FACT, "HLQ", STR0001, "SRA", { RH } ) //"Vida Profissional"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   29/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXVidaProfissional
	Local oModel := BIXModel():Build( Self )

	//-------------------------------------------------------------------
	// Converte o período de extração informado para o primeio dia do mês 
	// da data inicial até o último dia do mês da data final. 
	//-------------------------------------------------------------------	
	oModel:SetPeriod ( PERIOD_MONTH_FINAL )
	
	oModel:AddField( "HLQ_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLQ_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HLQ_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLQ_TIPMOB", "C", 32, 0, .T., "HJQ" )
	oModel:AddField( "HLQ_MOTMOV", "C", 32, 0, .T., "HJS" )
	oModel:AddField( "HLQ_TIPMOT", "C", 32, 0, .T., "HG7" )
	oModel:AddField( "HLQ_MOEDA" , "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HLQ_CATSAL", "C", 32, 0, .T., "HJT" )
	oModel:AddField( "HLQ_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HLQ_TURNO" , "C", 32, 0, .T., "HJU" )
	oModel:AddField( "HLQ_FXASAL", "C", 32, 0, .T., "HKG" )
	oModel:AddField( "HLQ_SINDIC", "C", 32, 0, .T., "HJV" )
	oModel:AddField( "HLQ_SITCLB", "C", 32, 0, .T., "HKA" )
	oModel:AddField( "HLQ_COLABR", "C", 32, 0, .T., "HJM" )
	oModel:AddField( "HLQ_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HLQ_CARGO" , "C", 32, 0, .T., "HJP" )
	oModel:AddField( "HLQ_NIVHIE", "C", 32, 0, .T., "HG5" )
	oModel:AddField( "HLQ_ESTCIV", "C", 32, 0, .T., "HKE" )
	oModel:AddField( "HLQ_FXAETA", "C", 32, 0, .T., "HK8" )
	oModel:AddField( "HLQ_GRAINS", "C", 32, 0, .T., "HK9" )
	oModel:AddField( "HLQ_TPCASA", "C", 32, 0, .T., "HKH" )
	oModel:AddField( "HLQ_TPCARG", "C", 32, 0, .T., "HKI" )
	oModel:AddField( "HLQ_RELTRB", "C", 32, 0, .T., "HKD" )
	oModel:AddField( "HLQ_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HLQ_SECAO" , "C", 32, 0, .T., "HQ0" )
	oModel:AddField( "HLQ_PRESRV", "C", 32, 0, .T., "HQQ" )
	oModel:AddField( "HLQ_PLOTAC", "C", 32, 0, .T., "HQP" )
	oModel:AddField( "HLQ_ULOTAC", "C", 32, 0, .T., "HQT" )
	oModel:AddField( "HLQ_LOCALI", "C", 32, 0, .T., "HQO" )
	oModel:AddField( "HLQ_DATA"  , "D", 8, 0, .F., "HK2" )		
	oModel:AddField( "HLQ_QCOLAB", "N", 4, 0 )
	oModel:AddField( "HLQ_QCBDEM", "N", 4, 0 )
	oModel:AddField( "HLQ_QCBADM", "N", 4, 0 )
	oModel:AddField( "HLQ_QPROMO", "N", 4, 0 )
	oModel:AddField( "HLQ_QRELOQ", "N", 4, 0 )
	oModel:AddField( "HLQ_QTRANS", "N", 4, 0 )
	oModel:AddField( "HLQ_QDEPEN", "N", 4, 0 )
	oModel:AddField( "HLQ_QAMSAL", "N", 4, 0 )
	oModel:AddField( "HLQ_QTRANL", "N", 4, 0 )
	oModel:AddField( "HLQ_QHRPRV", "N", 16, 4 )	
	oModel:AddField( "HLQ_ABSENT", "N", 16, 4 )	
	oModel:AddField( "HLQ_QHRAFT", "N", 16, 4 )	
	oModel:AddField( "HLQ_VCBDEM", "N", 16, 2 )	
	oModel:AddField( "HLQ_VCLDEM", "N", 16, 2 )	
	oModel:AddField( "HLQ_QDFAVC", "N", 16, 2 )	
	oModel:AddField( "HLQ_QDFVCD", "N", 16, 2 )	
	oModel:AddField( "HLQ_QDFERI", "N", 16, 2 )	
	oModel:AddField( "HLQ_VAMSAL", "N", 16, 2 )	
	oModel:AddField( "HLQ_VLABST", "N", 16, 2 )	
	
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
@since   29/05/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXVidaProfissional
	Local oRegion	:= NIL
	Local aMoedas := {}
	
	Local prevAlias  	:= GetArea()
	Local cMoeda     	:= ""
	Local cMsg       	:= ""
	Local cCargo     	:= ""
	Local cFuncao    	:= ""
	Local cMesAtu    	:= Month2STR(StoD(cFrom))
	Local dDataAlt   	:= Stod("//") 
	Local nInd       	:= 1
	Local nSalAtu    	:= 0
	Local nValHrs    	:= 0
	Local lPromo     	:= .F.
	Local aPerA			:= {}
	Local aPerF			:= {}
	Local nPos 			:= 0
	Local cCod318 		:= FGetCodFol("0318")
	Local nDCalcM	 	:= 0
	Local aFXSal 	  	:= {}	
	Local aFXEta 	  	:= {}
	Local aTpCasa 	  	:= {}
	Local aTpCarg 	  	:= {}
	Local lDemis	  	:= .F.
	Local lRecebDemis	:= .F.	
	Local cFlow			:= ""
	Local nVamSal 		:= 0
	Local nQDepen := 0
	Local lQamSal := .F.
	Local lQReloq := .F.
	Local nQDFERI := 0
	Local nQDFAVC := 0
	Local nQDFVCD := 0
	Local nQHRAFT := 0
	Local nABSENT := 0
	Local nVCBDEM := 0
	Local nVCLDEM := 0

	Private cAuxAlias 	:= getNextAlias()
	
	aMoedas := BIXGetMxF(::cEntity )
	oRegion	:= BIXRegiao():New()

	DbSelectArea("SR3")         // Historico Valores Salariais
	SR3->( dbSetOrder(1) ) // R3_FILIAL + R3_MAT + DTOS(R3_DATA) + R3_TIPO + R3_PD
	
	DbSelectArea("SR7")         // Historico Alteracoes Salariais
	SR7->( dbSetOrder(1) ) // R7_FILIAL + R7_MAT + DTOS(R7_DATA) + R7_TIPO
	
	DbSelectArea("SRF")         // Programacao de Férias
	SRF->( dbSetOrder(1) ) // RF_FILIAL + RF_MAT + DTOS(RF_DATABAS) + RF_PD
	
	DbSelectArea("SRR")         // Itens de Férias e Rescis§es
	SRR->( dbSetOrder(9) ) // RR_FILIAL+RR_MAT+RR_TIPO3+RR_PERIODO+RR_ROTEIR+RR_SEMANA+RR_PD+RR_CC+RR_ITEM+RR_CLVL+RR_SEQ+DTOS(RR_DATA)
    
	DbSelectArea("SRV")         // Verbas	
	SRV->( dbSetOrder(1) ) // RV_FILIAL + RV_COD
	
	DbSelectArea("SRB")         // Dependentes	
	SRB->( dbSetOrder(1) ) // RB_FILIAL + RB_MAT
	
	DbSelectArea("SR8")         // Controle de Ausencias
	SR8->( dbSetOrder(3) ) //R8_FILIAL+R8_MAT+R8_PER+R8_NUMPAGO
	                                                                                                                           
	DbSelectArea("SRJ")         // Funções
	SRJ->( dbSetOrder(1) ) // RJ_FILIAL + RJ_FUNCAO
	
	DbSelectArea("SRD")
	SRD->( dbSetOrder(1) )
	
	aFXSal := aBIToken( BIXParInfo( "FXSALA", "C", "" ), ";", .F. )	
	aFXEta := aBIToken( BIXParInfo( "FXAETA", "C", "" ), ";", .F. )
	aTpCasa := aBIToken( BIXParInfo( "TPCASA", "C", "" ), ";", .F. )
	aTpCarg := aBIToken( BIXParInfo( "TPCARG", "C", "" ), ";", .F. )	

	//-------------------------------------------------------------------
	// Carrega os perídos abertos e fechados 
	//-------------------------------------------------------------------
	fRetPerComp( Subs(cFrom, 5, 2), Subs(cTo, 1, 4), , , , @aPerA, @aPerF ) 

	//-------------------------------------------------------------------
	// Recupera o fluxo de dados da fato. 
	//------------------------------------------------------------------- 
	cFlow := ::Flow( cFrom, cTo )
	
	While (cFlow)->(! EoF() ) 
		nPos := 0
		nDCalcM := 0

		//Verifica se o colaborador foi demitido no período
		lDemis := .F.
		If (cFlow)->RA_DEMISSA >= stod(cFrom) .And. (cFlow)->RA_DEMISSA <= stod(cTo)
	    	BIXSubFlow( cAuxAlias, (cFlow)->RA_MAT, cFrom, cTo )
	    	//Verifica se a demissão acusada é por causa de transferência, se sim, não considera o colaborador na extração
	    	If (cAuxAlias)->(! Eof() )
	    		(cAuxAlias)->(DbCloseArea())
				(cFlow)->(dBSkip())
				Loop
			Else
				(cAuxAlias)->(DbCloseArea())
				lDemis := .T.
			Endif	    
	    EndIf

		//Verifica se o colaborador foi transferido
		If ( RIGHT((cFlow)->RA_TIPOADM, 1) == "C"  )
	    	BIXSubFlow( cAuxAlias, (cFlow)->RA_MAT, cTo, '', .T. ) //DataAte será o início da busca, assumindo papel de DataDe
	    	//Verifica se o colaborador não veio para a filial de extração somente após a data de ref. da extração
	    	If (cAuxAlias)->(! Eof() )
	    		(cAuxAlias)->(DbCloseArea())
				(cFlow)->(dBSkip()) //Não será considerado por não fazer parte da filial na data
				Loop
			Else
				(cAuxAlias)->(DbCloseArea())
			Endif	    
	    EndIf		
		
		For nInd := 1 To Len(aMoedas)
			cMoeda  := aMoedas[nInd][1]
			
			nSalAtu  := 0   // Controle para comparação do histórico salarial
			nValHrs  := 0
			lPromo   := .F. // Indica True caso tenha havido alteração de cargo/função e salario na mesma data
			dDataAlt := Stod("//") 
			nVamSal := 0
			nVCBDEM := 0
			nVCLDEM := 0
			nQDepen := 0
			nQDFERI := 0
			nQDFAVC := 0
			nQDFVCD := 0
			nQHRAFT := 0
			nABSENT := 0
			lQamSal := .F.
			lQReloq := .F.
			

			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "RA_MAT"  , (cFlow)->RA_MAT )
			oRecord:SetValue( "CTT_CUSTO"  , (cFlow)->RA_CC )
			oRecord:SetValue( "R6_TURNO"   , (cFlow)->RA_TNOTRAB )
			oRecord:SetValue( "RCE_CODIGO" , (cFlow)->RA_SINDICA )
			oRecord:SetValue( "RJ_FUNCAO"  , (cFlow)->RA_CODFUNC )
			oRecord:SetValue( "QB_DEPTO"   , (cFlow)->RA_DEPTO )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HLQ_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HLQ_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
			oRecord:SetValue( "HLQ_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HLQ_MOEDA" , oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
			oRecord:SetValue( "HLQ_CATSAL", oSeeker:Seek( "HJT", { (cFlow)->RA_CATFUNC } ) )
			oRecord:SetValue( "HLQ_CCUSTO", oSeeker:Seek( "HJ5", { (cFlow)->RA_CC } ) )
			oRecord:SetValue( "HLQ_TURNO" , oSeeker:Seek( "HJU", { (cFlow)->RA_TNOTRAB } ) ) 
			oRecord:SetValue( "HLQ_FXASAL", oSeeker:Seek( "HKG", { BIXParGetFaixa( "FXSALA", (cFlow)->RA_SALARIO, @aFxSal ) } ) ) 
			oRecord:SetValue( "HLQ_SINDIC", oSeeker:Seek( "HJV", { (cFlow)->RA_SINDICA } ) ) 
			oRecord:SetValue( "HLQ_SITCLB", oSeeker:Seek( "HKA", { (cFlow)->RA_SITFOLH } ) ) 
			oRecord:SetValue( "HLQ_COLABR", oSeeker:Seek( "HJM", { (cFlow)->RA_MAT } ) ) 
			oRecord:SetValue( "HLQ_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( (cFlow)->RA_NATURAL ) } ) ) 
			oRecord:SetValue( "HLQ_CARGO" , oSeeker:Seek( "HJP", { (cFlow)->RA_CODFUNC } ) ) 
			oRecord:SetValue( "HLQ_ESTCIV", oSeeker:Seek( "HKE", { (cFlow)->RA_ESTCIVI } ) ) 
			oRecord:SetValue( "HLQ_FXAETA", oSeeker:Seek( "HK8", { BIXParGetFaixa( "FXAETA", DateDiffYMD((cFlow)->RA_NASC, Stod(cTo))[1], @aFxEta ) } ) ) 
			oRecord:SetValue( "HLQ_GRAINS", oSeeker:Seek( "HK9", { (cFlow)->RA_GRINRAI } ) ) 
			oRecord:SetValue( "HLQ_TPCASA", oSeeker:Seek( "HKH", { BIXParGetFaixa( "TPCASA", DateDiffYMD((cFlow)->RA_ADMISSA, Stod(cTo))[1], @aTpCasa ) } ) ) 
			oRecord:SetValue( "HLQ_TPCARG", oSeeker:Seek( "HKI", { BIXParGetFaixa( "TPCARG", BIXRetTPCARG((cFlow)->RA_MAT, Stod(cTo)), @aTpcarg )  } ) ) 
			oRecord:SetValue( "HLQ_RELTRB", oSeeker:Seek( "HKD", { (cFlow)->RA_TIPOADM } ) ) 
			oRecord:SetValue( "HLQ_SECAO" , oSeeker:Seek( "HQ0", { (cFlow)->RA_DEPTO } ) ) 
			oRecord:SetValue( "HLQ_MOTMOV", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HLQ_TIPMOT", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HLQ_NIVHIE", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HLQ_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HLQ_PRESRV", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HLQ_PLOTAC", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HLQ_ULOTAC", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			oRecord:SetValue( "HLQ_LOCALI", oSeeker:oKey:GetKey( { UNDEFINED } ) )

			If SRJ->( MsSeek( xFilial("SRJ") + (cFlow)->RA_CODFUNC) ) .And. !Empty(SRJ->RJ_MAOBRA)
				oRecord:SetValue( "HLQ_TIPMOB", oSeeker:Seek( "HJQ", { SRJ->RJ_MAOBRA } ) ) 
			Else
				oRecord:SetValue( "HLQ_TIPMOB", oSeeker:oKey:GetKey( { UNDEFINED } ) )
			Endif
			
			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HLQ_QAMSAL", 0 ) // Qtde Aumento Salarial 
			oRecord:SetValue( "HLQ_VAMSAL", 0 ) // Vl Aumento Salarial
			oRecord:SetValue( "HLQ_QPROMO", 0 ) // Qtde Promovidos 
			oRecord:SetValue( "HLQ_VCBDEM", 0 ) // Vl Custo Bruto Demissão 
			oRecord:SetValue( "HLQ_VCLDEM", 0 ) // Vl Custo Líquido Demissão 
			oRecord:SetValue( "HLQ_QDEPEN", 0 ) // Qtde Dependentes 
			oRecord:SetValue( "HLQ_QHRAFT", 0 ) // Qtde Horas Afastamento
			oRecord:SetValue( "HLQ_QDFERI", 0 ) // Qtde Dias Férias
			oRecord:SetValue( "HLQ_QDFAVC", 0 ) // Qtde Dias Férias a Vencer 
			oRecord:SetValue( "HLQ_QDFVCD", 0 ) // Qtde Dias Férias Vencidas 

			oRecord:SetValue( "HLQ_DATA"  , IIf( !Empty(Stod(cTo)), Stod(cTo), DATE_EMPTY ) )  // Data da Extração 			
			oRecord:SetValue( "HLQ_QHRPRV", (cFlow)->RA_HRSMES )	// Horas Previstas 
			oRecord:SetValue( "HLQ_QTRANS", 0 )                     // Qtde Transferência Setor
			oRecord:SetValue( "HLQ_QTRANL", 0 )                     // Qtde Transferência Localidade 
			
			// Qtde Colaboradores Admitidos
			If (cFlow)->RA_ADMISSA >= Stod(cFrom) .And. (cFlow)->RA_ADMISSA <= Stod(cTo)
				oRecord:SetValue( "HLQ_QCBADM", 1 )	
			Else
				oRecord:SetValue( "HLQ_QCBADM", 0 )
			EndIf
			
			// Qtde Colaboradores Demitidos
			If lDemis
				oRecord:SetValue( "HLQ_QCBDEM", 1 )	
			Else
				oRecord:SetValue( "HLQ_QCBDEM", 0 )
			EndIf
			
			SR3->( MsSeek( xFilial("SR3") + (cFlow)->RA_MAT + cFrom, .T. ) )
			While SR3->(! EoF() ) .And.  SR3->R3_MAT == (cFlow)->RA_MAT .And. SR3->R3_DATA <= stod(cTo) .And. SR3->R3_FILIAL == xFilial("SR3")
				If nSalAtu == 0
					SR3->( dbSkip(-1) )
					If SR3->R3_MAT == (cFlow)->RA_MAT .And. SR3->R3_FILIAL == xFilial("SR3")
						nSalAtu := SR3->R3_VALOR
						SR3->( dbSkip() )
					Else
						SR3->( dbSkip() )
						nSalAtu := SR3->R3_VALOR
					EndIf
				EndIf
				
				If SR3->R3_VALOR > nSalAtu
					nVamSal += BIXValue((SR3->R3_VALOR - nSalAtu), 1, cMoeda, SR3->R3_DATA) // Vl Aumento Salarial
					
					nSalAtu  := SR3->R3_VALOR	// Atualiza o salario
					dDataAlt := SR3->R3_DATA    // Data da alteração
				EndIf
             
				If SR7->(MsSeek( xFilial("SR7") + (cFlow)->RA_MAT + Dtos(SR3->R3_DATA)))
					SR7->( dbSkip(-1) )
					If SR7->R7_MAT == (cFlow)->RA_MAT .And. SR7->R7_FILIAL == xFilial("SR7")
						cCargo  := SR7->R7_CARGO
						cFuncao := SR7->R7_FUNCAO
						SR7->( dbSkip() )
					Else
						SR7->( dbSkip() )
						cCargo  := SR7->R7_CARGO
						cFuncao := SR7->R7_FUNCAO						
					EndIf
					
					While SR7->(!Eof()) .And. SR7->R7_MAT == (cFlow)->RA_MAT .And. SR7->R7_DATA == SR3->R3_DATA .And. SR7->R7_FILIAL == xFilial("SR7")
						If SR7->R7_CARGO <> cCargo .Or. SR7->R7_FUNCAO <> cFuncao
							oRecord:SetValue( "HLQ_QRELOQ", 1 )	// Qtde Realocação
							lQReloq := .T.
							
							// Indica que houve alteração de cargo ou função na mesma data da ação salarial (foi promovido)
							If dDataAlt == SR7->R7_DATA
								lPromo := .T. 
								exit
							EndIf
						EndIf
						SR7->( dbSkip() )
					EndDo
				EndIf
				SR3->( dbSkip() )
			EndDo

			oRecord:SetValue( "HLQ_VAMSAL", nVamSal ) 	// Vl Aumento Salarial

			If nVamSal > 0
				oRecord:SetValue( "HLQ_QAMSAL", 1  )	// Qtde Aumento Salarial
				lQamSal := .T.
			EndIf
					
			If lQamSal .And. lQReloq .And. lPromo
				oRecord:SetValue( "HLQ_QPROMO", 1 ) 	// Qtde Promovidos
				oRecord:SetValue( "HLQ_QRELOQ", 0 ) 	// Qtde Realocação
				oRecord:SetValue( "HLQ_QAMSAL", 0 )	 	// Qtde Aumento Salarial
			EndIf

			
			If SRB->( MsSeek( xFilial("SRB") + (cFlow)->RA_MAT ) )
				While SRB->(! EoF() ) .And. SRB->RB_MAT == (cFlow)->RA_MAT .And. SRB->RB_FILIAL == xFilial("SRB")
					If  SRB->RB_TIPIR <> '4'
						nQDepen += 1
					EndIf	
					SRB->( dbSkip() )
				EndDo
			EndIf 
			oRecord:SetValue( "HLQ_QDEPEN", nQDepen ) // Qtde Dependentes
			 
			If SRF->( MsSeek( xFilial("SRF") + (cFlow)->RA_MAT )) 			 
				While SRF->(! EoF() ) .And. SRF->RF_FILIAL == xFilial("SRF") .And. SRF->RF_MAT == (cFlow)->RA_MAT  	
					If SRF->RF_STATUS == '1'		 
						nQDFERI += (SRF->RF_DFERVAT + SRF->RF_DFERAAT) // Qtde Dias Férias
						nQDFAVC += SRF->RF_DFERAAT                     // Qtde Dias Férias a Vencer 
						nQDFVCD += SRF->RF_DFERVAT                     // Qtde Dias Férias Vencidas
					EndIf
					
					SRF->(Dbskip())
				Enddo 
			EndIf
			oRecord:SetValue( "HLQ_QDFERI", nQDFERI) // Qtde Dias Férias
			oRecord:SetValue( "HLQ_QDFAVC", nQDFAVC) // Qtde Dias Férias a Vencer 
			oRecord:SetValue( "HLQ_QDFVCD", nQDFVCD) // Qtde Dias Férias Vencidas
			
			If ( nPos := Ascan( aPerF, {|x| x[8] == "FOL"})) > 0
				SR8->( MsSeek( xFilial("SR8") + (cFlow)->RA_MAT  + aPerF[nPos][1] + aPerF[nPos][2], .T. ) )
				While SR8->(! EoF() ) .And. SR8->R8_FILIAL == xFilial("SR8") .And. SR8->R8_MAT == (cFlow)->RA_MAT .And. SR8->R8_PER == aPerF[nPos][1] .And. SR8->R8_NUMPAGO == aPerF[nPos][2] 
					If RCM->( MsSeek( xFilial("RCM") + SR8->R8_TIPOAFA) )
						If RCM->RCM_TIPOAF == "1" .And. RCM->RCM_CODSEF $ "O1|P1|Q1|Q2|Q3|Q4|Q5|Q6"
							nQtdDias := 0 
							
							// Assumimos o padrão de 8h trabalhadas por dia
							nQHRAFT += (SR8->R8_DURACAO * 8) // Qtde Horas Afastamento
			
							// Absenteísmo
							If Month2STR(SR8->R8_DATAINI) == cMesAtu .And. Month2STR(SR8->R8_DATAFIM) == cMesAtu
								nABSENT += ( SR8->R8_DPAGAR * 8 )
								
							ElseIf Month2STR(SR8->R8_DATAINI) == cMesAtu
								nQtdDias := DateDiffDay( LastDate( SR8->R8_DATAINI ), SR8->R8_DATAINI )
								nABSENT += ( IIf(nQtdDias > 15, 15, nQtdDias) * 8 )
								
							Else
								nQtdDias := DateDiffDay( FirstDate( SR8->R8_DATAFIM ), SR8->R8_DATAINI )
								
								If  nQtdDias > 15
									nABSENT += 0
								Else
									nABSENT += (( 15 - nQtdDias ) * 8 )
								EndIf
							EndIf
						EndIf
					EndIf
					SR8->( dbSkip() )
				EndDo            
			EndIf
			oRecord:SetValue( "HLQ_QHRAFT", nQHRAFT ) // Qtde Horas Afastamento
			oRecord:SetValue( "HLQ_ABSENT", nABSENT )
				
			// Vl Calculado Absenteísmo 
			IF ( nPos := Ascan( aPerF, {|x| x[8] == "FOL"}) ) > 0
				If SRD->( MsSeek( xFilial("SRD") + (cFlow)->RA_MAT + aPerF[nPos][1] + cCod318) )
					If RCF->( MSSeek( xFilial("RCF") + aPerF[nPos][4] + aPerF[nPos][3] ) )
	 					While RCF->(!Eof()) .And. RCF->RCF_FILIAL == xFilial("RCF") .And. RCF->RCF_ANO == aPerF[nPos][4] .And. RCF->RCF_MES == aPerF[nPos][3] 
	 						IF RCF->RCF_PER == aPerF[nPos][1] .And. RCF->RCF_PROCES == aPerF[nPos][7]
								nDCalcM := RCF->RCF_DCALCM
								Exit
	 						EndIf
	 					
	 						RCF->(DbSkip())
	 					EndDo
					EndIf
					 
					While SRD->( !Eof() ) .And. SRD->RD_FILIAL == xFilial("SRD") .And. ;
						SRD->RD_MAT == (cFlow)->RA_MAT .And. SRD->RD_DATARQ == aPerF[nPos][1] ;
						.And. SRD->RD_PD == cCod318
						
						If SRD->RD_HORAS <> 0
							nValHrs +=  (SRD->RD_VALOR / nDCalcM)
						EndIf
						SRD->( dbSkip() )
					EndDo
					
					oRecord:SetValue( "HLQ_VLABST", BIXValue( ( nValHrs / 8 ) * oRecord:GetValue( "HLQ_ABSENT" ), 1, cMoeda, aPerF[nPos][6] ) )
				EndIf
			Else
				oRecord:SetValue( "HLQ_VLABST", 0 )
			EndIF

			lRecebDemis := .F.			                                        
			IF ( nPos := Ascan( aPerF, {|x| x[8] == "RES"} )) > 0			                                        
				If SRR->( MsSeek( xFilial("SRR") + (cFlow)->RA_MAT + 'R' + aPerF[nPos][1]) )
					While SRR->(! EoF() ) .And. SRR->RR_FILIAL == xFilial("SRR") .And. SRR->RR_MAT == (cFlow)->RA_MAT .And. SRR->RR_TIPO3 == 'R' .And. SRR->RR_PERIODO == aPerF[nPos][1]
						If SRV->( MsSeek( xFilial("SRV") + SRR->RR_PD  ) )
							If SRV->RV_TIPOCOD = '1' .And. SRR->RR_VALOR <> 0 
								nVCBDEM += BIXvalue(SRR->RR_VALOR, 1, cMoeda, SRR->RR_DATAPAG)
								lRecebDemis := .T.
							EndIf
							 
							If  SRV->RV_CODFOL = '0126' .And. SRR->RR_VALOR <> 0
								nVCLDEM += BIXValue(SRR->RR_VALOR, 1, cMoeda, SRR->RR_DATAPAG)
								lRecebDemis := .T.
							EndIf
						EndIf
						SRR->( dbSkip() )
					EndDo
				EndIf 
			EndIf
			oRecord:SetValue( "HLQ_VCBDEM", nVCBDEM ) // Vl Custo Bruto Demissão
			oRecord:SetValue( "HLQ_VCLDEM", nVCLDEM ) // Vl Custo Líquido Demissão
			
			//Se o colaborador não foi demitido no período mas receberá valores ref. demissão
			If !lDemis .AND. lRecebDemis
				oRecord:SetValue( "HLQ_QCOLAB", 0 ) // Qtde Colaboradores - não ativo no período
			Else
				oRecord:SetValue( "HLQ_QCOLAB", 1 ) // Qtde Colaboradores - ativo no mês, inclusive quando foi demitido no período
			EndIF
			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		Next nInd	
			
		(cFlow)->( dbSkip() ) 

	EndDo

	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()

	(cFlow)->(DbCloseArea())
	RestArea(prevAlias)
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
Method Flow( cFrom, cTo ) Class BIXVidaProfissional
	Local cQuery 	:= ""
	Local cDemitidos := BIXAddInFlow(cFrom, cTo)
	
	cQuery := "SELECT SRA.RA_MAT, SRA.RA_DEMISSA, SRA.RA_ADMISSA, SRA.RA_CATFUNC, " + ;
			"SRA.RA_CC, SRA.RA_TNOTRAB, SRA.RA_SINDICA, SRA.RA_SITFOLH, SRA.RA_CODFUNC, " + ;
			"SRA.RA_ESTCIVI, SRA.RA_GRINRAI, SRA.RA_TIPOADM, SRA.RA_DEPTO, SRA.RA_NATURAL, " + ;
			"SRA.RA_NASC, SRA.RA_SALARIO, SRA.RA_HRSMES, SRA.R_E_C_N_O_ ID " + ;
			"FROM " + RetSqlName("SRA") + " SRA " + ;
			"WHERE	SRA.RA_FILIAL = '" + xFilial("SRA") + "' " + ;
			"AND SRA.RA_ADMISSA <= '" + cTo + "' " + ;
			"AND ((SRA.RA_DEMISSA = ' ' OR SRA.RA_DEMISSA >= '" + cFrom + "') " 
			If !Empty(cDemitidos)
				cQuery += "OR SRA.RA_MAT IN (" + cDemitidos+ ") " 
			EndIf
	cQuery += ")" + ;
			"AND SRA.D_E_L_E_T_ = ' ' "
	

	//-------------------------------------------------------------------
	// Transforma a query em ANSI. 
	//-------------------------------------------------------------------  	
	cQuery := ChangeQuery(cQuery)

	//-------------------------------------------------------------------
	// Abre a área de trabalho temporária. 
	//-------------------------------------------------------------------  	
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), ::cFlow := GetNextAlias(), .T., .T.)   
	
	TcSetField( ::cFlow, "RA_DEMISSA", "D", 8, 0 )
	TcSetField( ::cFlow, "RA_ADMISSA", "D", 8, 0 )
	TcSetField( ::cFlow, "RA_NASC", "D", 8, 0 )
Return ::cFlow

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXAddInFlow
Criação da query anterior ao fluxo principal para adicionar colaboradores 
que receberão valores por demissão ao fluxo

@param cFrom 	Data de início do período verificado
@param cTo 	Data de fim do período verificado

@author  Tamara Clemente
@since   17/11/2015
/*/
//-------------------------------------------------------------------

Static Function BIXAddInFlow( cFrom, cTo )
	Local cDemits 	:= ""
	Local cQuery := ""
	
	Private cPrevAlias := getNextAlias()
		
	cQuery := "SELECT DISTINCT SRR.RR_MAT " + ;
			"FROM " + RetSqlName("SRR") + " SRR " + ;
			"INNER JOIN " + RetSqlName("SRV") + " SRV " + ;
				"ON (SRV.RV_FILIAL = '" + xFilial("SRV") + "' " + ;
				"AND SRV.RV_COD = SRR.RR_PD " + ;
				"AND SRV.RV_TIPOCOD = '1' " + ;
				"AND SRV.D_E_L_E_T_ = ' ') " + ;
			"WHERE	SRR.RR_FILIAL = '" + xFilial("SRR") + "' " + ;
			"AND SRR.RR_TIPO3 = 'R' " + ;			
			"AND SRR.RR_DATAPAG BETWEEN '" + cFrom + "' AND '" + cTo + "' " + ;
			"AND SRR.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cPrevAlias, .T., .T.)   
	
	While (cPrevAlias)->(! Eof() )
		if Len(cDemits) > 0
			cDemits += ","
		EndIf		
		
		cDemits += "'" + (cPrevAlias)->RR_MAT + "'"
		(cPrevAlias)->( dbSkip() )
	EndDo
	
	(cPrevAlias)->(DbCloseArea())
Return cDemits

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSubFlow
Criação da query do fluxo auxiliar

@param cAuxAlias 	Alias utilizado pela query
@param cMat 		Matrícula do colaborador
@param cFrom 	Data de início do período verificado
@param cTo 	Data de fim do período verificado
@param lFuncFilial 	Se .T. verifica transferências de ENTRADA 
			para a filial de extração, se .F. verifica 
			transferências de SAÍDA da filial de extração

@author  Tamara Clemente
@since   17/11/2015
/*/
//-------------------------------------------------------------------
Static Function BIXSubFlow( cAuxAlias, cMat, cFrom, cTo, lFuncFilial )
	Local cQuery 	:= ""
	Default lFuncFilial := .F.
	
	cQuery := "SELECT SRE.R_E_C_N_O_ " + ;
			"FROM " + RetSqlName("SRE") + " SRE " + ;
			"WHERE	SRE.RE_FILIAL = '" + xFilial("SRE") + "' "
			
			If lFuncFilial
				cQuery += "AND SRE.RE_MATP = '" + cMat + "' " + ;
							"AND SRE.RE_DATA >= '" + cFrom + "' " + ;
							"AND SRE.RE_FILIALP = '" + cFilAnt + "' " 							
			Else
			 	cQuery += "AND SRE.RE_MATD = '" + cMat + "' " + ;
			 				"AND SRE.RE_DATA Between '" + cFrom + "' AND '" + cTo + "' "  
			EndIF

	cQuery += "AND (SRE.RE_FILIALD <> SRE.RE_FILIALP OR SRE.RE_EMPD <> SRE.RE_EMPP) " + ;
			"AND SRE.D_E_L_E_T_ = ' ' "
		
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAuxAlias, .T., .T.)       	

Return NIL
