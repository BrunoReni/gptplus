Function ConsEstOnLine(cCodProd)
/*
Local nCon    := 0
Local cFunc   := "U_HHESTON" 
Local cRetRpc := ""
If !Empty(cCodProd)
	// Faz a Conexao com o Servidor
	nCon := connectserver()

	If nCon != 0
		// Executa a funcao do Protheus
		cRetRpc := rpcprotheus( nCon , cFunc , cCodProd)
		// Diconecta do Servidor
		disconnectserver(nCon)
		MsgAlert("Estoque = " + cRetRpc, HB1->HB1_DESCR)
	Else 
		MsgAlert("N�o foi possivel conectar ao servidor", "Conex�o")
	EndIf
Else
	MsgAlert("Digite o c�digo do produto", "Produto")
EndIf
*/
Return Nil