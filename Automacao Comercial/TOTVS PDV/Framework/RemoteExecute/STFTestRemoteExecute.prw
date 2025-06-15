#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STFTestRemoteExecute
Verifica se h� comunica��o com a Retaguarda

@param  lComCPDV - Se executa a funcao na central de PDV 	
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  lCommuOk			Retorna se a tem comunica��o com a Retaguarda
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFTestRemoteExecute( lComCPDV )

Local lCommuOk := .F.

Default lComCPDV := .F.  //Usa comunicacao com a Central de PDV 

If lComCPDV 
	//Para central de PDV executa outra funcao para testar comunicacao
	STBRemoteExecute("STFCOMMUCP", NIL , NIL, .F. , @lCommuOk )
Else
	STBRemoteExecute("STFCOMMUOK", NIL , NIL, .F. , @lCommuOk )
EndIf

Return lCommuOk


//-------------------------------------------------------------------
/*/{Protheus.doc} STFCommuOk
Fun��o executada na retaguarda

@param   
@author  Vendas & CRM
@version P12
@since   29/03/2012
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFCommuOk()

// Se chegou aqui a comunica��o est� ok, retorna .T.

Return .T.
            

//-------------------------------------------------------------------
/*/{Protheus.doc} STFCommuCP
Fun��o executada na Central de PDV para verificar se esta Ativa
@param   
@author  Vendas & CRM
@version P12
@since   20/08/2013
@return  
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFCommuCP()

// Se chegou aqui a comunica��o est� ok, retorna .T.

Return .T.

