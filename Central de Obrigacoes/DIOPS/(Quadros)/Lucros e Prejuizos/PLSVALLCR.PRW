#Include 'totvs.ch'

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LucrPrej01

Validação de Lucros e Prejuízos

@author Roger C
@since 06/11/2017
/*/
//--------------------------------------------------------------------------------------------------
Function LucrPrej01()
	Local lRet		:= .T.
	Local cSql		:= ""
	Local nNAlia1	:= GetNextAlias()
	Local nNAlia2	:= GetNextAlias()
	Local nSoma		:= 0
	Local nDebCre	:= 0

	//Soma de CREDITO + DEBITO da conta 256 do Balancete
	cSql := "SELECT B8A_CREDIT + (-B8A_DEBITO) B8A_CREDEB FROM " + RetSqlName("B8A") + " WHERE B8A_FILIAL = '" + xFilial("B8A") + "' AND B8A_CODOPE = '" + B8E->B8E_CODOPE + "' AND B8A_CODOBR = '" + B8E->B8E_CODOBR + "' "
	cSql += "AND B8A_ANOCMP = '" + B8E->B8E_ANOCMP + "' AND B8A_CDCOMP = '" + B8E->B8E_CDCOMP + "' AND B8A_CONTA = '256' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),nNAlia1,.F.,.T.)

	If !(nNAlia1)->(Eof())
		nDebCre := (nNAlia1)->B8A_CREDEB
	EndIf
	
	(nNAlia1)->(dbCloseArea())
	
	//Somatoria do quadro
	cSql := "SELEC SUM(B8E_VLRCON) B8E_VLRCON FROM " + RetSqlName("B8E") + " WHERE B8E_FILIAL = '" + xFilial("B8E") + "' AND B8E_CODOPE = '" + B8E->B8E_CODOPE + "' AND B8E_CODOBR = '" + B8E->B8E_CODOBR + "' "
	cSql += "AND B8E_ANOCMP = '" + B8E->B8E_ANOCMP + "' AND B8E_CDCOMP = '" + B8E->B8E_CDCOMP + "' AND D_E_L_E_T_ = ' '"
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),nNAlia2,.F.,.T.)

	If !(nNAlia2)->(Eof())
		nSoma := (nNAlia2)->B8E_VLRCON
	EndIf
	
	(nNAlia2)->(dbCloseArea())
	
	If nSoma <> nDebCre
		lRet := .F.
	EndIf

Return lRet


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LucrPrej02

Funcao criada para validar Critica 
Para esta conta o do saldo final deve ser menor ou igual a zero

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author jose.paulo
@since 25/07/2019
/*/
//--------------------------------------------------------------------------------------------------
Function LucrPrej02(oModel)
	Local lRet := .T.
	Local cSql 	:= ""
	Local cDescri:=""
	Local aNegativo := {"1","2","5","7"}

		Default oModel := Nil	

	If oModel == Nil
		cDescri	:= AllTrim(B8E->B8E_DESCRI)	
		nVlrCon	:= B8E->B8E_VLRCON
	Else
		cDescri 	:= AllTrim(oModel:GetValue( 'B8EMASTER', 'B8E_DESCRI' ))
		nVlrCon 	:= oModel:GetValue( 'B8EMASTER', 'B8E_VLRCON' )
	EndIf

	nPos := Ascan( aNegativo,{|x| x == cDescri })

	lRet := nPos == 0 .OR. nVlrCon <= 0	
	
Return lRet


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetBoxLPr

Retorna opções para o cbox do campo B8E_CODIGO

@author José Paulo
@since 02/07/2019
/*/
//--------------------------------------------------------------------------------------------------
Function RetBoxLPr()
	Local cRet		:= .T.

	cRet:="1=Lucros distribuidos (-);2=Constituição de reservas (-);3=Reversão de reservas (+);5=Juros sobre capital próprio (-);6=Ajustes de exercícios anteriores (com sinal);"
	cRet+="7=Lucro incorporado ao capital (-);8=Outros (com sinal);"

Return cRet 