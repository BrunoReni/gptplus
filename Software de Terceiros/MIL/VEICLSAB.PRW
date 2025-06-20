////////////////
// Versao 001 //
////////////////

#include "protheus.ch"

Function VEICLSAB()
Return()

/*/{Protheus.doc} DMS_BackOrder

	@author       Vinicius Gati
	@since        02/05/2014
	@description  Classe para facilitar opera��es com backorder

/*/
Class DMS_BackOrder
	Method New() CONSTRUCTOR
	Method QueryAll()
	Method QueryAllP()
	Method GetItensBO()
	Method GetStatus()
	Method InStarvation()
EndClass

/*/{Protheus.doc} New
	Construtor simples DMS_BackOrder
	@author Vinicius Gati
	@since 05/10/2015
/*/
Method New() Class DMS_BackOrder
Return SELF

/*/{Protheus.doc} QueryAll
	Busca os dados filtrando por or�amento


	@author  Vinicius Gati
	@since   05/10/2015
	@param   aDados , Array , Ser� usado como datacontainer para pegar parametros de filtro
	@example 

/*/
Method QueryAll(cFil, aDados, cTipo) Class DMS_BackOrder
	Local oParams  := DMS_DataContainer():New(aDados)
	Local oSqlHlp  := DMS_SqlHelper():New()
	Local cQuery   := " "
	Local aResults := {}
	Local cBckFil  := cFilAnt
	Local cAl      := GetNextAlias()
	
	cFilAnt := cFil

	cQuery += "   SELECT VS1.VS1_FILIAL, VS1.VS1_NUMORC, VS1.VS1_DATORC, VE6.VE6_DATREG, VE6.VE6_HORREG "
	cQuery += "     FROM "+oSqlHlp:NoLock('VE6')
	cQuery += "     JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VE6_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "    WHERE VE6.D_E_L_E_T_ = ' '  AND VE6.VE6_FILIAL = '"+xFilial('VE6')+"' "

	cQuery += " AND VE6_INDREG = '"+oParams:GetValue('VE6_INDREG', "4")+"' " // 4 - BackOrder

	If ! EMPTY(oParams:GetValue('VE6_GRUITE_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_GRUITE_ATE', ""))
		cQuery += " AND VE6_GRUITE >= '"+oParams:GetValue('VE6_GRUITE_DE')+"' AND VE6_GRUITE <= '"+oParams:GetValue('VE6_GRUITE_ATE')+"' "
	ElseIf ! EMPTY(oParams:GetValue('VE6_GRUITE_DE', ""))
		cQuery += " AND VE6_GRUITE >= '"+oParams:GetValue('VE6_GRUITE_DE')+"' "
	ElseIf ! EMPTY(oParams:GetValue('VE6_GRUITE_ATE', ""))
		cQuery += " AND VE6_GRUITE <= '"+oParams:GetValue('VE6_GRUITE_ATE')+"' "
	EndIf

	If ! EMPTY(oParams:GetValue('VE6_CODITE_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_CODITE_ATE', ""))
		cQuery += " AND VE6_CODITE >= '"+oParams:GetValue('VE6_CODITE_DE')+"' AND VE6_CODITE <= '"+oParams:GetValue('VE6_CODITE_ATE')+"' "
	ElseIf ! EMPTY(oParams:GetValue('VE6_CODITE_DE', ""))
		cQuery += " AND VE6_CODITE >= '"+oParams:GetValue('VE6_CODITE_DE')+"' "
	ElseIf ! EMPTY(oParams:GetValue('VE6_CODITE_ATE', ""))
		cQuery += " AND VE6_CODITE <= '"+oParams:GetValue('VE6_CODITE_ATE')+"' "
	EndIf

	if ! EMPTY(oParams:GetValue('VS1_NUMORC', ""))
		cQuery += " AND VS1_NUMORC = '"+ oParams:GetValue('VS1_NUMORC') +"'  "
	EndIf

	cQuery += " GROUP BY VS1_FILIAL,VE6.D_E_L_E_T_,VS1_NUMORC ,VS1_DATORC ,VE6_DATREG ,VE6_HORREG "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )

	(cAl)->(DbGoTop()) // Posiciona o cursor no in�cio da �rea de trabalho ativa
	While !(cAl)->(EOF())          // Enquanto o cursor da �rea de trabalho ativa n�o indicar fim de arquivo
		cFStatus := oParams:GetValue('STATUS')
		cStatus  := self:GetStatus(xFilial('VS1'), (cAl)->VS1_NUMORC )
		If cFStatus == "TODOS" .OR. cStatus == cFStatus
			aEl := {                                   ;
				{ 'VS1_FILIAL', (cAl)->VS1_FILIAL },;
				{ 'VS1_NUMORC', (cAl)->VS1_NUMORC },;
				{ 'VS1_DATORC', (cAl)->VS1_DATORC },;
				{ 'VE6_DATREG', (cAl)->VE6_DATREG },;
				{ 'VE6_HORREG', (cAl)->VE6_HORREG },;
				{ 'STATUS'    , cStatus           } ;
			}
			oEl := DMS_DataContainer():New(aEl)
			AADD(aResults, oEl)
		EndIf

		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())

	cFilAnt := cBckFil
Return aResults

/*/{Protheus.doc} QueryAllP
	Busca os dados filtrando por pedido


	@author  Vinicius Gati
	@since   05/10/2015
	@param   aDados , Array , Ser� usado como datacontainer para pegar parametros de filtro
	@example 

/*/
Method QueryAllP(cFil, aDados, cTipo) Class DMS_BackOrder
	Local oParams  := DMS_DataContainer():New(aDados)
	Local oSqlHlp  := DMS_SqlHelper():New()
	Local cQuery   := " "
	Local cAl      := getNextAlias()
	Local aResults := {}
	Local cBckFil  := cFilAnt
	
	cFilAnt := cFil

	cQuery += "   SELECT VS1.VS1_FILIAL, VS1.VS1_NUMORC, C7_ITEM, VS1.VS1_DATORC, VE6.VE6_DATREG, VE6.VE6_HORREG "
	cQuery += "     FROM "+oSqlHlp:NoLock('VE6')
	cQuery += "     JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VE6_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "     JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VE6_CODITE AND B1_GRUPO   = VE6_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "LEFT JOIN "+oSqlHlp:NoLock('SC7')+" ON C7_FILIAL  = '"+xFilial('SC7')+"' AND VE6_PEDCOM = C7_NUM     AND C7_ITEM    = B1_COD     AND SC7.D_E_L_E_T_ = ' ' "
	cQuery += "    WHERE VE6.D_E_L_E_T_ = ' '  AND VE6.VE6_FILIAL = '"+xFilial('VE6')+"' "

	cQuery += " AND VE6_INDREG = '"+oParams:GetValue('VE6_INDREG', "4")+"' " // 4 - BackOrder

	If ! EMPTY(oParams:GetValue('VE6_GRUITE_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_GRUITE_ATE', ""))
		cQuery += " AND VE6_GRUITE >= '"+oParams:GetValue('VE6_GRUITE_DE')+"' AND VE6_GRUITE <= '"+oParams:GetValue('VE6_GRUITE_ATE')+"' "
	ElseIf ! EMPTY(oParams:GetValue('VE6_GRUITE_DE', ""))
		cQuery += " AND VE6_GRUITE >= '"+oParams:GetValue('VE6_GRUITE_DE')+"' "
	ElseIf ! EMPTY(oParams:GetValue('VE6_GRUITE_ATE', ""))
		cQuery += " AND VE6_GRUITE <= '"+oParams:GetValue('VE6_GRUITE_ATE')+"' "
	EndIf

	If ! EMPTY(oParams:GetValue('VE6_CODITE_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_CODITE_ATE', ""))
		cQuery += " AND VE6_CODITE >= '"+oParams:GetValue('VE6_CODITE_DE')+"' AND VE6_CODITE <= '"+oParams:GetValue('VE6_CODITE_ATE')+"' "
	ElseIf ! EMPTY(oParams:GetValue('VE6_CODITE_DE', ""))
		cQuery += " AND VE6_CODITE >= '"+oParams:GetValue('VE6_CODITE_DE')+"' "
	ElseIf ! EMPTY(oParams:GetValue('VE6_CODITE_ATE', ""))
		cQuery += " AND VE6_CODITE <= '"+oParams:GetValue('VE6_CODITE_ATE')+"' "
	EndIf

	If ! EMPTY(oParams:GetValue('VE6_DATREG_DE', "")) .AND. ! EMPTY(oParams:GetValue('VE6_DATREG_ATE', ""))
		cQuery += " AND VE6_DATREG >= '"+oParams:GetValue('VE6_DATREG_DE')+"' AND VE6_DATREG <= '"+oParams:GetValue('VE6_DATREG_ATE')+"' "
	ElseIf ! EMPTY(oParams:GetValue('VE6_DATREG_DE', ""))
		cQuery += " AND VE6_DATREG >= '"+oParams:GetValue('VE6_DATREG_DE')+"' "
	ElseIf ! EMPTY(oParams:GetValue('VE6_DATREG_ATE', ""))
		cQuery += " AND VE6_DATREG <= '"+oParams:GetValue('VE6_DATREG_ATE')+"' "
	EndIf

	if ! EMPTY(oParams:GetValue('VS1_NUMORC', ""))
		cQuery += " AND C7_NUM = '"+ oParams:GetValue('C7_NUM') +"'  "
	EndIf

	cQuery += " GROUP BY VS1_FILIAL,VE6.D_E_L_E_T_ ,C7_ITEM,VS1_NUMORC ,VS1_DATORC ,VE6_DATREG ,VE6_HORREG "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )

	(cAl)->(DbGoTop()) // Posiciona o cursor no in�cio da �rea de trabalho ativa
	While !(cAl)->(EOF())          // Enquanto o cursor da �rea de trabalho ativa n�o indicar fim de arquivo
		cFStatus := oParams:GetValue('STATUS') // filtro
		cStatus  := self:GetStatus(xFilial('VS1'), (cAl)->VS1_NUMORC )
		If cFStatus == "TODOS" .OR. cStatus == cFStatus
			aEl := {;
				{ 'VS1_FILIAL', (cAl)->VS1_FILIAL },;
				{ 'VS1_NUMORC', (cAl)->VS1_NUMORC },;
				{ 'VS1_DATORC', (cAl)->VS1_DATORC },;
				{ 'VE6_DATREG', (cAl)->VE6_DATREG },;
				{ 'C7_ITEM'   , (cAl)->C7_ITEM    },;
				{ 'VE6_HORREG', (cAl)->VE6_HORREG },;
				{ 'STATUS'    , cStatus           } ;
			}
			oEl := DMS_DataContainer():New(aEl)
			AADD(aResults, oEl)
		EndIf

		(cAl)->(DbSkip())
	End
	(cAl)->(dbCloseArea())

	cFilAnt := cBckFil
Return aResults

/*/{Protheus.doc} GetItensBO
	Construtor simples DMS_BackOrder


	@author  Vinicius Gati
	@since   05/10/2015

Par�metros:
	cFil: Filial
	cOrcNum: Numero do Or�amento/Pedido que fez a Sugest�o, se nulo abre janela para busca geral de Sugest�o BackOrder
	cSugBO: 1 - Sugest�o de Compras BackOrder / Outras Sugest�es de Compras (N�o BackOrder)
	cTipo: n�o utilizado
	
	@example 

/*/
Method GetItensBO(cFil, cNumOrc, cSugBO, cTipo) Class DMS_BackOrder
	Local cQuery   := " "
	Local cAl   := getNextAlias()
	Local aResults := {}
	Local cBckFil  := cFilAnt
	Local oSqlHlp  := DMS_SqlHelper():New()
	
	cFilAnt := cFil

	cQuery += "   SELECT VS1_NUMORC, VE6.D_E_L_E_T_ DELETED, VE6_FILIAL, VE6_SUGCOM, B1_COD, VE6_CODITE, VE6_GRUITE, VE6_ITEORC, VE6_QTDITE, VE6_QTDATE "
	cQuery += "     FROM "+oSqlHlp:NoLock('VE6')
	cQuery += "     JOIN "+oSqlHlp:NoLock('VS1')+" ON VS1_FILIAL = '"+xFilial('VS1')+"' AND VE6_NUMORC = VS1_NUMORC AND VS1.D_E_L_E_T_ = ' ' "
	cQuery += "     JOIN "+oSqlHlp:NoLock('SB1')+" ON B1_FILIAL  = '"+xFilial('SB1')+"' AND B1_CODITE  = VE6_CODITE AND B1_GRUPO   = VE6_GRUITE AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += "    WHERE VE6.VE6_FILIAL = '"+xFilial('VE6')+"' "
	cQuery += "      AND VS1_NUMORC = '"+ cNumOrc +"' "
	If cSugBO == "1" // Sugest�o BackOrder
		cQuery += "      AND VE6_INDREG = '4' " // 4 - BackOrder
		cQuery += "      AND VE6_ITEORC <> '' "
	Else // Outras Sugest�es (n�o BackOrder)
		cQuery += "      AND VE6_INDREG = '0' " // Sugest�o de Compras
		cQuery += "      AND VE6_ORIREQ = '1' " // Or�amento Balc�o
	Endif
	cQuery += " GROUP BY VS1_NUMORC, VE6.D_E_L_E_T_, VE6_FILIAL, VE6_SUGCOM, B1_COD, VE6_CODITE, VE6_GRUITE, VE6_ITEORC, VE6_QTDITE, VE6_QTDATE "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl, .F., .T. )

	(cAl)->(DbGoTop()) // Posiciona o cursor no in�cio da �rea de trabalho ativa
	While !(cAl)->(EOF())          // Enquanto o cursor da �rea de trabalho ativa n�o indicar fim de arquivo
		aEl := {                                ;
			{ 'VE6_FILIAL', (cAl)->VE6_FILIAL },;
			{ 'VS1_NUMORC', (cAl)->VS1_NUMORC },;
			{ 'VE6_SUGCOM', (cAl)->VE6_SUGCOM },;
			{ 'B1_COD'    , (cAl)->B1_COD     },;
			{ 'VE6_CODITE', (cAl)->VE6_CODITE },;
			{ 'VE6_GRUITE', (cAl)->VE6_GRUITE },;
			{ 'VE6_ITEORC', (cAl)->VE6_ITEORC },;
			{ 'VE6_QTDITE', (cAl)->VE6_QTDITE },;
			{ '_DELETED'  , (cAl)->DELETED    },;
			{ 'VE6_QTDATE', (cAl)->VE6_QTDATE } ;
		}
		oEl := DMS_DataContainer():New(aEl)
		AADD(aResults, oEl)

		DbSkip()
	End
	(cAl)->(dbCloseArea())

	cFilAnt := cBckFil
Return aResults

/*/{Protheus.doc} GetStatus
	Construtor simples DMS_BackOrder


	@author  Vinicius Gati
	@since   05/10/2015
	@param   aDados , Array , Ser� usado como datacontainer para pegar parametros de filtro
	@example 

/*/
Method GetStatus(cFil, cNumOrc, cTipo) Class DMS_BackOrder
	Local cQuery   := " "
	Local cAl1     := 'ASD'
	Local cBckFil  := cFilAnt
	Local oSqlHlp  := DMS_SqlHelper():New()
	
	cFilAnt := cFil

	If FM_SQL("SELECT COALESCE(COUNT(*),0) FROM " + oSqlHlp:NoLock('VQL') + " WHERE VQL_AGROUP = 'BO_DELETED' AND VQL_TIPO = '"+cNumOrc+"' AND VQL_FILORI = '"+xFilial('VS1')+"' AND D_E_L_E_T_ = ' ' ") > 0
		return "CANCELADO"
	EndIf

	cQuery += "   SELECT SUM(VE6_QTDITE) VE6_QTDITE, SUM(VE6_QTDATE) VE6_QTDATE "
	cQuery += "     FROM "+oSqlHlp:NoLock('VE6')
	cQuery += "    WHERE VE6.VE6_FILIAL = '"+xFilial('VE6')+"' "
	cQuery += "      AND VE6.VE6_NUMORC = '"+ cNumOrc +"' "
	cQuery += "      AND VE6.VE6_INDREG = '4' " // 4 - BackOrder
	cQuery += "      AND VE6.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAl1, .F., .T. )

	(cAl1)->(DbGoTop()) // Posiciona o cursor no in�cio da �rea de trabalho ativa
	While !(cAl1)->(EOF())          // Enquanto o cursor da �rea de trabalho ativa n�o indicar fim de arquivo
		cStatus := ""
		If( (cAl1)->VE6_QTDITE == (cAl1)->VE6_QTDATE )
			cStatus := "ATENDIDO"
		ElseIf (cAl1)->VE6_QTDITE < (cAl1)->VE6_QTDATE
			cStatus := "PARCIAL"
		ElseIf (cAl1)->VE6_QTDATE == 0
			cStatus := "AGUARDANDO"
		EndIf
		(cAl1)->(DbSkip())
	End
	(cAl1)->(dbCloseArea())
	
	if !Empty(cStatus) // A l�gica aqui � a seguinte, se fez a query normal e descobriu o status, retorna acima o correto, caso contr�rio foi cancelado.
		Return cStatus
	EndIf

	cFilAnt := cBckFil
Return "AGUARDANDO"


/*/{Protheus.doc} InStarvation
	Eternamente esperando chegada de itens?

	@author  Vinicius Gati
	@since   05/10/2015
	@param   oDados , DataContainer , Dados do item
			 aEl := {                                ;
			 	{ 'VE6_FILIAL', (cAl)->VE6_FILIAL },;
			 	{ 'VS1_NUMORC', (cAl)->VS1_NUMORC },;
			 	{ 'VE6_SUGCOM', (cAl)->VE6_SUGCOM },;
			 	{ 'B1_COD'    , (cAl)->B1_COD     },;
			 	{ 'VE6_CODITE', (cAl)->VE6_CODITE },;
			 	{ 'VE6_GRUITE', (cAl)->VE6_GRUITE },;
			 	{ 'VE6_ITEORC', (cAl)->VE6_ITEORC },;
			 	{ 'VE6_QTDITE', (cAl)->VE6_QTDITE },;
			 	{ '_DELETED'  , (cAl)->_DELETED   },;
			 	{ 'VE6_QTDATE', (cAl)->VE6_QTDATE } ;
			 }
	@example 

/*/
Method InStarvation(oItData) Class DMS_BackOrder
	return FM_SQL(" SELECT COUNT(*) FROM "+RetSqlName('SFJ')+" WHERE FJ_FILIAL = '"+xFilial('SFJ')+"' AND FJ_CODIGO = '"+oItData:GetValue('VE6_SUGCOM')+"' AND FJ_SOLICIT <> '' AND D_E_L_E_T_ = '' ") > 0
Return .F.
