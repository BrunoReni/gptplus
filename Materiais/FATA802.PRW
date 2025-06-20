#Include 'Protheus.ch'
#Include 'FATA802.CH'
#Include 'FWMVCDef.ch'

Static cRetF3 := ""
//-------------------------------------------------------------------
/*/{Protheus.doc} FATA802

Rotina para controle de exporta��o de dados. O uso da rotina facilita
o processo de integra��o e evita que a cada nova integra��o um campo
novo seja criado nas tabelas.

Importante: Para todas as integra��es o campo de controle
ser� efetuado pelo campo de sistema "_MSEXP" este campo � limpado
de forma autom�tica sempre que houver altera��o no registro, indicando
assim, que o registro em quest�o dever� ser exportado novamente, e 
pelo campo de usu�rio "_HREXPO" que gravar� a hora da exporta��o. Tais 
campos devem existir na tabela que ser� exportada.

@return Nil
 
@author Thamara Villa Jacomo
@since 26/01/2015
/*/
//-------------------------------------------------------------------
Function FATA802()

Local aArea 	   := GetArea()
Local oMBrowse   := Nil

Private cCadastro := STR0005//"Controle de Exporta��o"
Private aRotina := MenuDef()

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "AIP" )
oMBrowse:SetDescription( STR0005 )//"Controle de Exporta��o"

oMBrowse:Activate() 

RestArea( aArea )

Return( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Define as opera��es que poder�o ser realizadas pela aplica��o.

@return aRotina - Retorna as opera��es
 
@author Thamara Villa Jacomo
@since 30/01/2015
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {} 

ADD OPTION aRotina TITLE STR0001 ACTION "VIEWDEF.FATA802" OPERATION 1 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.FATA802" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.FATA802" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.FATA802" OPERATION 5 ACCESS 0 //"Excluir"

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo de Dados (Regra de Neg�cio)

@return oModel - Objeto do Modelo de Dados
 
@author Thamara Villa Jacomo
@since 30/01/2015
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel  := Nil
Local oStruAIP := FWFormStruct( 1, "AIP" )
Local oStruAIR := FWFormStruct( 1, "AIR" )

oModel := MPFormModel():New()( "FATA802", /*"bPrevalid"*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields( "AIPMASTER",/*cOwner*/, oStruAIP )
oModel:AddGrid( "AIRDETAIL", "AIPMASTER", oStruAIR )

//------------------------------------------------------------------
// Rela��es
//------------------------------------------------------------------
oModel:SetRelation( "AIRDETAIL", { { "AIR_FILIAL", "xFilial( 'AIR' )" },{ "AIR_CODINT", "AIP_CODIGO" } }, AIR->( IndexKey( 1 ) ) )

oModel:GetModel( "AIRDETAIL" ):SetNoInsertLine( .T. )
oModel:GetModel( "AIRDETAIL" ):SetNoUpdateLine( .T. )
oModel:GetModel( "AIRDETAIL" ):SetOptional( .T. )

oModel:SetDescription( STR0005 )//"Controle de Exporta��o"

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

View - Interface de intera��o com o Modelo de Dados 

@return oView - Objeto do Modelo de Dados
 
@author Thamara Villa Jacomo
@since 30/01/2015
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView    := Nil
Local oModel 	 := FWLoadModel( "FATA802" )
Local oStruAIP := FWFormStruct( 2, "AIP" )
Local oStruAIR := FWFormStruct( 2, "AIR" )

oView := FWFormView():New()

oView:SetModel( oModel ) 

//---------------------------------------------------------------
// Adiciona campos da tabela de C�digo de Integra��o (AIP)
//---------------------------------------------------------------
oStruAIP:AddGroup( 'GRUPO01', "Integra��o", "", 2 ) //"Integra��o"
oStruAIP:SetProperty( '*', MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
oView:AddField( "VIEW_AIP", oStruAIP, "AIPMASTER" )

oView:CreateHorizontalBox( "TOP", 20 )
oView:SetOwnerView( "VIEW_AIP", "TOP" )

//----------------------------------------------------------------
// Adiciona grid da tabela de Controle de Exporta��o (AIR)
//----------------------------------------------------------------
oView:AddGrid( "VIEW_AIR", oStruAIR, "AIRDETAIL" )

oView:CreateHorizontalBox( "BOTTOM", 80 )
oView:EnableTitleView( "VIEW_AIR", STR0005 )//"Controle de Exporta��o"
oView:SetOwnerView( "VIEW_AIR", "BOTTOM" )  

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} Ft802Expo

Grava��o do log de exporta��o de dados.

@param cCodInt		- C�digo da intgra��o conforme tabela AIP.
@param cTag		- Sequ�ncial composto de 4 caracteres, utilizado para
					   compor a chave em caso de exporta��o para a mesma tabela
					   na mesma integra��o com regras diferentes.
@param cTabela		- Tabela Principal de Exporta��o.
@param cQuery		- Query com os dados a serem exportados
@param cNameRec	- Nome do alias atribu�do ao R_E_C_N_O_, caso exista.
@param cNameExp	- Nome do alias atribu�do ao campo _MSEXP, caso exista.
@param cNameHrExp	- Nome do alias atribu�do ao campo _HREXPO, caso exista.

@return lRet 		- Retorna se foi poss�vel efetuar a grava��o do log.
 
@author Thamara Villa Jacomo
@since 26/01/2015
/*/
//-------------------------------------------------------------------
Function Ft802Expo( cCodInt, cTag, cTabela, cQuery, cNameRec, cNameExp, cNameHrExp )

Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaAIP	:= AIP->( GetArea() )
Local aAreaAIR	:= AIR->( GetArea() )
Local cAliasQry	:= GetNextAlias() 
Local cDtUltEx	:= ""
Local cHrUltEx	:= ""
Local cCpTabel	:= Iif( SubStr( cTabela, 1, 1 ) == "S", SubStr( cTabela, 2,3 ), cTabela )
Local nFindRec	:= 0
Local nCont		:= 0

Default cNameRec  := ""
Default cNameRec  := "" 
Default cNameExp  := "" 
Default cNameHrExp:= ""

//-----------------------------------------------------------------------
// Verifica se os par�metros obrigat�rios foram informados 
//-----------------------------------------------------------------------
If Empty( cCodInt ) .Or. Empty( cTag ) .Or. Empty( cTabela ) .Or. Empty( cQuery )
	Help( " ", 1, 'FT802NOPARAM' )//H� par�metro(s) obrigat�rio(s) n�o informado(s).
	lRet := .F.
EndIf

//-----------------------------------------------------------------------
// Verifica se os campos de exporta��o existem, sen�o, solicita cria��o.
//-----------------------------------------------------------------------
If !( ( cTabela )->( FieldPos( cCpTabel + "_MSEXP" ) ) > 0 .And.  ( cTabela )->( FieldPos( cCptabel + "_HREXPO" ) ) > 0 )  
	Help( " " , 1, 'FT802NOFIELD' )// � necess�rio efetuar a cria��o dos campos _MSEXP e _HREXPO na tabela informada, pois, tais campos ser�o utilizados no controle da exporta��o. ## Criar os respectivos campos na tabela.
	lRet := .F.
EndIf


If lRet 
	//----------------------------------------------------------------
	// Verifica se j� existe exporta��o para a integra��o informada.
	//----------------------------------------------------------------
	DbSelectArea( "AIP" ) //Cadastro de integra��es
	DbSetOrder( 1 ) //AIP_FILIAL+AIP_CODIGO        
	If !DbSeek( xFilial( "AIP" ) + cCodInt )
				
		//----------------------------------------------------
		// Se n�o existir, solicita o cadastro da integra��o
		//----------------------------------------------------
		Help( " ", 1, "FT802CADINT",, , 1, 0 )//N�o existe cadastro para a integra��o informada. ##Efetue o cadastro da integra��o na tabela AIP (Cadastro de Integra��es).
		lRet := .F.
	Else
		
		Begin Transaction
		
			If Select( cAliasQry ) > 0
				DbSelectArea( cAliasQry )
				DbCloseArea()
			EndIf
					
			DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .T., .T. )	
		
		
			If Empty( cNameRec )
				cNameRec := "R_E_C_N_O_"
			EndIf
			
			If Empty( cNameExp )
				cNameExp := ( cCpTabel+"_MSEXP" )
			EndIf
				
			If Empty( cNameHrExp )
				cNameHrExp := ( cCpTabel+"_HREXPO" )
			EndIf			
								
			DbSelectArea( cTabela )
			DbSetOrder( 1 ) 
			
			While !( ( cAliasQry )->( Eof() ) )
									
				//-----------------------------------------------------------
				// Insere data e hora para registros sem dados de exporta�ao
				//-----------------------------------------------------------
				If Empty( ( cAliasQry )->&( cNameExp ) ) 
					nRecno := ( cAliasQry )->&( cNameRec )
					( cTabela )->( DbGoTo( nRecno ) )//R_E_C_N_O_ )
					Reclock( cTabela, .F. )
						( cTabela )->&( cCpTabel+"_MSEXP" ) := DtoS( dDatabase )
						( cTabela )->&( cCpTabel+"_HREXPO" ) := Time()	
					(cTabela)->(MsUnLock())
				EndIf
				
				( cAliasQry )->( DbSkip() )
			EndDo
							
			( cAliasQry )->( DbCloseArea() )
	
			//-------------------------------------------------------------------
			// Ap�s a Exporta��o, grava o controle da exporta��o na tabela (AIR)
			//-------------------------------------------------------------------
			DbSelectArea( "AIR" ) //Controle de Exporta��es
			DbSetOrder( 2 ) // AIR_FILIAL+AIR_CODINT+AIR_TAG+AIR_TABELA                                                                                                                         
			If DbSeek( xFilial( "AIR" ) + cCodInt + cTag + cTabela )			                                                                                                                               
				RecLock( "AIR", .F. )
					AIR->AIR_MSEXP  := DtoS( dDataBase )		
					AIR->AIR_HREXPO := Time()
			Else
				RecLock( "AIR", .T. )
					AIR->AIR_FILIAL := xFilial( "AIR" )
					AIR->AIR_CODIGO := GetSx8Num( "AIR", "AIR_CODIGO" )
					AIR->AIR_CODINT := AIP->AIP_CODIGO
					AIR->AIR_TAG	  := cTag
					AIR->AIR_TABELA := cTabela 			 
					AIR->AIR_MSEXP  := DtoS( dDataBase )		
					AIR->AIR_HREXPO := Time()
				MsUnlock()
				ConfirmSX8()
			EndIf
					
		End Transaction
	EndIf
EndIf

RestArea( aAreaAIR )
RestArea( aAreaAIP )
RestArea( aArea )

Return( lRet )

//----------------------------------------------------------------------------
/*/{Protheus.doc} Ft802FilQry

Retona filtro para ser utilizado em queries que retornam apenas 
registros alterados, ou seja, registros cujo campo "_MSEXP" esteja vazio ou 
que a data+hora contida seja maior que a data+hora da ultima integra��o. 

@param cCodInt		- C�digo da intgra��o conforme tabela AIP.
@param cTag		- Sequ�ncial composto de 4 caracteres, utilizado para
					   compor a chave em caso de exporta��o para a mesma tabela
					   na mesma integra��o com regras diferentes.
@param cTabela		- Tabela Principal de Exporta��o.  

@return cFilQry - Retorna o filtro da query
 
@author Thamara Villa Jacomo
@since 20/02/2015
/*/
//-----------------------------------------------------------------------------
Function Ft802FilQry( cCodInt, cTag, cTabela )

Local aArea 	 := GetArea() 
Local cHrExpo  := ""
Local cFilQry  := ""
Local cExpo    := ""
Local cCpTabel := Iif( SubStr( cTabela, 1, 1 ) == "S", SubStr( cTabela, 2, 3), cTabela )
 
DbSelectArea( "AIR" )// Controle de Exporta��o
DbSetOrder( 2 )// AIR_FILIAL+AIR_CODINT+AIR_TABELA
If DbSeek( xFilial( "AIR" ) + cCodInt + cTag + cTabela )
	cExpo 	 := AIR->AIR_MSEXP  
	cHrExpo := AIR->AIR_HREXPO
	cFilQry := " AND " +cCpTabel+ "_MSEXP = '' OR " +cCpTabel+ "_MSEXP || " +cCpTabel+ "_HREXPO > '"+cExpo+cHrExpo+"' 
EndIf  

RestArea( aArea )

Return( cFilQry )

//-------------------------------------------------------------------
/*/{Protheus.doc} Ft802Exemplo

Fonte de exemplo para utiliza��o da rotina de Controle de Exporta��o.

@return lRet - Retorna se a exporta��o foi efetuada com sucesso.
 
@author Thamara Villa Jacomo
@since 20/02/2015
/*/
//-------------------------------------------------------------------
User Function Ft802Exemplo()

Local cQuery  	:= ""
Local cAliasQry	:= GetNextAlias()
Local cLinha		:= ""   
Local cFile   	:= "C:\Exportacao.txt"
Local nHandle 	:= 0
Local lRet			:= .T.

If ( nHandle := fCreate( cFile ) ) > 0

	cQuery := "Select B1_COD, B1_CODBAR, B1_DESC, B1_UM, "
	cQuery += "       B1_PROC, B1_LOJPROC, B1_TIPO, B1_GRUPO, "
	cQuery += "       B1_USERLGI, B1_USERLGA, R_E_C_N_O_ AS NUMREC, B1_MSEXP, B1_HREXPO "
	cQuery += "  From " + RetSqlName('SB1') + " SB1 "
	cQuery += " Where D_E_L_E_T_ <> '*' " 
	cQuery += " Order by B1_COD "
	
	cQuery := ChangeQuery( cQuery )

	If Select( cAliasQry ) > 0
		DbSelectArea( cAliasQry )
		DbCloseArea()
	EndIf
					
	DbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .T., .T. )
	
	While !( cAliasQry )->( Eof() )
	
		cLinha += AllTrim( ( cAliasQry )->B1_COD )
		cLinha += ";"
		cLinha += If( !Empty( ( cAliasQry )->B1_CODBAR ), AllTrim( ( cAliasQry )->B1_CODBAR ), "NULO" )
		cLinha += ";"
		cLinha += AllTrim( ( cAliasQry )->B1_DESC )
		cLinha += ";"
		cLinha += AllTrim( ( cAliasQry )->B1_UM )
		cLinha += ";"
		cLinha += AllTrim( ( cAliasQry )->B1_PROC )
		cLinha += ";"
		cLinha += AllTrim( ( cAliasQry )->B1_LOJPROC )
		cLinha += ";"
		cLinha += AllTrim( ( cAliasQry )->B1_TIPO )
		cLinha += ";"
		cLinha += AllTrim( ( cAliasQry )->B1_GRUPO )
		
		cLinha := Left( cLinha, Len( cLinha ) -1 )
		cLinha += CRLF
		
		( cAliasQry )->( DbSkip() )
	
	EndDo
		
	//--------------------------------------------------------------------------------------------------------
	// 							Rotina que faz o controle da Exporta��o.
	//--------------------------------------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------------------------------------
	// Par�metro|   Status    |   Conte�do 
	//----------|-------------|-------------------------------------------------------------------------------
	// cCodInt  |	Obrigat�rio |(Precisa ser previamente cadastrado na tabela AIP - Cadastro de Integra��es ).
	// cTag     |	Obrigat�rio |(C�digo sequ�ncial para composi��o de chave definido pela rotina chamadora).
	// cTabela  |	Obrigat�rio |(Tabela principal da Query).
	// cQuery   |	Obrigat�rio |(Query dos dados a serem exportados).
	// cNameExp |	  Opcional  |(Nome do alias atribu�do ao R_E_C_N_O_, caso exista).
	//cNameHrExp|	  Opcional  |(Nome do alias atribu�do ao campo _MSEXP, caso exista).
	// cNameRec |	  Opcional  |(Nome do alias atribu�do ao campo _HREXPO, caso exista).
	//---------------------------------------------------------------------------------------------------------	
	If Ft802Expo( /*cCodInt*/"000001", /*cTag*/"0001",/*cTabela*/"SB1", cQuery, /*cNameRec*/"NUMREC", /*cNameExp*/, /*cNameHrExp*/ )
		fWrite( nHandle, cLinha )
	Else	 
		Help( ,, 'Help',, "Houve problemas com a grava��o do log do arquivo. Por favor, verifique os par�metros informados.", 1, 0 )
		lRet := .F.
	EndIf		
	
	( cAliasQry )->( DbCloseArea() )

fClose(nHandle) 

EndIf
	
Return( lRet )
