#INCLUDE "BCDEFINITION.CH"
#INCLUDE "BCEMPINSTALLER.CH"

#DEFINE LIMIT_QUERY_PER_VIEW 5

//-------------------------------------------------------------------
/*/{Protheus.doc} BCEmpInstaller
Classe responsavel por efetuar a  instalacao da Carol para empresa.

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Class BCEmpInstaller From BCInstaller 
	Method New() CONSTRUCTOR
	Method Init()
	Method RunEntities()
	Method AddViewControl()
	Method CreateView()
EndClass
 
//-------------------------------------------------------------------
/*/{Protheus.doc} New
Mwtodo contrutor.

@Return Self, Instancia da Classe. 

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Method New() Class BCEmpInstaller
Return _Super:New()

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Inicia o processo de instalacao. 

@param, aApp, array, area selecionadas para instalacao.

@Return lSuccess, True para quando a execucao do metodo nao houve erros, caso contrario False.

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Method Init( aApp, aCompany, showWizard) Class BCEmpInstaller
	
	Local lSuccess := .F.
	
    Default aApp       := {}
	Default aCompany	:= {}
	Default showWizard := .T.

	If len(aCompany) == 0
		
		SET DELET ON

    	OpenSM0()

    	aEval( FWAllGrpCompany(), {|oComp| AAdd(aCompany, { .T., oComp, FWEmpName(oComp) }) } )
    
    	BICompanySelected(aCompany)

	EndIf

    If Len( aCompany ) > 0
    	If ( BCTruncate() )
	    	aSort( aCompany )
	
	    	lSuccess := ::RunEntities( aCompany, aApp, showWizard )
			
	    	
	    	::AddViewControl()
	    		
	    	::CreateView()
	    	
	    	RpcClearEnv()
	    	
    	EndIf
    Else
    	ConOut(I18n( "BCEmpInstaller:Init: #1" , { STR0001 } ) ) // " Nao houve o retorno das empresas"
    EndIf
Return lSuccess

//-------------------------------------------------------------------
/*/{Protheus.doc} RunEntities
Executa todos os fontes cadastrados para instalacao.

@param, aCompany, array, vetor de empresas.
@param, aApp, array, area selecionadas para instalacao.

@Return lSuccess, True para quando a execucao do metodo nao houve erros, caso contrario False.

@author  Andreia Lima
@since   23/04/2019
/*/
//-------------------------------------------------------------------
Method RunEntities( aCompany, aApp, showWizard ) Class BCEmpInstaller
	Local nCompany		:= 0
	Local nI			:= 0
	Local nEntity      := 0
	Local nApp         := 0
	Local aAppEntity   := {}
	Local oEntity      := Nil
	Local lSuccess     := .T.
	Local nStatusQuery := 0
	Local nReg			:=0
	Local aAllCompany	:= BCLoadComp()
		
	Default aCompany   := {} 
	Default aApp       := {}
	Default showWizard := .T.
	
	//--------------------------------------------------
	// Fontes das entidades por apps selecionados
	//--------------------------------------------------
	aAppEntity := BCAppEntity( aApp )

	//--------------------------------------------------
	// Wizard da Controladoria
	//--------------------------------------------------
	IF (ASCAN(aApp, {|x| x:capp == 'Controladoria'} ) > 0) .And. showWizard
		bcwizard(aCompany)
	ENDIF
	//--------------------------------------------------
	// Instalacao dos Apps selecionados por empresa
	//--------------------------------------------------

	// Readequa aCompany para criacao correta das views
	For nI :=1 to Len(aCompany)
		If aCompany[nI][1]
			For nCompany := 1 To Len(aAllCompany)
				If aCompany[nI][2]==aAllCompany[nCompany][2]
					aAllCompany[nCompany][1]:=aCompany[nI][1]
				EndIf
			Next
		EndIf
	Next
	aCompany := {}
	For nCompany := 1 To Len(aAllCompany)
		If (aAllCompany[nCompany][4]) .OR. (aAllCompany[nCompany][1])
			aAdd(aCompany,aAllCompany[nCompany])
			nReg++
		EndIf
	Next

	if GetRemoteType() != -1
		oProcess:IncRegua1("Criando Views")

		oProcess:SetRegua2(nReg)
		ProcessMessage()
	EndIf
	For nCompany := 1 To Len( aCompany )

		RpcClearEnv()
		// oProcess:IncRegua2(Iif(aCompany[nCompany][4],"Readequando","Criando")+" views para a empresa "+aCompany[nCompany][2])
		If GetRemoteType() != -1
			oProcess:IncRegua2("Preparando views para a empresa "+aCompany[nCompany][2])
		EndIf
		Conout(replicate("-", 50))
		ConOut(I18n( "RunEntities: #1 #2" , { STR0002, aCompany[nCompany][2] } ) ) // "Executando o processo para a empresa "

		//------------------------------------------------------------------------------
		// Ambiente preparado somente com SX2 (Nao necessita abrir ambiente completo).
		//------------------------------------------------------------------------------
		// RPCSetType( 3 )
		RPCSetEnv( aCompany[nCompany][2] )
	
		BCProcessTable()
		BCAppTable()
		BCAppEntTable()
		
		If Len( aAppEntity ) > 0
		
			For nApp := 1 To Len( aAppEntity )
				BCSaveApp( aAppEntity[nApp][1] )
		
				For nEntity := 1 To Len( aAppEntity[nApp][2] )
					//-------------------------------------------------------------------
					// Instancia cada entidade.
					//-------------------------------------------------------------------
					oEntity	:= BIClass( aAppEntity[nApp][2][nEntity] )
	
					If ! ( Empty( oEntity ) )						
						nStatusQuery := BCRecordEntity( oEntity, aCompany[nCompany][2] )

						BCSaveAppEntity( aAppEntity[nApp][1], oEntity:cEntity )

						oEntity:Destroy()
						oEntity := Nil
					EndIf

					If nStatusQuery > 0
						lSuccess := .F.
						::nStatus := nStatusQuery

					EndIf

				Next nEntity
			Next nApp	

			ConOut(I18n( "RunEntities: #1 #2" , { STR0003, aCompany[nCompany][2] } ) ) // " Fim do processo para a empresa "
			Conout(replicate("-", 50))	

			// If nCompany < Len( aCompany )
			// 	RpcClearEnv()
			// EndIf
			

		Else
			conout(I18n( "RunEntities: #1", {STR0004} )) // "Nao ha entidades cadastradas." 
			lSuccess := .F.
		EndIf
		
	Next nCompany 

	// RPCSetType( 3 )
	// RPCSetEnv( aCompany[1][2] )	
	
Return lSuccess


//-------------------------------------------------------------------
/*/{Protheus.doc} AddViewControl
Cria as view intermediarias de controle, ou a view final, caso existam poucas empresas

@param, aCompany, array, vetor de empresas.
@param, aApp, array, area selecionadas para instalacao.

@Return lSuccess, True para quando a execucao do metodo nao houve erros, caso contrario False.

@author  Marcia Junko
@since   16/09/2019
/*/
//-------------------------------------------------------------------
Method AddViewControl( ) Class BCEmpInstaller
	Local cDDL 		:= ""
	Local cView		:= ""
	Local cEntity	:= ""
	Local cQuery	:= ""
	Local cViewName := ""
	Local cTempAlias := GetNextAlias()
	Local cAuxAlias := GetNextAlias()
	Local nEntCount	:= 0
	Local nCount	:= 0
	Local nSeqView	:= 0
	Local nStatus   := 0
	Local lCreateView := .F.
	Local aSM0 		:= {}

	aSM0 := FWLoadSM0()
		
	cDDL := "SELECT I10_ENTITY AS ENTITY, I10_EMPRES AS INSTALL_COMPANY, R_E_C_N_O_ AS ID FROM I10 WHERE D_E_L_E_T_ = ' ' ORDER BY I10_USEVW, I10_ENTITY, I10_EMPRES"
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cDDL ), cTempAlias , .T., .F. )

	While (cTempAlias)->( !EoF() )
	//Condição criada para tratar a criação das view das tabelas que nao serao criadas
		If Alltrim(( cTempAlias )->ENTITY) $ "Centrocusto|Dre|Balance|Ccusto_Day|Itemcontabil|Itemc_Day|Classevalor|Clvalor_Day"
			(cTempAlias)->(DbSkip())
		Endif
		// Somente considera no fluxo views de empresas validas
		If ( AScan( aSM0, {|x| x[1] == Alltrim( ( cTempAlias )->INSTALL_COMPANY ) } ) > 0 ) .Or. ;
			( Alltrim( ( cTempAlias )->ENTITY ) $ 'Empresa|Filial' )
			IF Upper((cTempAlias)->ENTITY) != cEntity .Or. lCreateView
				nEntCount := BCCountEnt( ( cTempAlias )->ENTITY, aSM0, cAuxAlias )
				
				If Empty(cEntity)
					cEntity :=  Upper((cTempAlias)->ENTITY )
					If nEntCount <= LIMIT_QUERY_PER_VIEW
						cViewName := "CAROL_" + Upper(cEntity)
					Else
						nSeqView++
						cViewName := "CAROL_" + Upper(Alltrim(cEntity)) + "_SQ" + StrZero( nSeqView, 2 )
					EndIf
				EndIf

				If !Empty( cView )
					nStatus := BCCreateView( cView, cViewName )
					cView := ""
					IF Upper((cTempAlias)->ENTITY) != cEntity
						nSeqView := 0
					EndIf
					lCreateView := .F.

					If nEntCount <= LIMIT_QUERY_PER_VIEW
						cViewName := "CAROL_" + Upper((cTempAlias)->ENTITY )
					Else
						nSeqView++
						cViewName := "CAROL_" + Upper(Alltrim((cTempAlias)->ENTITY )) + "_SQ" + StrZero( nSeqView, 2 )
					EndIf

					nCount := 0
				EndIf
			EndIf
		
			nCount++

			If nEntCount <= LIMIT_QUERY_PER_VIEW .Or. nCount <= LIMIT_QUERY_PER_VIEW
				cQuery := BCRetQuery( (cTempAlias)->ID )
				
				If !Empty(cQuery)
					If !Empty( cView )
						cView += " UNION ALL "
					EndIf
					cView += cQuery
				Endif
				
				If nCount == LIMIT_QUERY_PER_VIEW
					lCreateView := .T.
				EndIf
			Else
				lCreateView := .T.
			EndIf

			BCUpdVwName( (cTempAlias)->ID, cViewName )
		
			cEntity := Upper((cTempAlias)->ENTITY)
		EndIf
		(cTempAlias)->(DbSkip())
	EndDo

	If !Empty( cView )
		nStatus := BCCreateView( cView, cViewName )
	EndIf

	(cTempAlias)->(DbCloseArea())

Return (nStatus == 0)


//-------------------------------------------------------------------
/*/{Protheus.doc} CreateView
Cria a view que sera utilizada pela Carol, caso haja Views temporarias.

@param, aCompany, array, vetor de empresas.
@param, aApp, array, area selecionadas para instalacao.

@Return lSuccess, True para quando a execucao do metodo nao houve erros, caso contrario False.

@author  Marcia Junko
@since   16/09/2019
/*/
//-------------------------------------------------------------------
Method CreateView( ) Class BCEmpInstaller
	Local cDDL 		:= ""
	Local cView		:= ""
	Local cEntity	:= ""
	Local cViewName := ""
	Local cIdentify := ""
	Local cTempAlias := GetNextAlias()
	Local nStatus	:= 0
	
	cDDL := "SELECT I10_ENTITY AS ENTITY, I10_VIEW AS NAME FROM I10 WHERE D_E_L_E_T_ = ' ' ORDER BY I10_USEVW, I10_ENTITY, I10_EMPRES"
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, cDDL ), cTempAlias , .T., .F. )
	
	While (cTempAlias)->(! EoF() )
		If "_SQ" $ Right( Upper(Alltrim((cTempAlias)->NAME)), 5) 
			IF Upper(Alltrim((cTempAlias)->ENTITY)) != cEntity
				If Empty(cEntity)
					cEntity :=  Upper(Alltrim((cTempAlias)->ENTITY ))
				EndIf
	
				cViewName := "CAROL_" + cEntity
	
				If !Empty( cView )
					nStatus := BCCreateView( cView, cViewName )
					cView := ""
				EndIf
			EndIf
						
			If Upper(Alltrim((cTempAlias)->NAME)) != cIdentify 
				If !Empty( cView )
					cView += " UNION ALL "
				EndIf
				cView += "SELECT * FROM " + Alltrim((cTempAlias)->NAME) + " "				
			EndIf								
		
			cEntity := Upper(Alltrim((cTempAlias)->ENTITY))
			cIdentify := Upper(Alltrim((cTempAlias)->NAME))			
		EndIf

		(cTempAlias)->(DbSkip())
	EndDo
	
	If !Empty( cView )
		nStatus := BCCreateView( cView, "CAROL_" + cEntity )
	EndIf

	(cTempAlias)->(DbCloseArea())

Return (nStatus == 0)


