#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXTREINAMENTO.CH"

REGISTER EXTRACTOR HLM

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXTreinamento
Apresenta informações dos treinamentos realizados e em andamento, e 
das bolsas de estudos, em quantidades e valores.

@author  BI TEAM
@since   31/08/2010
/*/
//-------------------------------------------------------------------
Class BIXTreinamento from BIXEntity
	Method New() CONSTRUCTOR
	Method Model() 
	Method Run()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padrão.  

@Return Self, Instância da classe.

@author  Marcia Junko
@since   29/05/2017
/*/
//-------------------------------------------------------------------  
Method New() Class BIXTreinamento
	Local cMapHLM := ""

	If !Empty(xFilial("RA4"))
		cMapHLM := "RA4" 
	ElseIf !Empty(xFilial("RA3"))
		cMapHLM := "RA3"
	Else
		cMapHLM := "RA4"
	EndIf	

	_Super:New( FACT, "HLM", STR0001, cMapHLM, { RH } ) //"Treinamentos Colaboradores"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   29/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXTreinamento
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLM_EMPRES", "C", 32, 0, .T., "HJ4" )
	oModel:AddField( "HLM_ESTABL", "C", 32, 0, .T., "HKK" )
	oModel:AddField( "HLM_UNDNEG", "C", 32, 0, .T., "HJ1" )
	oModel:AddField( "HLM_FXASAL", "C", 32, 0, .T., "HKG" )
	oModel:AddField( "HLM_MOEDA ", "C", 32, 0, .T., "HJ6" )
	oModel:AddField( "HLM_CATSAL", "C", 32, 0, .T., "HJT" )
	oModel:AddField( "HLM_SINDIC", "C", 32, 0, .T., "HJV" )
	oModel:AddField( "HLM_TURNO ", "C", 32, 0, .T., "HJU" )
	oModel:AddField( "HLM_TIPMOB", "C", 32, 0, .T., "HJQ" )
	oModel:AddField( "HLM_COLABR", "C", 32, 0, .T., "HJM" )
	oModel:AddField( "HLM_CCUSTO", "C", 32, 0, .T., "HJ5" )
	oModel:AddField( "HLM_INSTIT", "C", 32, 0, .T., "HJN" )
	oModel:AddField( "HLM_INSTRU", "C", 32, 0, .T., "HJO" )
	oModel:AddField( "HLM_CURSO ", "C", 32, 0, .T., "HJL" )
	oModel:AddField( "HLM_TIPCUR", "C", 32, 0, .T., "HG6" )
	oModel:AddField( "HLM_REGIAO", "C", 32, 0, .T., "HJB" )
	oModel:AddField( "HLM_ESTCIV", "C", 32, 0, .T., "HKE" )
	oModel:AddField( "HLM_FXAETA", "C", 32, 0, .T., "HK8" )
	oModel:AddField( "HLM_GRAINS", "C", 32, 0, .T., "HK9" )
	oModel:AddField( "HLM_NIVHIE", "C", 32, 0, .T., "HG5" )
	oModel:AddField( "HLM_RELTRB", "C", 32, 0, .T., "HKD" )
	oModel:AddField( "HLM_TPCASA", "C", 32, 0, .T., "HKH" )
	oModel:AddField( "HLM_TPCARG", "C", 32, 0, .T., "HKI" )
	oModel:AddField( "HLM_CARGO" , "C", 32, 0, .T., "HJP" )
	oModel:AddField( "HLM_PLCCST", "C", 32, 0, .T., "HKF" )
	oModel:AddField( "HLM_SECAO" , "C", 32, 0, .T., "HQ0" )
	oModel:AddField( "HLM_LOCALI", "C", 32, 0, .T., "HQO" )
	oModel:AddField( "HLM_PLOTAC", "C", 32, 0, .T., "HQP" )
	oModel:AddField( "HLM_ULOTAC", "C", 32, 0, .T., "HQT" )
	oModel:AddField( "HLM_BOLSA" , "C", 32, 0, .T., "HQA" )
	oModel:AddField( "HLM_MOTTRE", "C", 32, 0, .T., "HQR" )
	oModel:AddField( "HLM_DATA"  , "D", 8, 0, .F., "HK2" )
	oModel:AddField( "HLM_STTREI", "C", 1, 0 )		
	oModel:AddField( "HLM_QCTREI", "N", 4, 0 )
	oModel:AddField( "HLM_QHTREI", "N", 16, 4 )
	oModel:AddField( "HLM_DBOLSA", "N", 16, 4 )
	oModel:AddField( "HLM_QBOLSA", "N", 16, 4 )
	oModel:AddField( "HLM_VTREIN", "N", 16, 2 )
	oModel:AddField( "HLM_VINVEP", "N", 16, 2 )
	oModel:AddField( "HLM_VINVCL", "N", 16, 2 )

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXTreinamento
	Local oRegion	:= NIL
	Local aMoedas   := {}
	Local prevAlias := GetArea()
	Local cFilter	:= ""                    
	Local cMoeda	:= ""
	Local nInd      := 1
	Local aFXSal 	:= {}	
	Local aFXEta 	:= {}
	Local aTpCasa 	:= {}
	Local aTpCarg 	:= {}	 	

	aMoedas := BIXGetMxF(::cEntity )
	oRegion	:= BIXRegiao():New()
	
	DbSelectArea("RA4")    // Curso de funcionário	
	RA4->( dbSetOrder(1) ) // Filial + ...
	
	cFilter := " RA4_FILIAL = '" + xFilial("RA4") + "'"
	cFilter += " .AND. RA4_DATAIN >= STOD('" + cFrom + "') "
	cFilter += " .AND. RA4_DATAIN <= STOD('" + cTo + "') "
	
	RA4->( DBSetFilter ( &("{|| " + cFilter + "}"), cFilter) )
	RA4->( dbGoTop() )
	
	DbSelectArea("RA1")         // Cursos
	RA1->( dbSetOrder(1) ) // Filial + RA1_CURSO

	DbSelectArea("RA2")         // Treinamento
	RA2->( dbSetOrder(2) ) // RA2_FILIAL + RA2_CURSO + RA2_TURMA

	DbSelectArea("SRA")         // Funcionário
	SRA->( dbSetOrder(1) ) // Filial + RA_MAT

	DbSelectArea("SRJ")         // Funções
	SRJ->( dbSetOrder(1) ) // Filial + RJ_FUNCAO

	DbSelectArea("RA0")         // Entidades
	RA0->( dbSetOrder(1) ) // Filial + RA0_ENTIDA

	aFXSal := aBIToken( BIXParInfo( "FXSALA", "C", "" ), ";", .F. )	
	aFXEta := aBIToken( BIXParInfo( "FXAETA", "C", "" ), ";", .F. )
	aTpCasa := aBIToken( BIXParInfo( "TPCASA", "C", "" ), ";", .F. )
	aTpCarg := aBIToken( BIXParInfo( "TPCARG", "C", "" ), ";", .F. )		
    
	While RA4->(! Eof() )
		RA2->( dbSetOrder(2) )
		If  RA1->( MsSeek( xFilial("RA1") + RA4->RA4_CURSO  ) ) .And. ;
			RA2->( MsSeek( xFilial("RA2") + RA4->RA4_CURSO  ) ) .And. ;
			RA0->( MsSeek( xFilial("RA0") + RA4->RA4_ENTIDA ) ) .And. ;
			SRA->( MsSeek( xFilial("SRA") + RA4->RA4_MAT 	) ) .And. ;
			SRJ->( MsSeek( xFilial("SRJ") + SRA->RA_CODFUNC ) )

			RA2->( dbSetOrder(1) ) // RA2_FILIAL + RA2_CALEND + RA2_CURSO + RA2_TURMA
			RA2->( MsSeek( xFilial("RA2") + RA4->RA4_CALEND + RA4->RA4_CURSO + RA4->RA4_TURMA  ) )

			For nInd := 1 To Len(aMoedas)
				cMoeda := aMoedas[nInd][1]

				//-------------------------------------------------------------------
				// Inicializa o registro. 
				//------------------------------------------------------------------- 				
				oRecord:Init()
				
				//-------------------------------------------------------------------
				// Customização.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "RCE_CODIGO" , SRA->RA_SINDICA )
				oRecord:SetValue( "R6_TURNO"   , SRA->RA_TNOTRAB )
				oRecord:SetValue( "CTT_CUSTO"  , SRA->RA_CC ) 
				oRecord:SetValue( "RA7_INSTRU" , RA2->RA2_INSTRU )
				oRecord:SetValue( "QX_CODIGO"  , RA1->RA1_TIPOPP )				
				oRecord:SetValue( "RJ_FUNCAO"  , SRA->RA_CODFUNC )
				oRecord:SetValue( "QB_DEPTO"   , SRA->RA_DEPTO )
				oRecord:SetValue( "RA_MAT"     , RA4->RA4_MAT )
				oRecord:SetValue( "RA1_CURSO"  , RA4->RA4_CURSO )
				oRecord:SetValue( "RA0_ENTIDA" , RA4->RA4_ENTIDA )

				//-------------------------------------------------------------------
				// Lookups.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "HLM_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
				oRecord:SetValue( "HLM_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HLM_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
				oRecord:SetValue( "HLM_FXASAL", oSeeker:Seek( "HKG", { BIXParGetFaixa( "FXSALA", SRA->RA_SALARIO, @aFxSal ) } ) ) 
				oRecord:SetValue( "HLM_MOEDA ", oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) )
				oRecord:SetValue( "HLM_CATSAL", oSeeker:Seek( "HJT", { SRA->RA_CATFUNC } ) )
				oRecord:SetValue( "HLM_SINDIC", oSeeker:Seek( "HJV", { SRA->RA_SINDICA } ) ) 
				oRecord:SetValue( "HLM_TURNO ", oSeeker:Seek( "HJU", { SRA->RA_TNOTRAB } ) ) 
				oRecord:SetValue( "HLM_COLABR", oSeeker:Seek( "HJM", { RA4->RA4_MAT } ) ) 
				oRecord:SetValue( "HLM_CCUSTO", oSeeker:Seek( "HJ5", { SRA->RA_CC } ) )
				oRecord:SetValue( "HLM_INSTIT", oSeeker:Seek( "HJN", { RA4->RA4_ENTIDA } ) ) 
				oRecord:SetValue( "HLM_INSTRU", oSeeker:Seek( "HJO", { RA2->RA2_INSTRU } ) ) 
				oRecord:SetValue( "HLM_CURSO ", oSeeker:Seek( "HJL", { RA4->RA4_CURSO } ) ) 
				oRecord:SetValue( "HLM_TIPCUR", oSeeker:Seek( "HG6", { RA1->RA1_TIPOPP } ) ) 
				oRecord:SetValue( "HLM_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( SRA->RA_NATURAL ) } ) ) 
				oRecord:SetValue( "HLM_ESTCIV", oSeeker:Seek( "HKE", { SRA->RA_ESTCIVI } ) )
				oRecord:SetValue( "HLM_FXAETA", oSeeker:Seek( "HK8", { BIXParGetFaixa( "FXAETA", DateDiffYMD(SRA->RA_NASC, RA4->RA4_DATAIN)[1], @aFxEta ) } ) )
				oRecord:SetValue( "HLM_GRAINS", oSeeker:Seek( "HK9", { SRA->RA_GRINRAI } ) )
				oRecord:SetValue( "HLM_RELTRB", oSeeker:Seek( "HKD", { SRA->RA_TIPOADM } ) )
				oRecord:SetValue( "HLM_TPCASA", oSeeker:Seek( "HKH", { BIXParGetFaixa( "TPCASA", DateDiffYMD(SRA->RA_ADMISSA, RA4->RA4_DATAIN)[1], @aTpCasa ) } ) )
				oRecord:SetValue( "HLM_TPCARG", oSeeker:Seek( "HKI", { BIXParGetFaixa( "TPCARG", BIXRetTPCARG(SRA->RA_MAT, RA4->RA4_DATAFI), @aTpcarg )  } ) )
				oRecord:SetValue( "HLM_CARGO" , oSeeker:Seek( "HJP", { SRA->RA_CODFUNC } ) )
				oRecord:SetValue( "HLM_SECAO" , oSeeker:Seek( "HQ0", { SRA->RA_DEPTO } ) ) 
				oRecord:SetValue( "HLM_NIVHIE", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLM_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLM_LOCALI", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLM_PLOTAC", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLM_ULOTAC", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLM_BOLSA" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLM_MOTTRE", oSeeker:oKey:GetKey( { UNDEFINED } ) )

				If !Empty(SRJ->RJ_MAOBRA)
					oRecord:SetValue( "HLM_TIPMOB", oSeeker:Seek( "HJQ", { SRJ->RJ_MAOBRA } ) ) 
				Else
					oRecord:SetValue( "HLM_TIPMOB", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				Endif
				
				//-------------------------------------------------------------------
				// Atributo
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HLM_STTREI", "S" )	// Treinamento Concluido
				
				//-------------------------------------------------------------------
				// Indicadores.
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HLM_DATA  ", IIf( !Empty(RA4->RA4_DATAFI), RA4->RA4_DATAFI, DATE_EMPTY ) ) // Data de Realização do Treinamento
				oRecord:SetValue( "HLM_QHTREI", RA1->RA1_HORAS )                                    // Qtde Horas Treinamento 
				oRecord:SetValue( "HLM_VTREIN", BIXValue(RA1->RA1_VALOR,1,cMoeda,RA4->RA4_DATAIN) ) // Vl Treinamento
				oRecord:SetValue( "HLM_QCTREI", 1 )                                                 // Qtde Colaboradores Treinados
				oRecord:SetValue( "HLM_VINVEP", 0 )                                                 // Vl Investimento Empresa
				oRecord:SetValue( "HLM_VINVCL", 0 )                                                 // Vl Investimento Colaborador 
				oRecord:SetValue( "HLM_DBOLSA", 0 )                                                 // Qtde Dias Bolsa Estudo
				oRecord:SetValue( "HLM_QBOLSA", 0 )                                                 // Qtde Colaboradores Bolsistas

				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
            Next nInd
		EndIf
		RA4->( dbSkip() )
	EndDo
  
	RA4->( DBClearFilter() ) // Remove filtro

// =================================== FLUXO DA RA3

	
	DbSelectArea("RA3")         // Curso de funcionário	
	RA3->( dbSetOrder(1) ) // Filial + ...
	
	cFilter := " RA3_FILIAL = '" + xFilial("RA3") + "'"
	cFilter += " .AND. RA3_DATA >= STOD('" + cFrom + "') "
	cFilter += " .AND. RA3_DATA <= STOD('" + cTo + "') "

	RA3->( DBSetFilter ( &("{|| " + cFilter + "}"), cFilter) )
	RA3->( dbGoTop() )
	
	While RA3->(! Eof() )
    	RA2->( dbSetOrder(2) )
    	
		If  RA1->( MsSeek( xFilial("RA1") + RA3->RA3_CURSO  ) ) .And. ;
			RA2->( MsSeek( xFilial("RA2") + RA3->RA3_CURSO  ) ) .And. ;
			SRA->( MsSeek( xFilial("SRA") + RA3->RA3_MAT 	) ) .And. ;
			SRJ->( MsSeek( xFilial("SRJ") + SRA->RA_CODFUNC ) )

			RA2->( dbSetOrder(1) ) // RA2_FILIAL + RA2_CALEND + RA2_CURSO + RA2_TURMA
			RA2->( MsSeek( xFilial("RA2") + RA3->RA3_CALEND + RA3->RA3_CURSO + RA3->RA3_TURMA  ) )

			//-------------------------------------------------------------------
			// Valida o relacionamento com a região geográfica.  
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
				oRecord:SetValue( "RCE_CODIGO" , SRA->RA_SINDICA )
				oRecord:SetValue( "R6_TURNO"   , SRA->RA_TNOTRAB )
				oRecord:SetValue( "CTT_CUSTO"  , SRA->RA_CC ) 
				oRecord:SetValue( "RA7_INSTRU" , RA2->RA2_INSTRU )
				oRecord:SetValue( "QX_CODIGO"  , RA1->RA1_TIPOPP )				
				oRecord:SetValue( "RJ_FUNCAO"  , SRA->RA_CODFUNC )
				oRecord:SetValue( "QB_DEPTO"   , SRA->RA_DEPTO )
				oRecord:SetValue( "RA_MAT"     , RA4->RA4_MAT )
				oRecord:SetValue( "RA1_CURSO"  , RA4->RA4_CURSO )
				oRecord:SetValue( "RA0_ENTIDA" , RA4->RA4_ENTIDA )
				
				//-------------------------------------------------------------------
				// Lookups.
				//------------------------------------------------------------------- 
				oRecord:SetValue( "HLM_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
				oRecord:SetValue( "HLM_UNDNEG", oSeeker:Seek( "HJ1", { ::GetCompany( ), ::GetUnitBusiness( ) } ) )
				oRecord:SetValue( "HLM_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
				oRecord:SetValue( "HLM_FXASAL", oSeeker:Seek( "HKG", { BIXParGetFaixa( "FXSALA", SRA->RA_SALARIO, @aFxSal ) } ) ) 
				oRecord:SetValue( "HLM_MOEDA ", oSeeker:Seek( "HJ6", { aMoedas[nInd][2] } ) ) 
				oRecord:SetValue( "HLM_CATSAL", oSeeker:Seek( "HJT", { SRA->RA_CATFUNC } ) )
				oRecord:SetValue( "HLM_SINDIC", oSeeker:Seek( "HJV", { SRA->RA_SINDICA } ) ) 
				oRecord:SetValue( "HLM_TURNO ", oSeeker:Seek( "HJU", { SRA->RA_TNOTRAB } ) ) 
				oRecord:SetValue( "HLM_COLABR", oSeeker:Seek( "HJM", { RA4->RA4_MAT } ) ) 
				oRecord:SetValue( "HLM_CCUSTO", oSeeker:Seek( "HJ5", { SRA->RA_CC } ) )
				oRecord:SetValue( "HLM_INSTIT", oSeeker:Seek( "HJN", { RA4->RA4_ENTIDA } ) ) 
				oRecord:SetValue( "HLM_INSTRU", oSeeker:Seek( "HJO", { RA2->RA2_INSTRU } ) ) 
				oRecord:SetValue( "HLM_CURSO ", oSeeker:Seek( "HJL", { RA4->RA4_CURSO } ) ) 
				oRecord:SetValue( "HLM_TIPCUR", oSeeker:Seek( "HG6", { RA1->RA1_TIPOPP } ) ) 
				oRecord:SetValue( "HLM_REGIAO", oSeeker:Seek( "HJB", { oRegion:Key( SRA->RA_NATURAL ) } ) ) 
				oRecord:SetValue( "HLM_ESTCIV", oSeeker:Seek( "HKE", { SRA->RA_ESTCIVI } ) ) 
				oRecord:SetValue( "HLM_FXAETA", oSeeker:Seek( "HK8", { BIXParGetFaixa( "FXAETA", DateDiffYMD(SRA->RA_NASC, RA3->RA3_DATA)[1], @aFxEta ) } ) )
				oRecord:SetValue( "HLM_GRAINS", oSeeker:Seek( "HK9", { SRA->RA_GRINRAI } ) ) 
				oRecord:SetValue( "HLM_RELTRB", oSeeker:Seek( "HKD", { SRA->RA_TIPOADM } ) ) 
				oRecord:SetValue( "HLM_TPCASA", oSeeker:Seek( "HKH", { BIXParGetFaixa( "TPCASA", DateDiffYMD(SRA->RA_ADMISSA, RA3->RA3_DATA)[1], @aTpCasa ) } ) )
				oRecord:SetValue( "HLM_TPCARG", oSeeker:Seek( "HKI", { BIXParGetFaixa( "TPCARG", BIXRetTPCARG(SRA->RA_MAT, RA3->RA3_DATA), @aTpcarg )  } ) )
				oRecord:SetValue( "HLM_CARGO" , oSeeker:Seek( "HJP", { SRA->RA_CODFUNC } ) ) 
				oRecord:SetValue( "HLM_SECAO" , oSeeker:Seek( "HQ0", { SRA->RA_DEPTO } ) ) 
				oRecord:SetValue( "HLM_NIVHIE", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLM_PLCCST", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLM_LOCALI", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLM_PLOTAC", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLM_ULOTAC", oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLM_BOLSA" , oSeeker:oKey:GetKey( { UNDEFINED } ) )
				oRecord:SetValue( "HLM_MOTTRE", oSeeker:oKey:GetKey( { UNDEFINED } ) )

				If !Empty(SRJ->RJ_MAOBRA)
					oRecord:SetValue( "HLM_TIPMOB", oSeeker:Seek( "HJQ", { SRJ->RJ_MAOBRA } ) ) 
				Else
					oRecord:SetValue( "HLM_TIPMOB", oSeeker:oKey:GetKey( { UNDEFINED } ) )	
				Endif
				
				//-------------------------------------------------------------------
				// Atributo
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HLM_STTREI", "N" )	// Treinamento Concluido

				//-------------------------------------------------------------------
				// Indicadores.
				//------------------------------------------------------------------- 			
				oRecord:SetValue( "HLM_DATA  ", IIf( !Empty(RA3->RA3_DATA), RA3->RA3_DATA, DATE_EMPTY ) ) // Data de Realização do Treinamento
				oRecord:SetValue( "HLM_QHTREI", RA1->RA1_HORAS )                                  // Qtde Horas Treinamento 
				oRecord:SetValue( "HLM_VTREIN", BIXValue(RA1->RA1_VALOR,1,cMoeda,RA3->RA3_DATA) ) // Vl Treinamento
				oRecord:SetValue( "HLM_QCTREI", 0 )                                               // Qtde Colaboradores Treinados
				oRecord:SetValue( "HLM_VINVEP", 0 )                                               // Vl Investimento Empresa
				oRecord:SetValue( "HLM_VINVCL", 0 )                                               // Vl Investimento Colaborador 
				oRecord:SetValue( "HLM_DBOLSA", 0 )                                               // Qtde Dias Bolsa Estudo
				oRecord:SetValue( "HLM_QBOLSA", 0 )                                               // Qtde Colaboradores Bolsistas

				//-------------------------------------------------------------------
				// Envia o registro para o pool de gravação. 
				//-------------------------------------------------------------------				
				oOutput:Send( oRecord ) 
            Next nInd
		EndIf 
		RA3->( dbSkip() )
	EndDo		

	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()
	
	RA3->( DBClearFilter() ) // Remove filtro	
	RestArea(prevAlias)
Return NIL
