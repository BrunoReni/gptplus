#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXCONT.CH"

REGISTER EXTRACTOR HJE

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXCont
Visualiza as informa��es c�digo ou nome da Conta Cont�bil que est� relacionada a um 
plano de contas. Conta Cont�bil � o elemento cont�bil destinado a sintetizar, mediante
d�bitos e cr�ditos, as opera��es financeiras e patrimoniais, classificadas segundo os 
tipos dos componentes do patrim�nio (bens, direitos e obriga��es), dos custos, despesas 
ou consumos, das rendas ou receitas, do capital e dos lucros ou perdas.

@author  BI TEAM
@since   18/11/2010
/*/
//-------------------------------------------------------------------
Class BIXCont from BIXEntity
	Method New( ) CONSTRUCTOR
	Method Model( )
	Method Run( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New  
Construtor padr�o.  

@Return Self, Inst�ncia da classe.

@author  Helio Leal
@since   07/04/2017
/*/
//-------------------------------------------------------------------  
Method New() class BIXCont
	_Super:New( DIMENSION, "HJE", STR0001, "CT1" ) //"Conta Cont�bil"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Defini��o do modelo de dados da entidade.  
           
@Return oModel, objeto,	Modelo de dados da entidade.

@author  Helio Leal
@since   07/04/2017
/*/
//------------------------------------------------------------------- 
Method Model() class BIXCont 
	Local oModel := BIXModel():Build( Self )

	oModel:SetSK( "HJE_CNTCTB" )
	oModel:SetBK( { "HJE_CODIGO" } )

	oModel:AddField( "HJE_CNTCTB" , "C", 32, 0 )
	oModel:AddField( "HJE_CNTCTP" , "C", 32, 0, .T. )	
	oModel:AddField( "HJE_PLCONT" , "C", 08, 0 )
	oModel:AddField( "HJE_CNTPAI" , "C", 40, 0 )
	oModel:AddField( "HJE_CODIGO" , "C", 40, 0 )
	oModel:AddField( "HJE_DESC"   , "C", 40, 0 )	
	
	oModel:FreeField() 
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Extra��o dos dados para entidade. 
 
@param cFrom, caracter, Data inicial de extra��o. 
@param cTo, caracter, Data final de extra��o.
@param dToday, data, Data de inicio do processo de extra��o.  
@param oOutput, objeto, Objeto para grava��o dos dados.
@param oRecord, objeto, Objeto para extra��o dos dados.
@param oKey, objeto, Objeto para gera��o da surrogate key.

@author  Helio Leal
@since   07/04/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo, dToday, oOutput, oRecord, oKey ) class BIXCont
	Local aUpper	:= {}
	Local cUpper 	:= ""
	Local cSup		:= ""
	Local nCount	:= 0
	Local cFlow 	:= ""
    	
	cFlow := ::Flow( cFrom, cTo, { "CT1_CONTA", "CT1_DESC01", "CT1_CTASUP", "CT1_CLASSE" } )

	While ! ( (cFlow)->( Eof() ) ) 
		//-------------------------------------------------------------------
		// Inicializa o registro. 
		//-------------------------------------------------------------------   	
		oRecord:Init()
		
		//-------------------------------------------------------------------
		// Alimenta os campos para customiza��o e consolida��o. 
		//-------------------------------------------------------------------	
		oRecord:SetValue( "CT1_CONTA", 	(cFlow)->CT1_CONTA )

		//-------------------------------------------------------------------
		// Alimenta os campos de neg�cio. 
		//-------------------------------------------------------------------
		oRecord:SetValue( "HJE_CNTCTB"	, oKey:GetKey( { (cFlow)->CT1_CONTA } ) )		
		oRecord:SetValue( "HJE_CODIGO"	, (cFlow)->CT1_CONTA )
		oRecord:SetValue( "HJE_DESC"	, (cFlow)->CT1_DESC01 )
		oRecord:SetValue( "HJE_PLCONT"	, UNDEFINED )

		//-------------------------------------------------------------------
		// Recupera as informa��es da conta superior.
		//-------------------------------------------------------------------
		cUpper := (cFlow)->CT1_CTASUP
		
		//-------------------------------------------------------------------
		// Verifica se a conta superior � sint�tica.
		//-------------------------------------------------------------------
		If ( CT1->( DBSeek( xFilial("CT1") + cUpper ) ) .And. CT1->CT1_CLASSE == "1" )
			oRecord:SetValue( "HJE_CNTPAI", cUpper )
			oRecord:SetValue( "HJE_CNTCTP",  oKey:GetKey( { cUpper },,,,.F. ) )
		Else			
			oRecord:SetValue( "HJE_CNTCTP", oKey:GetKey( { UNDEFINED },,,,.F. ) )
			oRecord:SetValue( "HJE_CNTPAI", UNDEFINED )
			
			//-------------------------------------------------------------------
			// Lista as contas superiores que n�o s�o sint�ticas. 
			//-------------------------------------------------------------------	
			If ! ( Empty( cUpper ) )
				If ( aScan( aUpper, {|x| Alltrim(x) == Alltrim( cUpper ) } ) == 0 )
					Aadd( aUpper, AllTrim( cUpper ) )
				EndIf
			EndIf			
		EndIf
		
		//-------------------------------------------------------------------
		// Envia o registro para o pool de grava��o da Fluig Smart Data. 
		//-------------------------------------------------------------------		
		oOutput:Send( oRecord ) 

 		(cFlow)->( DBSkip() ) 
	EndDo

	//-------------------------------------------------------------------
	// Libera o pool de grava��o. 
	//-------------------------------------------------------------------	
 	oOutput:Release()
	
	//-------------------------------------------------------------------
	// Loga as contas superiores n�o sint�ticas. 
	//-------------------------------------------------------------------	
	If ! ( Empty( aUpper ) )
		BIXSetLog( LOG_RUNNING, "HJE",,,,, STR0001 + " " + BIXConcatWSep( ",", aUpper ) + STR0002 ) //"Conta Cont�bil"###" indicado(s) como superior n�o � sint�tica."    
	EndIf
Return nil