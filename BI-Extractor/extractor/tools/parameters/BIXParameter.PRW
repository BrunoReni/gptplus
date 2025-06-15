#INCLUDE "BIXEXTRACTOR.CH"
#INCLUDE "BIXPARAMETER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXDelGrpParam
Remove um parâmetro da HJK.

@param lOpenLink
@param nRecNo

@author  BI TEAM
@version P11
@since   31/01/2011
/*/
//-------------------------------------------------------------------
Function BIXDelGrpParam( lOpenLink , nRecNo )   
	Local aArea 		:= getArea() 
	Local cQuery		:= ""
	Local lContinue 	:= .T.  
	Local nLink			:= BIXGetLink()   
	
	Default lOpenLink		:= .F. 
	Default nRecNo		:= 0

	//-------------------------------------------------------------------
	// Verifica se deve conectar na Fluig Smart Data. 
	//-------------------------------------------------------------------
	If ( BIXLinkFSD() > 0 )	
		BIXSetupTable("HJK")
		
		//-------------------------------------------------------------------
		// Monta a query para remoção do parâmetro. 
		//-------------------------------------------------------------------	
		cQuery += " DELETE"
		cQuery += " FROM" 
		cQuery += " 		HJK"
		cQuery += " WHERE" 
		cQuery += " 		R_E_C_N_O_ = '" + cBIStr( nRecNo ) + "'
		
		//-------------------------------------------------------------------
		// Remove o parâmetro. 
		//-------------------------------------------------------------------	
		If ( TCSQLExec(cQuery) < 0 )
			BIXSysOut( "BIXDelGrpParam", TCSQLError() )
		EndIf 
		
		BIXSetLink( nLink )
	EndIf

	RestArea( aArea )
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXLoadParam
Retorna os valores de um parâmetro da HJK.  

@param cParameter		Parâmetro que será consultado. 
@param cEntity			Fato relacionado ao parâmetro que será consultado. 
@param lColletion		Identifica se o conteúdo parâmetro é uma lista. 

@return aParameter	Conteúdo do parâmetro solicitado. 

@author  BI Team
@version P11
/*/
//-------------------------------------------------------------------
function BIXLoadParam( cParameter, cEntity, lColletion, lLike )
	Local aParameter 	:= Nil	
	Local aArea   		:= GetArea()
	Local cTemp			:= GetNextAlias()
	Local cQuery  		:= ""  
	Local nLink			:= BIXGetLink()

	Default cParameter 	:= "" 	          
	Default cEntity 	:= "___"         
	Default lColletion 	:= .F.
	Default lLike		:= .F.

	If ( BIXLinkFSD() > 0 )
		BIXSetupTable( "HJK" )

		//-------------------------------------------------------------------
		// Monta a query para recuperação do conteúdo do parâmetro. 
		//-------------------------------------------------------------------		
		If !lColletion .AND. !lLike 
			cQuery += " SELECT"
			cQuery += " 		*"
			cQuery += " FROM" 
			cQuery += " 		HJK"
			cQuery += " WHERE" 
			cQuery += " 		HJK_CPARAM = '" + Padr( cParameter, 10 ) + "'
			cQuery += " AND 
			cQuery += " 		HJK_CDFATO = '" + Padr( cEntity, 3 ) + "'
			cQuery += " AND 
			cQuery += " 		D_E_L_E_T_ = ' ' "		
		Else
			cQuery += " SELECT"
			cQuery += " 		*"
			cQuery += " FROM" 
			cQuery += " 		HJK"
			cQuery += " WHERE" 
			If !(lLike)
				cQuery += "		HJK_CPARAM = '" + Padr(cParameter,10) + "'
			Else
				cQuery += "		HJK_CPARAM LIKE '" + cParameter+"%" + "'
			EndIf
			cQuery += " AND 
			cQuery += " 		D_E_L_E_T_ = ' ' "	
		EndIf 		
		
		//-------------------------------------------------------------------
		// Monta a área de trabalho temporária. 
		//-------------------------------------------------------------------			
		DBUseArea( .T., "TOPCONN", TcGenQry( ,,ChangeQuery( cQuery ) ), cTemp ) 
			
		//-------------------------------------------------------------------
		// Recupera o parâmetro.  
		//-------------------------------------------------------------------				
		If !lColletion .AND. !lLike	
			If ! (cTemp)->( EoF() ) 
				aParameter := { (cTemp)->HJK_CPARAM, (cTemp)->HJK_DPARAM, (cTemp)->HJK_VPARAM, (cTemp)->HJK_APARAM, (cTemp)->HJK_CDFATO, (cTemp)->R_E_C_N_O_ }
			EndIf  
		Else 
			aParameter := {}
		   			
			While ! (cTemp)->( EoF() ) 
				aAdd( aParameter , { (cTemp)->HJK_CPARAM, (cTemp)->HJK_DPARAM, (cTemp)->HJK_VPARAM, (cTemp)->HJK_APARAM, (cTemp)->HJK_CDFATO, (cTemp)->R_E_C_N_O_ } )
				(cTemp)->( DBSkip() )		
			EndDo
		EndIf
					
		(cTemp)->( DBCloseArea() )
		
		BIXSetLink( nLink )
	EndIf
	
	RestArea( aArea )
Return aParameter

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXSaveParam
Salva um parâmetro na HJK.  

@param cName
@param cValue		
@param cFato		
@param lOpenLink		
@param lForGrp		
@param lUpdGrp				
@param aInfos			

@author  BI Team
@version P11
/*/
//-------------------------------------------------------------------
Function BIXSaveParam(cName, cValue, cFato, lOpenLink, lForGrp, lUpdGrp, aInfos, cError )                        
	Local aArea 		:= getArea()	
	Local nPos			:= 0
	Local aFxsDesc 		:= BIXGetFaixas() 
	Local lContinue 	:= .T.   
	Local nLink			:= BIXGetLink()
	                       	
	Default cFato 		:= '___'
	Default lOpenLink	:= .T.        
	Default lForGrp     := .F.
	Default lUpdGrp     := .F.   
	Default aInfos      := {}
	Default cError		:= ""
	
	//-------------------------------------------------------------------
	// Padroniza o tamanho das chaves. 
	//-------------------------------------------------------------------
	cName 	:= PadR( cName, 10 )
	cFato 	:= PadR( cFato, 3 )

	//-------------------------------------------------------------------
	// Loga o status de extração de processos e entidades.
	//-------------------------------------------------------------------
	If ( AllTrim( cName ) == "STATUS" )	   	
   		If ( AllTrim( cValue ) == "RUNNING" )
			BIXSetLog( LOG_RUNNING, cFato )
			
   		ElseIf  ( AllTrim( cValue ) == "ERROR" )
			BIXSetLog( LOG_ERROR, cFato,,,,, cError )
			
   		ElseIf ( AllTrim( cValue ) == "OK" )
			BIXSetLog( LOG_FINISH, cFato )

			//-------------------------------------------------------------------
			// Identifica se o status da HJK pode ser alterado. 
			//-------------------------------------------------------------------
			If ( BIXLogStatus( cFato ) == LOG_RUNNING )
				cValue := "RUNNING"
			ElseIf ( BIXLogStatus( cFato ) == LOG_ERROR )
				cValue := "ERROR"
			EndIf 
		EndIf 
	EndIf 

	If ( BIXLinkFSD() > 0 )
		BIXSetupTable( "HJK" )
		DBUseArea( .T., "TOPCONN", "HJK", "HJK", .T., .F. )
		
		HJK->( dbSetIndex("HJK1") )
		HJK->( dbSetOrder(1) )
		
		//-------------------------------------------------------------------
		// Identifica se atualiza ou insere um parâmetro. 
		//-------------------------------------------------------------------
		If !( lForGrp )
			If ( HJK->( dbSeek(xFilial("HJK") + cName + cFato) ) )
				RecLock( "HJK", .F. )
			Else
				RecLock( "HJK", .T. )
			EndIf
		Else 
			If ( lUpdGrp ) 
				HJK->( DbGoTo(aInfos[6]) ) 
				RecLock( "HJK", .F. )  
			Else
			  	RecLock( "HJK", .T. )     
			EndIf
		EndIf
		
		//-------------------------------------------------------------------
		// Atualiza os parâmetros. 
		//-------------------------------------------------------------------	
		If Left(cName,6) == "CNTRES"
			nPos := aScan( aFxsDesc, {|x| x[1] == alltrim(Left(cName,6))} )
		Else
			nPos := aScan( aFxsDesc, {|x| x[1] == alltrim(cName)} )
		EndIf
		
		If ! ( nPos == 0 )
			HJK->HJK_FILIAL := xFilial("HJK")
			HJK->HJK_CDFATO := cFato 
			HJK->HJK_CPARAM := cName
			HJK->HJK_DPARAM := aFxsDesc[nPos, 2]
			HJK->HJK_APARAM := aFxsDesc[nPos, 3]
			HJK->HJK_VPARAM := cValue
		EndIf 
		
		HJK->( MsUnlock() )
		HJK->( DBCloseArea() )
		
		BIXSetLink( nLink )
	EndIf 

	RestArea( aArea )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BIXGetAParam
Lista de moedas configuradas para uma fato. 

@param cParameter		Parâmetro solicitado.  
@return aMoeda			Lista com os valores do parâmetro solicitado. 

@author  BI Team
@version P11
@since   13/04/2011
/*/
//-------------------------------------------------------------------
Function BIXGetAParam( cParameter )
	Local aParameter := BIXParInfo( cParameter,,,, .T. )  
Return aParameter              