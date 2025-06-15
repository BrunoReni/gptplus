#INCLUDE "TOTVS.CH"

Static _lPcpRevAt := FindFunction('PCPREVATU') .AND. SuperGetMv("MV_REVFIL",.F.,.F.)

/*/{Protheus.doc} VersionPrd
Busca a revis�o que dever� ser utilizada, de acordo com o cadastro da vers�o
da produ��o do produto na tabela SVC.

@type  Function
@author lucas.franca
@since 16/05/2019
@version P12.1.25
@param cProduto , Caracter, C�digo do produto
@param nQuant   , Numeric , Quantidade a ser produzida
@param dData    , Date    , Data de produ��o.
@return cRevisao, Caracter, Revis�o que dever� ser utilizada na produ��o.
/*/
Function VersionPrd(cProduto, nQuant, dData)
	Local cRevisao := ""
	Local cQuery   := ""
	Local cAlias   := GetNextAlias()

	cQuery := " SELECT SVC.VC_REV "
	cQuery +=   " FROM " + RetSqlName("SVC") + " SVC "
	cQuery +=  " WHERE SVC.VC_FILIAL  = '" + xFilial("SVC") + "' "
	cQuery +=    " AND SVC.VC_PRODUTO = '" + cProduto + "' "
	cQuery +=    " AND " + cValToChar(nQuant) + " BETWEEN SVC.VC_QTDDE AND SVC.VC_QTDATE "
	cQuery +=    " AND (SVC.VC_DTINI  = ' ' OR SVC.VC_DTINI <= '" + DtoS(dData) + "') "
	cQuery +=    " AND (SVC.VC_DTFIM  = ' ' OR SVC.VC_DTFIM >= '" + DtoS(dData) + "') "
	cQuery +=    " AND SVC.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	If (cAlias)->(!Eof())
		//Encontrou vers�o de produ��o na tabela SVC, ir� utilizar a revis�o cadastrada.
		cRevisao := (cAlias)->(VC_REV)
	Else
		//N�o encontrou vers�o de produ��o, ir� utilizar a revis�o atual do produto.
		If _lPcpRevAt
			cRevisao := PCPREVATU(cProduto)
		Else
			SB1->(dbSetOrder(1))
			SB1->(dbSeek(xFilial("SB1")+cProduto))
			cRevisao := SB1->B1_REVATU
		EndIf
	EndIf
	(cAlias)->(dbCloseArea())

Return cRevisao
