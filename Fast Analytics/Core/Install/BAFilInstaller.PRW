#INCLUDE "BADEFINITION.CH"
#INCLUDE "BAFILINSTALLER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BAFilInstaller
Classe respons�vel pela instala��o do FAST ANALYTICS por filial.

@author  Andr�ia Lima
@since   12/04/2018
/*/
//-------------------------------------------------------------------
Class BAFilInstaller From BAInstaller 
	Method New() CONSTRUCTOR
	Method Init()
	Method RunEntities()
	Method GetCompanyFilial()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo contrutor.

@Return Self, Inst�ncia da Classe. 

@author  Andr�ia Lima
@since   12/04/2018
/*/
//-------------------------------------------------------------------
Method New() Class BAFilInstaller
Return _Super:New()

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Inicia o processo de instala��o. 

@param, aApp, array, �rea selecionadas para instala��o.

@Return lSuccess, True para quando a execu��o do m�todo n�o houve erros, caso contr�rio False.

@author  Andr�ia Lima
@since   12/04/2018
/*/
//-------------------------------------------------------------------
Method Init( aApp, aCompany ) Class BAFilInstaller
    Local aFilial  := {}
    Local aFilAux  := {}
    Local nFilAux  := 0
    Local lSuccess := .F.
    
    aFilAux := FWLoadSM0()  
    
    For nFilAux := 1 to len(aFilAux)
    	If Ascan( aCompany, {|x| x[2] == aFilAux[nFilAux][1] .And. x[1] == .T.}) > 0
    		Aadd( aFilial, aClone(aFilAux[nFilAux]))
    	EndIf
    Next
    
    If Len( aFilial ) > 0
    	If ( BATruncate() )
    		lSuccess := ::RunEntities( aFilial, aApp )
    	EndIf
    Else
    	ConOut(I18n( "BAFilInstaller:Init: #1" , { STR0001 } ) ) // " N�o houve o retorno das filiais"
    EndIf
Return lSuccess

//-------------------------------------------------------------------
/*/{Protheus.doc} RunEntities
Executa todos os fontes cadastrados para instala��o.

@param, aFilial, array, vetor de filiais.
@param, aApp, array, �rea selecionadas para instala��o.

@Return lSuccess, True para quando a execu��o do m�todo n�o houve erros, caso contr�rio False.

@author  Andr�ia Lima
@since   12/04/2018
/*/
//-------------------------------------------------------------------
Method RunEntities( aFilial, aApp ) Class BAFilInstaller
	Local nFilial      := 0
	Local nCompany     := 0
	Local nEntity      := 0
	Local nApp         := 0
	Local nStatusQuery := 0	
	Local aAppEntity   := {}
	Local aCompany     := {}
	Local lSuccess     := .T.
	Local oEntity      := Nil	
		
	Default aFilial  := {}
	Default aApp     := {}
	
	//--------------------------------------------------
	// Fontes das entidades por apps selecionados
	//--------------------------------------------------
	aAppEntity := BAAppEntity( aApp )
	
	aCompany := ::GetCompanyFilial( aFilial )

	//------------------------------------------------------
	// Instala��o dos Apps selecionados por empresa\filial
	//------------------------------------------------------
	For nCompany := 1 To Len( aCompany )
		
		Conout( replicate( "-", 50 ) )
		Conout( I18n( STR0003 + aCompany[nCompany][1] ) ) //"RunEntities: Executando o processo para a empresa "
	
		For nFilial := 1 To Len( aCompany[nCompany][2] )
		
			Conout( replicate( "-", 50 ) )
			Conout( I18n( STR0002 + aCompany[nCompany][2][nFilial] ) ) //"Filial "
			
			//------------------------------------------------------------------------------
			// Ambiente preparado somente com SX2 (N�o necessita abrir ambiente completo).
			//------------------------------------------------------------------------------
			RPCSetType( 3 )
			/* TO DO
			 	No fonte BAParser foi utilizado a fun��o FWModeAccess que n�o usa somente
			 	SX2, ent�o teve que ser carregado o ambiente inteiro, o que deixar o processo mais 
			 	lento, tentamos XX8 e XX9, por�m n�o adiantou e a fun��o n�o retorna correto.
			 	Necess�rio verificar quais tabela FWModeAccess utiliza para adicionar no array
			 	do RPCSetEnv.
			*/ 
			// RPCSetEnv( aCompany[nCompany], "",,,,, {"SX2", "XX8", "XX9"},,, .F.)
			RPCSetEnv( aCompany[nCompany][1], aCompany[nCompany][2][nFilial] )
	
			//-------------------------------------------------------------
			// Caso as tabelas I01, I02 e I03 n�o estejam abertas, as abre.
			//-------------------------------------------------------------
			BAProcessTable()
			BAAppTable()
			BAAppEntTable()
		
			If Len( aAppEntity ) > 0 
			
				For nApp := 1 To Len( aAppEntity )
					BASaveApp( aAppEntity[nApp][1] )
			
					For nEntity := 1 To Len( aAppEntity[nApp][2] )
						//-------------------------------------------------------------------
						// Inst�ncia cada entidade.
						//-------------------------------------------------------------------
						oEntity	:= BAClass( aAppEntity[nApp][2][nEntity] )
		
						If ! ( Empty( oEntity ) )						
							nStatusQuery := BARecByFil( oEntity, aCompany[nCompany][1],  xFilial( oEntity:GetOrigin() ) )
	
							BASaveAppEntity( aAppEntity[nApp][1], oEntity:cEntity )
	
							oEntity:Destroy()
							oEntity := Nil
						EndIf
	
						If ( nStatusQuery > 0 )
							lSuccess := .F.
							::nStatus := nStatusQuery
						EndIf
	
					Next nEntity
				Next nApp	
	
				RpcClearEnv()
				
			Else
				ConOut(I18n( "BAFilInstaller:RunEntities: #1" , { STR0005 } ) ) // "N�o h� entidades cadastradas." 
				lSuccess := .F.
			EndIf
			
		Next nFilial

		Conout(replicate("-", 50))
		Conout( I18n( STR0004  + aCompany[nCompany][1] ) ) //"Fim do processo para a empresa # filial # "
		
	Next nCompany	
	
Return lSuccess

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCompanyFilial
Organiza as filiais por grupo de empresa.

@Return aGrupoFilial, array, Grupos de Empresas com as filiais. 

@author  Andr�ia Lima
@since   20/04/2018
/*/
//-------------------------------------------------------------------
Method GetCompanyFilial( aFilial ) Class BAFilInstaller
	Local aGrupo       := {}
	Local aGrupoFilial := {}  
	Local aAuxFilial   := {}
	Local nGrupo       := 0
	Local nFilial      := 0
	
	Default aFilial := {}
	
	Aeval( aFilial,{ |grupo| IIF( ascan( aGrupo,grupo[1] ) = 0, AAdd( aGrupo,  grupo[1] ), .F. ) } )

	For nGrupo := 1 To Len( aGrupo )
		//-------------------------------------------------------------
		// Separa as filiais por grupo
		//-------------------------------------------------------------
		aSize( aAuxFilial, 0 )
		For nFilial := 1 To Len ( aFilial )
			If ( aFilial[nFilial][1] == aGrupo[nGrupo] ) 
				AAdd( aAuxFilial, aFilial[nFilial][2] )
			EndIf
		Next nFilial  
		
		AAdd( aGrupoFilial, { aGrupo[nGrupo], ACLONE( aAuxFilial ) } )
	
	Next nGrupo
	
Return aGrupoFilial