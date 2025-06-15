#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXRECLAMACOES.CH"

REGISTER EXTRACTOR HLF

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXReclamacoes
Apresenta informações dos processos registrados contra a empresa, 
como também as reclamações associadas, em quantidades.

@author  BI TEAM
@since   31/08/2010
/*/
//-------------------------------------------------------------------
Class BIXReclamacoes from BIXEntity
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
Method New() Class BIXReclamacoes
	_Super:New( FACT, "HLF", STR0001, "RE0", { RH } ) //"Reclamações Trabalhistas"
Return Self  

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Definição do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Marcia Junko
@since   28/05/2017
/*/
//------------------------------------------------------------------- 
Method Model() Class BIXReclamacoes
	Local oModel := BIXModel():Build( Self )

	oModel:AddField( "HLF_EMPRES", "C", 32, 0, .T., "HJ4")
	oModel:AddField( "HLF_ESTABL", "C", 32, 0, .T., "HKK")
	oModel:AddField( "HLF_GRAINS", "C", 32, 0, .T., "HK9")
	oModel:AddField( "HLF_NIVHIE", "C", 32, 0, .T., "HG5")
	oModel:AddField( "HLF_SINDIC", "C", 32, 0, .T., "HJV")
	oModel:AddField( "HLF_SITCLB", "C", 32, 0, .T., "HKA")
	oModel:AddField( "HLF_TPCASA", "C", 32, 0, .T., "HKH")
	oModel:AddField( "HLF_TPCARG", "C", 32, 0, .T., "HKI")
	oModel:AddField( "HLF_SECAO" , "C", 32, 0, .T., "HQ0")
	oModel:AddField( "HLF_COLREC", "C", 32, 0, .T., "HJM")
	oModel:AddField( "HLF_DATA"  , "D", 8, 0, .F., "HK2")
	oModel:AddField( "HLF_DTPROC", "D", 8, 0 )
	oModel:AddField( "HLF_DTFIMP", "D", 8, 0 )
	oModel:AddField( "HLF_NUMPRC", "C", 30, 0 )
	oModel:AddField( "HLF_QTRECL", "N", 16, 4 )	

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
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oSeeker ) class BIXReclamacoes
	Local prevAlias     := GetArea()
	Local cFilter       := ""
	Local cColabr       := ""  
	Local aTpCasa 	:= {}
	Local aTpCarg 	:= {}	 
	
	DbSelectArea("SRA")         // Funcionarios
	SRA->( dbSetOrder(1) ) // Filial + RA_MAT

	DbSelectArea("RE0")
	RE0->( dbSetOrder(1) )

	cFilter := " RE0_FILIAL = '" + xFilial("RE0") + "'"
	cFilter += " .And. (RE0_DTPROC >= STOD('" + cFrom + "') .And. RE0_DTPROC <= STOD('" + cTo + "')) .Or. "
	cFilter += " (RE0_DTPROT >= STOD('" + cFrom + "') .And. RE0_DTPROT <= STOD('" + cTo + "')) .Or. "
	cFilter += " (RE0_DTARQU >= STOD('" + cFrom + "') .And. RE0_DTARQU <= STOD('" + cTo + "')) "		
	
	RE0->( dbSetFilter ( &("{|| " + cFilter + "}"), cFilter) )
	RE0->( dbGoTop() )

	DbSelectArea("RDZ")
	RDZ->( dbSetOrder(2) )	

	aTpCasa := aBIToken( BIXParInfo( "TPCASA", "C", "" ), ";", .F. )
	aTpCarg := aBIToken( BIXParInfo( "TPCARG", "C", "" ), ";", .F. )		

	While RE0->(! EoF() )
		If RDZ->(MsSeek(xFilial("RDZ") + RE0->RE0_RECLAM))
			cColabr := SubStr(RDZ->RDZ_CODENT,TamSX3("RDZ_FILIAL")[1] + 1)
		EndIf
		
		If SRA->(MsSeek(xFilial("SRA") + cColabr))
			//-------------------------------------------------------------------
			// Inicializa o registro. 
			//------------------------------------------------------------------- 				
			oRecord:Init()
			
			//-------------------------------------------------------------------
			// Customização.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "RE0_NUM" , RE0->RE0_NUM )
			oRecord:SetValue( "RCE_CODIGO" , RE0->RE0_CODSIN )
			oRecord:SetValue( "QB_DEPTO"   , SRA->RA_DEPTO )
			oRecord:SetValue( "RA_MAT"   , SRA->RA_MAT )

			//-------------------------------------------------------------------
			// Lookups.
			//------------------------------------------------------------------- 
			oRecord:SetValue( "HLF_EMPRES", oSeeker:Seek( "HJ4", { ::GetCompany( ) } ) ) 
			oRecord:SetValue( "HLF_ESTABL", oSeeker:Seek( "HKK", { ::GetCompany( ), ::GetUnitBusiness( ), ::GetFilial( ) } ) )
			oRecord:SetValue( "HLF_GRAINS", oSeeker:Seek( "HK9", { SRA->RA_GRINRAI } ) ) 
			oRecord:SetValue( "HLF_SINDIC", oSeeker:Seek( "HJV", { RE0->RE0_CODSIN } ) ) 
			oRecord:SetValue( "HLF_SITCLB", oSeeker:Seek( "HKA", { SRA->RA_SITFOLH } ) ) 
			oRecord:SetValue( "HLF_TPCASA", oSeeker:Seek( "HKH", { BIXParGetFaixa( "TPCASA", DateDiffYMD(SRA->RA_ADMISSA, IIf(!Empty(SRA->RA_DEMISSA),SRA->RA_DEMISSA,stod(cTo)))[1], @aTpCasa )} ) ) 
			oRecord:SetValue( "HLF_TPCARG", oSeeker:Seek( "HKI", { BIXParGetFaixa( "TPCARG", BIXRetTPCARG(SRA->RA_MAT, RE0->RE0_DTPROC), @aTpCarg ) } ) ) 
			oRecord:SetValue( "HLF_SECAO" , oSeeker:Seek( "HQ0", { SRA->RA_DEPTO } ) )
			oRecord:SetValue( "HLF_COLREC", oSeeker:Seek( "HJM", { cColabr } ) ) 
			oRecord:SetValue( "HLF_NIVHIE", oSeeker:oKey:GetKey( { UNDEFINED } ) )

			//-------------------------------------------------------------------
			// Indicadores.
			//------------------------------------------------------------------- 			
			oRecord:SetValue( "HLF_DTPROC", IIf( !Empty(RE0->RE0_DTPROT), RE0->RE0_DTPROT, DATE_EMPTY ) ) // Data de Abertura do Processo
			oRecord:SetValue( "HLF_DTFIMP", IIf( !Empty(RE0->RE0_DTARQU), RE0->RE0_DTARQU, DATE_EMPTY ) ) // Data de Encerramento do Processo 
			oRecord:SetValue( "HLF_DATA  ", IIf( !Empty(RE0->RE0_DTPROC), RE0->RE0_DTPROC, DATE_EMPTY ) ) // Data do Periodo Informado (Mês/Ano)
			oRecord:SetValue( "HLF_NUMPRC", RE0->RE0_NUM )                                               // Numero Processo 
			oRecord:SetValue( "HLF_QTRECL", 1 )                                                          // Qtde Reclamações 

			//-------------------------------------------------------------------
			// Envia o registro para o pool de gravação. 
			//-------------------------------------------------------------------				
			oOutput:Send( oRecord ) 
		EndIf
		RE0->( dbSkip() )    
	EndDo

	//-------------------------------------------------------------------
	// Libera o pool de gravação. 
	//-------------------------------------------------------------------	
	oOutput:Release()

	RE0->( DBClearFilter() ) // Remove filtro
Return NIL