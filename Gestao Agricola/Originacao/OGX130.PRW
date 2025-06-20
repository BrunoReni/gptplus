#Include 'OGX130.ch'
#Include 'Protheus.ch'

/**{Protheus.doc} OGX130
Valida��o na Inclus�o de T�tulos a receber
garantindo que o t�tulo a ser incluso j� n�o exista
e tamb�m que esteja amarrado a um contrato.
@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	03/05/2013
@Uso: 		SIGAFIN - Financeiro
@Alterado Por: Marcelo R. Ferrari
Alterado em: 19/08/2014
**/
//Programa Original: ARMXPE14.PRW

Function OGX130()
Local lRetorno 	:= .T.
	If FindFunction("OGXUTOG") //Encontra a fun��o
		If OGXUTOG()
			If FindFunction("OGX130A")
				lRetorno := OGX130A()
			Endif
		Endif 
	EndIf	
Return( lRetorno )


/*/{Protheus.doc} OGX130VLDA
    fun��o que realiza a valida��o da RA se permite ou n�o realizar a baixa no FINA040
    @type  Function
    @author filipe.olegini
    @since 15/06/2018
    @version 1.0
    @param cFilOrig, Char, Filial de origem (E1_FILORIG) do titulo
    @param cPrefixo, Char, Prefixo do titulo
    @param cNum, Char, numero do titulo
    @param cTipo, Char, tipo do titulo
    @param cParcela, Char, parcela do titulo
    @param cOpc, Char, op��o 3-inclusao / 5-exclusao
    @return lRet, Logico, True ou false 
    @see (links_or_references)
/*/
 Function OGX130VLDA(cFilOrig,cPrefixo,cNum,cTipo,cParcela, cOpc)
    Local aAreaSE1  := SE1->(GetArea())
    Local lRet      := .T.

    lRet := OGX130QRY(cFilOrig,cPrefixo,cNum,cTipo,cParcela)

    RestArea(aAreaSE1)

Return lRet

/*/{Protheus.doc} OGX130VLDB
    fun��o que realiza a valida��o da RA se permite ou n�o realizar a baixa no FINA070
    @type  Function
    @author filipe.olegini
    @since 15/06/2018
    @version 1.0
    @param cFilOrig, Char, Filial de origem (E1_FILORIG) do titulo
    @param cPrefixo, Char, Prefixo do titulo
    @param cNum, Char, numero do titulo
    @param cTipo, Char, tipo do titulo
    @param cParcela, Char, parcela do titulo
    @param cOpc, Char, op��o 3-inclusao / 5-exclusao
    @return lRet, Logico, True ou false 
    @see (links_or_references)
/*/
 Function OGX130VLDB(cFilOrig,cPrefixo,cNum,cTipo,cParcela, cOpc)
    Local aAreaSE1  := SE1->(GetArea())
    Local lRet      := .T.

    lRet := OGX130QRY(cFilOrig,cPrefixo,cNum,cTipo,cParcela)

    RestArea(aAreaSE1)

Return lRet

/*/{Protheus.doc} OGX130VLDC
    fun��o que realiza a valida��o da RA se permite ou n�o realizar a baixa no FINA330
    @type  Function
    @author filipe.olegini
    @since 15/06/2018
    @version 1.0
    @param cFilOrig, Char, Filial de origem (E1_FILORIG) do titulo
    @param cPrefixo, Char, Prefixo do titulo
    @param cNum, Char, numero do titulo
    @param cTipo, Char, tipo do titulo
    @param cParcela, Char, parcela do titulo
    @param cOpc, Char, op��o 3-inclusao / 5-exclusao
    @return lRet, Logico, True ou false 
    @see (links_or_references)
/*/
 Function OGX130VLDC(cFilOrig,cPrefixo,cNum,cTipo,cParcela, cOpc)
    Local aAreaSE1  := SE1->(GetArea())
    Local lRet      := .T.

    lRet := OGX130QRY(cFilOrig,cPrefixo,cNum,cTipo,cParcela)

    RestArea(aAreaSE1)

Return lRet

/*/{Protheus.doc} OGX130QRY
    fun��o que realiza a q query para verificar o vinculo
    Chamado no FINA330
    @type  Function
    @author filipe.olegini
    @since 15/06/2018
    @version 1.0
    @param cFilOrig, Char, Filial de origem (E1_FILORIG) do titulo
    @param cPrefixo, Char, Prefixo do titulo
    @param cNum, Char, numero do titulo
    @param cTipo, Char, tipo do titulo
    @param cParcela, Char, parcela do titulo
    @return lRet, Logico, True ou false 
    @see (links_or_references)
/*/
 Static Function OGX130QRY(cFilOrig,cPrefixo,cNum,cTipo,cParcela)
    Local cAliasN9G := GetNextAlias()
    Local lRet      := .T.
    Local cQuery    := ""

     //busca a RA vinculada atrav�s da N9G
    cQuery := " SELECT N9G_FILTIT "
    cQuery +=   " FROM " + RetSqlname("N9G") 
    cQuery +=   " WHERE D_E_L_E_T_ = '' "
    cQuery +=     " AND N9G_FILTIT = '" + cFilOrig + "'"
    cQuery +=     " AND N9G_PREFIX = '" + cPrefixo + "'"
    cQuery +=     " AND N9G_NUM    = '" + cNum + "'"
    cQuery +=     " AND N9G_TIPO   = '" + cTipo + "'"
    cQuery +=     " AND N9G_PARTT  = '" + cParcela + "'"

    cQuery := ChangeQuery( cQuery )

    If Select(cAliasN9G) <> 0
        (cAliasN9G)->(dbCloseArea())
    EndIf
        
    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasN9G,.T.,.T.)        
        
    //se encontrar retorna false pois essa RA est� sendo utilizada no AGRO
    If (cAliasN9G)->(!EOF())
        lRet := .F.
    EndIf

    (cAliasN9G)->(dbCloseArea())

Return lRet
 
