#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXENTITY.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXEntity
Classe respons�vel por representar uma entidade.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Class BIXEntity
	Data oModel
	Data aApp
	Data nType
	Data cEntity
	Data _cFilial
	Data cBranch
	Data cCompany
	Data cUnitBusiness
	Data cTable
	Data cTitle
	Data cFlow
	Data cLastExec
	Data lUseLG
	Data lUseShare	
	Data lIncrement
	Data lUnified

	Method New( nType, cEntity, cTitle, cTable, aApp, lIncrement ) CONSTRUCTOR
	Method ClassName( )
	Method Run( cFrom, cTo )
	Method Model( )
	Method Filial( )
	Method Company( )
	Method UnitBusiness( )
	Method Flow( cFrom, cTo, aField, aWhere ) 
	Method SetEntity( cEntity )
	Method SetType( nType )
	Method SetTable( cTable )
	Method SetApp( aApp )
	Method SetTitle( cTitle )
	Method GetModel( )
	Method GetFilial( )
	Method GetCompany( )
	Method GetUnitBusiness( )
	Method GetEntity( )
	Method GetType( )
	Method GetTable( )
	Method GetApp() 
	Method GetTitle( )
	Method GetIncrement( )
	Method GetExec( )
	Method LastExec( ) 
	Method SetUseLG( cTable )
	Method GetUseLG( )
	Method GetUseShare( )
	Method GetUnified( )
	Method Destroy( )
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo contrutor.
  
@param nType, caracter, Tipo da entidade (fato ou dimens�o).
@param cEntity, caracter, Nome da entidade.
@param cTitle, caracter, Descri��o da entidade.
@param [cTable], caracter, Tabela origem da entidade no Protheus.
@param [aApp], array, Tabela origem da entidade no Protheus.
@param lShare, boolean, Verifica compartilhamento da entidade.
@param lIncrement, boolean, Indica se a entidade far� extra��o incremental
@Return Self, Inst�ncia da Classe. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method New( nType, cEntity, cTitle, cTable, aApp, lShare, lIncrement ) Class BIXEntity
	Default aApp	   := {}
	Default nType	   := ""
	Default cEntity	   := ""
	Default cTitle	   := ""
	Default cTable	   := ""
	Default lShare	   := .F.	
	Default lIncrement := .F. 

	::aApp			   := {}
	::nType			   := nType
	::cEntity		   := cEntity
	::cTitle		   := cTitle
	::aApp			   := aApp
	::cTable		   := cTable
	::_cFilial		   := nil
	::cCompany		   := nil
	::cUnitBusiness	   := nil
	::cFlow			   := nil
	::cLastExec		   := ""
	::lUseLG 		   := .F.
	::lIncrement       := lIncrement
	::lUnified         := ! ( Empty( BIXGetUnifier( cEntity ) ) )
	
	If ::lIncrement
		::LastExec( )
	EndIf	

	::lUseShare	:= BIXParInfo( "BIX_CMPEMP", "L", .F. )
	
	If ( Empty( nType ) .Or.  Empty( cEntity ) .Or. Empty( cTitle ) )
		UserException ( STR0001 ) //"Os par�metros obrigat�rios da entidade n�o foram preenchidos!"
	EndIf	
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ClassName
Retorna o nome da classe.  

@Return cClassName, Nome da classe. 

@author  Valdiney V GOMES
@since   26/01/2017
/*/
//-------------------------------------------------------------------
Method ClassName( ) Class BIXEntity
Return "BIXENTITY"

//-------------------------------------------------------------------
/*/{Protheus.doc} SetEntity
Define a entidade. 

@param cEntity, Entidade. 
@Return cEntity, Retorna a entidade. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method SetEntity( cEntity ) Class BIXEntity
	Default cEntity := ""
	
	::cEntity := cEntity
Return ::cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} SetType
Define o tipo da entidade. 

@param nType, num�rico, Tipo da entidade.
@Return nType, Retorna a entidade. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method SetType( nType ) Class BIXEntity
	Default nType := ""
	
	::nType := nType
Return ::nType

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTable
Tabela origem da entidade. 

@param cTable, Tabela origem da entidade.
@Return cTable, Tabela origem da entidade. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method SetTable( cTable ) Class BIXEntity
	Default cTable := ""
	
	::cTable := cTable
Return ::cTable

//-------------------------------------------------------------------
/*/{Protheus.doc} SetApp
App da entidade. 

@param aApp, App da entidade.
@Return aApp, App da entidade. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method SetApp( aApp ) Class BIXEntity
	Default aApp := ""
	
	::aApp := aApp
Return ::aApp

//-------------------------------------------------------------------
/*/{Protheus.doc} SetTitle
T�tulo da entidade. 

@param cTable, T�tulo da entidade.
@Return cTable, T�tulo da entidade.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method SetTitle( cTitle ) Class BIXEntity
	Default cTitle := ""
	
	::cTitle := cTitle
Return ::cTitle

//-------------------------------------------------------------------
/*/{Protheus.doc} Run
Executa a extra��o dos dados da entidade. 

@param cFrom, caracter, Per�odo inicial de extra��o.
@param cTo, caracter, Per�odo final de extra��o.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method Run( cFrom, cTo ) Class BIXEntity
Return nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} Model
Define o modelo de dados da entidade. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method Model( ) Class BIXEntity
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Filial
Define a regra de filial para a entidade. 

@Return _cFilial, Filial da entidade.  

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method Filial( ) Class BIXEntity
	Local _cFilial := ""
	
	If ! ( Empty( ::cTable ) )
		_cFilial := xFilial( ::cTable )
	EndIf
	
	//------------------------------------------------------------------------
	// Tratamento para n�o deixar filial de fato em branco igual o motor atual  
	//------------------------------------------------------------------------ 
	If ( ::nType == FACT ) .And. Empty( _cFilial )
		_cFilial := cFilAnt
	EndIf
	
Return _cFilial

//-------------------------------------------------------------------
/*/{Protheus.doc} UnitBusiness
Define a regra da unidade de neg�cio para a entidade. 

@Return cUnitBusiness, Unidade de neg�cio da entidade.  

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method UnitBusiness( ) Class BIXEntity
	Local cUnitBusiness := ""
	
	If ! ( Empty( ::cTable ) )
		cUnitBusiness := FWUnitBusiness( ::cTable )
	EndIf
Return cUnitBusiness

//-------------------------------------------------------------------
/*/{Protheus.doc} Company
Define a regra da empresa para a entidade. 

@Return cCompany, Empresa da entidade.  

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method Company( ) Class BIXEntity
	Local cCompany := ""
	
	If ! ( Empty( ::cTable ) )
		cCompany := FWCompany( ::cTable )
	EndIf
Return cCompany

//-------------------------------------------------------------------
/*/{Protheus.doc} Flow
Define o fluxo de dados da entidade. Pode ser usado para recuperar
dados de uma �nica tabela ou sobrescrito para recuperar dados de mais
de uma tabela.  

@param cFrom, caracter, Per�odo inicial de extra��o.
@param cTo, caracter, Per�odo final de extra��o.
@param aField, array, Lista de campos a serem recuperados. 
@param [aWhere], array, Restri��o na recupera��o de dados no formato {{campo, opera��o, valor}}. 
@return cFlow, Alias tempor�rio. 

@author  Valdiney V GOMES
@since   27/01/2017
/*/
//-------------------------------------------------------------------
Method Flow( cFrom, cTo, aField, aWhere ) Class BIXEntity
	Local cPrefix	:= ""
	Local cDML		:= ""
	Local nWhere	:= 0 

	Default cFrom	:= ""
	Default cTo		:= ""
	Default aField	:= {}
	Default aWhere	:= {}

	If ! ( Empty( ::cTable ) )
		//-------------------------------------------------------------------
		// Identifica o prefixo dos campos.
		//------------------------------------------------------------------- 
		If ( Substr( ::cTable, 1, 1) == "S" )
			cPrefix := Substr( ::cTable, 2 ) 
		Else
			cPrefix := ::cTable 
		EndIf 
	
		//-------------------------------------------------------------------
		// Monta o DML.
		//------------------------------------------------------------------- 
		cDML += " SELECT " 
		
		If ! ( Empty( aField ) )
			cDML += BIXConcatWSep( ", ", aField )
		Else
			cDML += "*"
		EndIf

		//-------------------------------------------------------------------
		// Adiciona os campos de USERLGI e USERLGA
		//-------------------------------------------------------------------
		IF ::GetUseLG()
			cDML += ", " + BIXAddLGField( ::cTable )
		EndIf
		
		cDML += " FROM " + RetSQLName( ::cTable ) + " " + ::cTable 
		cDML += " WHERE " 
		
		If ! ( Empty( aWhere ) )
			For nWhere := 1 To Len ( aWhere )
				cDML += ::cTable + "." + aWhere[nWhere][1] + " " + aWhere[nWhere][2] + " '" + aWhere[nWhere][3] + "'"  
				cDML += " AND "
			Next nWhere
		EndIf
		
		cDML += ::cTable + "." + cPrefix + "_FILIAL" + " = " + "'" + xFilial( ::cTable  ) + "'"           
		cDML += "	AND " 
		cDML += ::cTable + "." + "D_E_L_E_T_ = ' '"   	 

		//-------------------------------------------------------------------
		// Executa DML. 
		//-------------------------------------------------------------------  	
		DBUseArea( .T., "TOPCONN", TCGenQry( ,,cDML ), ::cFlow := GetNextAlias(), .F., .T. ) 
	EndIf
Return ::cFlow

//-------------------------------------------------------------------
/*/{Protheus.doc} GetType
Retorna o tipo da entidade. 

@Return nType, Tipo da entidade. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetType( ) Class BIXEntity
Return ::nType

//-------------------------------------------------------------------
/*/{Protheus.doc} GetEntity
Retorna a entidade. 

@Return cEntity, Entidade. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetEntity( ) Class BIXEntity
Return ::cEntity

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTable
Retorna a tabela de origem da entidade no Protheus

@Return cTable, Tabela de origem da entidade no Protheus.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetTable( ) Class BIXEntity
Return ::cTable

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTitle
Retorna o t�tulo da entidade. 

@Return cTitle, T�tulo da entidade.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetTitle( ) Class BIXEntity
Return ::cTitle

//-------------------------------------------------------------------
/*/{Protheus.doc} GetIncrement
Retorna se a entidade usa extra��o incremental 

@Return lIncrement, Extra��o incremental.

@author  Andreia Lima
@since   18/01/2018
/*/
//-------------------------------------------------------------------
Method GetIncrement( ) Class BIXEntity
Return ::lIncrement

//-------------------------------------------------------------------
/*/{Protheus.doc} GetApp
Retorna o app da entidade. 

@Return cApp, App da entidade.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetApp( ) Class BIXEntity
Return ::aApp

//-------------------------------------------------------------------
/*/{Protheus.doc} GetExec
Retorna a �ltima execu��o da entidade

@Return cLastExec, Data da ultima execu��o da entidade

@author  Marcia Junko
@since   07/06/2017
/*/
//-------------------------------------------------------------------
Method GetExec( ) Class BIXEntity
Return ::cLastExec

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFilial
Retorna a filial da tabela. 

@Return cCompany, Filial da tabela.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetFilial( ) Class BIXEntity
	If ( ::_cFilial == nil )
		::_cFilial := ::Filial( ) 
	
		If ( ::nType == FACT )		
			If ( Empty( FWFilial( ::cTable ) ) )
				::_cFilial := "__"
			Endif
		EndIf
	EndIf
Return AllTrim( ::_cFilial )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCompany
Retorna a empresa da entidade. 

@Return cCompany, Empresa da entidade.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetCompany( ) Class BIXEntity
	If ( ::cCompany == nil )
		If ( ::nType == FACT )	
			::cCompany :=  FWCompany( )
		Else
			If ! ( Empty( ::cTable ) )
				::cCompany := FWCompany( ::cTable )
			Else 
				::cCompany := ::Company( )
			EndIf 
		EndIf 
	EndIf
Return AllTrim( ::cCompany )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUnitBusiness
Retorna a unidade de neg�cio da entidade. 

@Return cUnitBusiness, Unidade de neg�cio da entidade.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetUnitBusiness( ) Class BIXEntity
	If ( ::cUnitBusiness == nil )
		If ( ::nType == FACT )	
			::cUnitBusiness := FWUnitBusiness( )
		Else
			If ! ( Empty( ::cTable ) )
				::cUnitBusiness := FWUnitBusiness( ::cTable )
			Else 
				::cUnitBusiness := ::UnitBusiness( )
			EndIf 
		EndIf
	EndIf
Return AllTrim( ::cUnitBusiness )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetModel
Retorna o modelo de dados da entidade. 

@Return oModel, Modelo de dados da entidade.

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method GetModel( ) Class BIXEntity
	If ( Empty( ::oModel ) )
		::oModel := ::Model( )
	EndIf
Return ::oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} LastExec  
Retorna a data e hora do agendamento da extra��o realizada. 

@param cTable, caracter, Alias de uma tabela do Protheus. 
@return cCampos, caracter, Cont�m os campos _USERLGI\_USERLGA 

@author  Marcia Junko
@since   05/06/2017
/*/
//-------------------------------------------------------------------
Method LastExec( ) Class BIXEntity
 	Local cSvAlias      := Alias()
	Local cQuery        := ""
	Local cTmpTbl       := GetNextAlias()
	Local cCompany	   	:= Space( 12 ) 
	Local cUnitBusiness	:= Space( 12 )
	Local cBranch		:= Space( 12 )  
	Local cGrpEmp	   	:= Space( 02 )   
	
    cCompany      := PadR( ::GetCompany( ), 12 )
    cUnitBusiness := PadR( ::GetUnitBusiness( ), 12 )
	cGrpEmp       := PadR( cEmpAnt, 02 )    
	cBranch       := PadR( ::GetFilial( ), 12 ) 

	//---------------------------------------------------------------
	// Se a tabela de hist�rico n�o tiver sido criada, a cria.
	//---------------------------------------------------------------
	BIXOpenHistory()

	cQuery := "SELECT HY6_DATE FROM HY6 WHERE HY6_TABLE = '" + ::cEntity + "' AND HY6_OPER = '2' AND D_E_L_E_T_ = ' '"
	cQuery += "   AND HY6_GRPEMP = '" + cGrpEmp + "' AND HY6_CDEMPR = '" + cCompany + "' AND HY6_CDUNEG = '" + cUnitBusiness + "' AND HY6_FILIAL = '" + cBranch + "'" 
	
	//-------------------------------------------------------------------
	// Executa o DML. 
	//-------------------------------------------------------------------  	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cQuery ), cTmpTbl, .T., .F. )
	
	If (cTmpTbl)->(!Eof())
		::cLastExec := Dtos(CTOD((cTmpTbl)->HY6_DATE))
	EndIf

	(cTmpTbl)->(DBCloseArea())
	
	If !Empty( cSvAlias )
		DbSelectArea( cSvAlias )
	EndIf
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} SetUseLG  
Retorna a data e hora do agendamento da extra��o realizada. 

@param cTable, caracter, Alias de uma tabela do Protheus. 
@return cCampos, caracter, Cont�m os campos _USERLGI\_USERLGA 

@author  Marcia Junko
@since   09/11/2017
/*/
//-------------------------------------------------------------------
Method SetUseLG( cTable ) Class BIXEntity
	Local cField := ""
	
	Default cTable := ::cTable
	
	If ::lIncrement
		IF !Empty( cTable )
			cField := BIXAddLGField( cTable, 2 )
			
			IF !Empty( cField )
				::lUseLG := .T.
			Else
				::lUseLG := .F.
			EndIf
		Else
			::lUseLG := .F.
		EndIf
	EndIf	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUseLG  
Retorna a data e hora do agendamento da extra��o realizada. 

@param cTable, caracter, Alias de uma tabela do Protheus. 
@return cCampos, caracter, Cont�m os campos _USERLGI\_USERLGA 

@author  Marcia Junko
@since   09/11/2017
/*/
//-------------------------------------------------------------------
Method GetUseLG( ) Class BIXEntity
Return ::lUseLG

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUseShare  
Retorna se est� configurado o uso de compartilhamento de tabelas 

@return lUseShare, l�gico, Retorna o conte�do do par�metro BIX_CMPEMP 

@author  Marcia Junko
@since   23/11/2017
/*/
//-------------------------------------------------------------------
Method GetUseShare( ) Class BIXEntity
Return ::lUseShare

//-------------------------------------------------------------------
/*/{Protheus.doc} GetUnified  
Retorna se est� configurado o consolidador da entidade.

@return lUnified, l�gico, se entidade est� consolidada. 

@author  Helio Leal
@since   21/06/2018
/*/
//-------------------------------------------------------------------
Method GetUnified( ) Class BIXEntity
Return ::lUnified


//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Destroi o objeto e libera a mem�ria alocada. 

@author  Valdiney V GOMES
@since   17/01/2017
/*/
//-------------------------------------------------------------------
Method Destroy( ) Class BIXEntity
	aSize( ::aApp, 0 )
	
	If ! ( Empty( ::oModel ) )
		::oModel:Destroy( )
	EndIf	

	If ! ( Empty( ::cFlow ) )
		If ! ( Empty ( Select( ::cFlow  ) ) )
			( ::cFlow )->( DBCloseArea( ) )
		EndIf
	EndIf

	::aApp			:= nil
	::oModel		:= nil
	::nType			:= nil
	::cEntity		:= nil
	::cTable		:= nil
	::cTitle		:= nil
	::_cFilial		:= nil
	::cCompany		:= nil
	::cUnitBusiness	:= nil
	::cFlow			:= nil
	::lUseShare		:= nil
	::lUnified      := nil	
Return nil