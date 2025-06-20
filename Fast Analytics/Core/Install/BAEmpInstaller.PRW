#INCLUDE "BADEFINITION.CH"
#INCLUDE "BAEMPINSTALLER.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BAEmpInstaller
Classe respons�vel por efetuar a instala��o do FAST ANALYTICS para empresa.

@author  Helio Leal
@since   12/04/2018
/*/
//-------------------------------------------------------------------
Class BAEmpInstaller From BAInstaller 
	Method New() CONSTRUCTOR
	Method Init()
	Method RunEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo contrutor.

@Return Self, Inst�ncia da Classe. 

@author  Helio Leal
@since   12/04/2018
/*/
//-------------------------------------------------------------------
Method New() Class BAEmpInstaller
Return _Super:New()

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Inicia o processo de instala��o. 

@param, aApp, array, �rea selecionadas para instala��o.

@Return lSuccess, True para quando a execu��o do m�todo n�o houve erros, caso contr�rio False.

@author  Helio Leal
@since   31/08/2017
/*/
//-------------------------------------------------------------------
Method Init( aApp, aCompany ) Class BAEmpInstaller
    Local lSuccess := .F.
    
    If Len( aCompany ) > 0
    	If ( BATruncate() )
	    	aSort( aCompany )
	
	    	lSuccess := ::RunEntities( aCompany, aApp )
    	EndIf
    Else
    	ConOut(I18n( "BAEmpInstaller:Init: #1" , { STR0001 } ) ) // " N�o houve o retorno das empresas"
    EndIf
Return lSuccess

//-------------------------------------------------------------------
/*/{Protheus.doc} RunEntities
Executa todos os fontes cadastrados para instala��o.

@param, aCompany, array, vetor de empresas.
@param, aApp, array, �rea selecionadas para instala��o.

@Return lSuccess, True para quando a execu��o do m�todo n�o houve erros, caso contr�rio False.

@author  Helio Leal
@since   01/09/2017
/*/
//-------------------------------------------------------------------
Method RunEntities( aCompany, aApp ) Class BAEmpInstaller
	Local nCompany     := 0
	Local nEntity      := 0
	Local nApp         := 0
	Local aAppEntity   := {}
	Local oEntity      := Nil
	Local lSuccess     := .T.
	Local nStatusQuery := 0
		
	Default aCompany := {}
	Default aApp     := {}
	
	//--------------------------------------------------
	// Fontes das entidades por apps selecionados
	//--------------------------------------------------
	aAppEntity := BAAppEntity( aApp )
	
	//--------------------------------------------------
	// Instala��o dos Apps selecionados por empresa
	//--------------------------------------------------
	For nCompany := 1 To Len( aCompany )
		If aCompany[nCompany][1]
		
			Conout(replicate("-", 50))
			ConOut(I18n( "RunEntities: #1 #2 - #3" , { STR0002, aCompany[nCompany][2], aCompany[nCompany][3] } ) ) // "Executando o processo para a empresa "
	
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
			RPCSetEnv( aCompany[nCompany][2] )
	
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
							nStatusQuery := BARecordEntity( oEntity, aCompany[nCompany][2] )
	
							BASaveAppEntity( aAppEntity[nApp][1], oEntity:cEntity )
	
							oEntity:Destroy()
							oEntity := Nil
						EndIf
	
						If nStatusQuery > 0
							lSuccess := .F.
							::nStatus := nStatusQuery
	
						EndIf
	
					Next nEntity
				Next nApp	
	
				RpcClearEnv()
	
				ConOut(I18n( "RunEntities: #1 #2 - #3" , { STR0003, aCompany[nCompany][2], aCompany[nCompany][3] } ) ) // " Fim do processo para a empresa "
				Conout(replicate("-", 50))	
			Else
				conout(I18n( "RunEntities: #1", {STR0004} )) // "N�o h� entidades cadastradas." 
				lSuccess := .F.
			EndIf
		EndIf	
	Next nCompany 	
	
Return lSuccess