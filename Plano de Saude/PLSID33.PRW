#include "PLSMGER.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"

Static nSTvlRee := 0
Static nSTvlCpR := 0
Static cCLNotIN := FormatIn( getNewPar("MV_PLNCLOC", PLSRETLDP(9) + "/" + PLSRETLDP(4)), '/') //Se vazio, considera o gen�rico e do MV_PLSDIGP

//Breve explica��o do que foi o ID33
//Provavelmente quando estiver lendo isso "ID33" n�o vai ser algo que diz muita coisa, ent�o fica aqui uma explica��o da regra que ele inseriu no sistema
//H� um cadastro onde pode ser definido valores de coparticipa��o por faixa de interna��o. Ent�o, para uma dada interna��o, todo o custo que ela teve deve ser somado e ent�o
//verificada a faixa em que se encontra, com isso voc� chega no valor de coparticipa��o definido para a dada interna��o.
//Essa coisa toda pode ocorrer em dois momentos: Consolida��o e gera��o de autoriza��o de reembolso.
//Quando a regra � ativada na consolida��o, � feita uma busca nas guias que tenham guia de interna��o vinculada, nisso � verificado se h� BDH em aberto para o benefici�rio e zerado
//(igual o padr�o da consolida��o j� ia fazer mesmo, s� que restrito aos casos que interessam para a regra), ap�s isso � verificado o valor total da interna��o (custo para a operadora)
//ent�o � verificado se h� faixa para aplica��o da regra, o valor j� cobrado do benefici�rio como coparticipa��o e ent�o s�o ajeitados os BD6/BD7 das guias envolvidas
//(zerando valores de coparticipa��o que por ventura existirem e , caso haja valor a descontar, incluindo o desconto integral no primeiro BD6/BD7 envolvido na regra)
//Quando a regra � ativada no reembolso, a diferen�a � que n�o � mexido nos BDH e que o valor da autoriza��o atual � enviada �s fun��o apra apurar o custo total da interna��o
//Com isso, o valor final da coparticipa��o das guias e reembolsos vinculados � interna��o ser� o da faixa em que o custo total da interna��o se encontra.
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSID33
Fun��o que chama o processo do ID 33. Vai receber o Numero da guia de interna��o e a matr�cula (quando vier do reembolso) e
um array de dados da consolida��o quando vier da consolida��o
@author Oscar Zanin
@since 08/01/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLSID33(cNumGui, cMatric, aDadCons, nVlrRee, lReembolso)
//AdadCons {cCodOpe, cCodEmpDe, cCodEmpAte, cAnoRef, cMesRef, cLocDe, cLocAte, cTipPre, dDatAte, cMatDe, cMatAte, cContrDe, cContrAte, cSubconDe, cSubconAte}
Local aID33ret	:= {.F., .F., .F., 0}
Default cNumgui 	:= ""
Default cMatric	:= ""
Default aDadCons	:= {}
Default nVlrRee	:= 0
Default lReembolso := .F.
//Se n�o veio do reembolso, da� tem que montar uma tabela tempor�ria com quem tem guia vinculada � uma solicita��o de interna��o
If EmpTy(cNumGui) .AND. !(lReembolso)

	OPEN QUERY PLSID33q0(aDadCons) ALIAS "ID33Q0"
		
	While !(ID33Q0->(EoF()))
		
		//Fun��o pra adiantar a parte de deletar os BDH n�o fechados (igual � consolida��o, ams s� pros registros envolvidos)
		PLSID33H0(ID33Q0->OPE, ID33Q0->EMP, ID33Q0->MAT, ID33Q0->REG) //Ponto de aten��o, ver regras de limpeza dos BDH
		
		PLSID33A(ID33Q0->GUIA, ID33Q0->(OPE+EMP+MAT+REG+DIG), lReembolso)
		
		ID33Q0->(Dbskip())
	EndDo
	
	CLOSE QUERY "ID33Q0"

else
	
	//Pra quando vir do reembolso, o retorno � utilizado, por isso aqui atribu�mos ele numa vari�vel
	aID33ret := PLSID33A(cNumGui, cMatric, lReembolso, nVlrRee)
	
EndIf

return aID33ret

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSID33A
Fun��o principal da regra do ID33
@author Oscar Zanin
@since 08/01/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLSID33A(cNumGui, cMatric, lReembolso, nVlrRee)

Local cSql			:= ""
Local nVlTotPag	:= 0
Local nVlAtulCp	:= 0
Local aFaixaCp	:= {.F., 0}
Local lAtualiza	:= .F.
Local aTotPag		:= {.F., 0}
Local dDataInt	:= StoD("")
Local aAreaBE4	:= BE4->(GetArea())
Local lCpReeCons	:= .F.
Local cGuiAux		:= ""
Local cNumBE4		:= ""
Default cNumgui 	:= ""
Default cMatric	:= ""
Default lReembolso := .F.
Default nVlrRee	:= 0
cNumBE4 := cNumgui
//Como tem vig�cia na tabela, e interna��o pode durar anos, a data a ser considerada �
//a data de interna��o.. ent�o vamos pegar a data de interna��o do carinha
If !(lReembolso)
	BE4->(DbSetOrder(1))
	If BE4->(MsSeek(xFilial("BE4")+cNumGui)) //No proc contas vem com o n�mero da guia no PEG
		dDataInt := BE4->BE4_DATPRO
		cGuiAux  := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
	else
		RestArea(aAreaBE4)
	EndIf
Else
	BE4->(DbSetOrder(2))
	If BE4->(MsSeek(xFilial("BE4")+cNumGui)) //No do reembolso vem com o n�mero do atendimento
		dDataInt := BE4->BE4_DATPRO
		cGuiAux  := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
		cNumGui  := BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
		cNumBE4  := BE4->(BE4_GUIINT)
	else
		RestArea(aAreaBE4)
	EndIf
EndIf

//Fun��o pra montar a query que verifica quanto de custo essa interna��o j� teve
//Vai olhar a base inteira. c'est la vie..
aTotPag := PLSID33B(cNumGui, nVlrRee, cGuiAux)
If aTotPag[1]
	nVlTotPag := aTotPag[2]
EndIf

//fun��o pra olhar se o cara se enquadra em alguma faixa.
//vai retornar um l�gico primeira posi��o, indicando se a regra � aplicada, ou n�o
//e um num�rico, que ser� quanto de coparticipa��o ele tem na faixa
If !(empTy(dDataInt))
	aFaixaCp 	:= PLSID33D(nVlTotPag, cMatric, dDataInt)
EndIf

If aFaixaCp[1]
	//Verifica o valor total de coparticipa��o da interna��o
	nVlAtulCp	:= PLSID33C(cNumGui, cGuiAux)[2]

	//Se ele pagou menos do que tem que pagar, da� marca pra fazer a pr�xima etapa
	If aFaixaCp[2] > nVlAtulCp
		lAtualiza := .T.
	EndIf

	If lReembolso
		//quando vier do reembolso, olha se tem guias vinculadas � interna��o que n�o foram consolidadas, ou est�o com a consolida��o em aberto
		//se tiver, vai jogar a coparticipa��o pra l�, ao inv�s de descontar no reembolso
		lCpReeCons := PLSID33K(cNumGui)
		If lCpReeCons
			//Vai zerar o que tiver de coparticipa��o nos itens (se n�o for gerar coparticipa��o no primeiro momento, da� n�o precisa isso aqui.. n�o, n�o)
			PLSID33F(cNumGui, lAtualiza, aFaixaCp[2] - nVlAtulCp, cNumBE4)
		EndIf
	else
		//Vai zerar o que tiver de coparticipa��o nos itens (se n�o for gerar coparticipa��o no primeiro momento, da� n�o precisa isso aqui.. n�o, n�o)
		PLSID33F(cNumGui, lAtualiza, aFaixaCp[2] - nVlAtulCp, cNumBE4)	
	EndIf
EndIf

//The end (por o meme do cara que coloca a etiqueta [cachorro] no cachorro)
return {aFaixaCp[1], lAtualiza, lCpReeCons, aFaixaCp[2] - nVlAtulCp}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSID33B
Verifica o custo total da interna��o para a operadora (soma dos VLRPAG [proc contas] e VLRMAN [Reembolso]), mais o VLRMAN 
do reem bolso que est� sendo processado (quando chamado do reembolso)
@author Oscar Zanin
@since 08/01/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSID33B(cNumGui, nVlrRee, cGuiAux)
Local cSql			:= "" 
Local nTotPag		:= 0
Local lAchou		:= .F.
Default nVlrRee 	:= 0

cSql += " SELECT SUM(BD6_VLRPAG) PAG, SUM(BD6_VLRTPF) PF FROM "
cSql += " ( "
cSql += " SELECT RES.BE4_CODOPE CODOPE, RES.BE4_CODLDP CODLDP, RES.BE4_CODPEG CODPEG, RES.BE4_NUMERO NUMERO, "
cSql += " RES.BE4_ORIMOV ORIMOV, RES.BE4_SITUAC SITUAC, RES.BE4_FASE FASE "
cSql += " FROM " + RetSqlName("BE4") + " RES "
cSql += " WHERE RES.BE4_FILIAL = '" + xFilial("BE4") + "' "
cSql += " AND RES.BE4_TIPGUI = '" + "05" + "' "
cSql += " AND RES.BE4_GUIINT = '" + cNumGui + "' "
cSql += " AND RES.BE4_FASE IN ('3', '4') "
cSql += " AND RES.BE4_SITUAC = '1' "
cSql += " AND RES.BE4_CODLDP NOT IN " + cCLNotIN + " "
cSql += " AND RES.D_E_L_E_T_ = ' ' "
cSql += " UNION "
cSql += " SELECT SADT.BD5_CODOPE CODOPE, SADT.BD5_CODLDP CODLDP, SADT.BD5_CODPEG CODPEG, SADT.BD5_NUMERO NUMERO, "
cSql += " SADT.BD5_ORIMOV ORIMOV, SADT.BD5_SITUAC SITUAC, SADT.BD5_FASE FASE "
cSql += " FROM " + RetSqlName("BD5") + " SADT "
cSql += " WHERE SADT.BD5_FILIAL = '" + xFilial("BD5") + "' "
cSql += " AND SADT.BD5_TIPGUI <> '04' "
cSql += " AND SADT.BD5_GUIINT = '" + cNumGui + "' "
cSql += " AND SADT.BD5_FASE IN ('3', '4') "
cSql += " AND SADT.BD5_SITUAC = '1' "
cSql += " AND SADT.BD5_CODLDP NOT IN " + cCLNotIN + " "
cSql += " AND SADT.D_E_L_E_T_ = ' ' "
cSql += "  ) TEMP_INT "
cSql += " INNER JOIN " + RetSqlName("BD6") + " BD6 "
cSql += " ON BD6.BD6_FILIAL = '" + xFilial("BD6") +  "' "
cSql += " AND BD6.BD6_CODOPE = TEMP_INT.CODOPE "
cSql += " AND BD6.BD6_CODLDP = TEMP_INT.CODLDP "
cSql += " AND BD6.BD6_CODPEG = TEMP_INT.CODPEG "
cSql += " AND BD6.BD6_NUMERO = TEMP_INT.NUMERO "
cSql += " AND BD6.BD6_ORIMOV = TEMP_INT.ORIMOV "
cSql += " AND BD6.BD6_SITUAC = '1' "
cSql += " AND BD6.BD6_FASE IN ('3','4') "
cSql += " AND BD6.BD6_CODLDP NOT IN " + cCLNotIN + " "
cSql += " AND BD6.D_E_L_E_T_ = ' ' "

OPEN QUERY cSql ALIAS "ID33QB"

If !(ID33QB->(EoF()))
	lAchou  := .T.
	nTotPag := ID33QB->PAG
EndIf
CLOSE QUERY "ID33QB"

//Essa parte � enganadora! como o reembolso abate a coparticipa��o no valor de pagamento, n�o podemos
//pegar o valor de pagamento, pois em certos casos at� mudaria a faixa que o carinha se enquadra..
//temos que pegar o VLRMAN, que � o valor final de apresentado - glosas (que seria o valor de pagamento,
//que seria o valor de pagamento no proc contas, da� tudo fica na mesma propor��o
cSql := ""
cSql += " Select SUM(B45_VLRMAN) PAG from "
cSql += RetSqlName("B45")
cSql += " Where "
cSql += " B45_FILIAL = '" + xFilial("B45") + "' AND "
cSql += " B45_GUIPRI = '" + cGuiAux + "' AND "
cSql += " D_E_L_E_T_ = ' ' "

OPEN QUERY cSql ALIAS "ID33QBR"

If !(ID33QBR->(EoF()))
	lAchou  := .T.
	nTotPag := nTotPag + ID33QBR->PAG
EndIf
CLOSE QUERY "ID33QBR"

nTotPag := nTotPag + PLID33Get(1)

return { lAchou, nTotPag }

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSID33C
Verifica o valor total de coparticipa��o da interna��o
@author Oscar Zanin
@since 08/01/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSID33C(cNumGui, cGuiAux)
Local cSql 		:= "" 
Local nTotPF 		:= 0
Local lAchou		:= .F.

cSql += " SELECT SUM(BD6_VLRPAG) PAG, SUM(BD6_VLRTPF) PF FROM "
cSql += " ( "
cSql += " SELECT RES.BE4_CODOPE CODOPE, RES.BE4_CODLDP CODLDP, RES.BE4_CODPEG CODPEG, RES.BE4_NUMERO NUMERO, "
cSql += " RES.BE4_ORIMOV ORIMOV, RES.BE4_SITUAC SITUAC, RES.BE4_FASE FASE "
cSql += " FROM " + RetSqlName("BE4") + " RES "
cSql += " WHERE RES.BE4_FILIAL = '" + xFilial("BE4") + "' "
cSql += " AND RES.BE4_TIPGUI = '05' "
cSql += " AND RES.BE4_GUIINT = '" + cNumGui + "' "
cSql += " AND RES.BE4_FASE IN ('3', '4') "
cSql += " AND RES.BE4_SITUAC = '1' "
cSql += " AND RES.BE4_CODLDP NOT IN " + cCLNotIN + " "
cSql += " AND RES.D_E_L_E_T_ = ' ' "
cSql += " UNION "
cSql += " SELECT HON.BD5_CODOPE CODOPE, HON.BD5_CODLDP CODLDP, HON.BD5_CODPEG CODPEG, HON.BD5_NUMERO NUMERO, "
cSql += " HON.BD5_ORIMOV ORIMOV, HON.BD5_SITUAC SITUAC, HON.BD5_FASE FASE "
cSql += " FROM  " + RetSqlName("BD5") + " HON "
cSql += " WHERE HON.BD5_FILIAL = '" + xFilial("BD5") + "' "
cSql += " AND HON.BD5_TIPGUI <> '04' "
cSql += " AND HON.BD5_GUIINT = '" + cNumGui + "' "
cSql += " AND HON.BD5_FASE IN ('3', '4') "
cSql += " AND HON.BD5_SITUAC = '1' "
cSql += " AND HON.BD5_CODLDP NOT IN " + cCLNotIN + " "
cSql += " AND HON.D_E_L_E_T_ = ' ' "
cSql += "  ) TEMP_INT "
cSql += " INNER JOIN " + RetSqlName("BD6") + " BD6 "
cSql += " ON BD6.BD6_FILIAL = '" + xFilial("BD6") +  "' "
cSql += " AND BD6.BD6_CODOPE = TEMP_INT.CODOPE "
cSql += " AND BD6.BD6_CODLDP = TEMP_INT.CODLDP "
cSql += " AND BD6.BD6_CODPEG = TEMP_INT.CODPEG "
cSql += " AND BD6.BD6_NUMERO = TEMP_INT.NUMERO "
cSql += " AND BD6.BD6_ORIMOV = TEMP_INT.ORIMOV "
cSql += " AND BD6.BD6_SITUAC = TEMP_INT.SITUAC "
cSql += " AND BD6.BD6_FASE   = TEMP_INT.FASE "
cSql += " AND BD6.BD6_SEQPF  <> ' ' "
cSql += " AND BD6.BD6_CODLDP NOT IN " + cCLNotIN + " "
cSql += " AND BD6.D_E_L_E_T_ = ' ' "

OPEN QUERY cSql ALIAS "ID33QC"

If !(ID33QC->(EoF()))
	lAchou  := .T.
	nTotPF := ID33QC->PF
EndIf
CLOSE QUERY "ID33QC"

cSql := ""
cSql += " Select SUM(B45_VLRTPF) PF from "
cSql += RetSqlName("B45")
cSql += " Where "
cSql += " B45_FILIAL = '" + xFilial("B45") + "' AND "
cSql += " B45_GUIPRI = '" + cGuiAux + "' AND "
cSql += " D_E_L_E_T_ = ' ' "

OPEN QUERY cSql ALIAS "ID33QCR"

If !(ID33QCR->(EoF()))
	lAchou  := .T.
	nTotPF := nTotPF + ID33QCR->PF
EndIf
CLOSE QUERY "ID33QCR"

nTotPF := nTotPF + PLID33Get(0)

return { lAchou, nTotPF }


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSID33D
Fun��o para verificar se aplica a regra da coparticipa��o por faixa da interna��o
para dado benefici�rio
@author Oscar Zanin
@since 08/01/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSID33D(nVltCop, cMatric, dDataInt)

Local nVlCopart 	:= 0
Local lAplica		:= .F.
Local cTabCop 	:= ""
Local aAreaBA1	:= BA1->(getArea())
Local aAreaBQC	:= BQC->(GetArea())
Local aAreaBI3	:= BI3->(GetArea())
Local aAreaBA3	:= BA3->(GetArea())
Local aAreaBHG	:= BHG->(GetArea())
Local cChaveProd	:= ""
Local cChaveBHG	:= ""
Default nVltCop 	:= 0
Default cMatric	:= ""

BA1->(DbSetOrder(2))
If BA1->(MsSeek(xFilial("BA1")+cMatric)) //Posiciona no benfici�rio

	//Se n�o foi informado no benefici�rio, vai na fam�lia
	If EmpTy(BA1->(BA1_CODPLA+BA1_VERSAO))
		BA3->(DbSetOrder(1))
		If BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
			cChaveProd := BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)
			cChaveBHG  := BA3->(BA3_CODINT + BA3_CODEMP + BA3_CONEMP + BA3_VERCON + BA3_SUBCON + BA3_VERSUB + BA3_CODPLA + BA3_VERSAO)
		Else
			restArea(aAreaBA3)
		EndIf
	else
		cChaveProd := BA1->(BA1_CODINT+BA1_CODPLA+BA1_VERSAO)
		cChaveBHG  := BA1->(BA1_CODINT + BA1_CODEMP + BA1_CONEMP + BA1_VERCON + BA1_SUBCON + BA1_VERSUB + BA1_CODPLA + BA1_VERSAO)
	EndIf

	BHG->(DbSetOrder(1)) //BHG_FILIAL + BHG_CODINT + BHG_CODIGO + BHG_NUMCON + BHG_VERCON + BHG_SUBCON + BHG_VERSUB + BHG_CODPRO + BHG_VERPRO
	If BHG->(MsSeek( xFilial("BHG") + cChaveBHG ))
		While !(BHG->(EoF())) .AND. ( BHG->(BHG_FILIAL+BHG_CODINT+BHG_CODIGO+BHG_NUMCON+BHG_VERCON+BHG_SUBCON+BHG_VERSUB+BHG_CODPRO+BHG_VERPRO) == xFilial("BHG")+cChaveBHG )
			If ! ( Empty(BHG->BHG_TABCOP) ) .AND. ( Empty(BHG->BHG_TIPUSR) .OR. BHG->BHG_TIPUSR == BA1->BA1_TIPUSU ) .AND. ;
				( Empty(BHG->BHG_GRAUPA) .OR. BHG->BHG_GRAUPA == BA1->BA1_GRAUPA ) .AND. BHG->BHG_TIPO $ " ,1,3" .AND. PLSINTVAL("BHG",'BHG_VIGINI','BHG_VIGFIN',dDataInt)
				
				cTabCop := BHG->BHG_TABCOP
				Exit
				
			EndIf
			BHG->(Dbskip())
		EndDo
	Else
		RestArea(aAreaBHG)
	EndIf

	BQC->(DbSetOrder(1)) //Olha se foi informada tabela de faixa de coparticipa��o no Sub contrato
	If (empTy(cTabCop)) .AND. BQC->(MsSeek(xFilial("BQC")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
		If !(empTy(BQC->BQC_TABCOP))
			cTabCop := BQC->BQC_TABCOP
		EndIf
	else
		restArea(aAreaBQC)
	EndIf
	
	BI3->(DbSetOrder(1)) //Olha se foi informada tabela de faixa de coparticipa��o no produto
	if empTy(cTabCop) .AND. !(EmpTy(cChaveProd)) .AND. BI3->(MsSeek(xFilial("BI3")+cChaveProd))
		IF !(empTy(BI3->BI3_TABCOP))
			cTabcop := BI3->BI3_TABCOP
		EndIf
	else
		RestArea(aAreaBI3)
	EndIf
else
	restArea(aAreaBA1)
EndIf

BRT->(DbSetOrder(1))
BRU->(DbSetOrder(1))
If !(empTy(cTabCop)) .AND. BRT->(MsSeek(xFilial("BRT")+cTabCop))
	//verifica vig�ncia da tabela encontrada (caso encontrada)
	If BRT->BRT_VIGINI <= dDataInt .AND. (EmpTy(BRT->BRT_VIGFIM) .OR. BRT->BRT_VIGFIM >= dDataInt)
		If BRU->(MsSeek(xFilial("BRU")+cTabCop))
			//Busca a faixa em que o custo da interna��o se encontra
			While !(BRU->(EoF())) .AND. (BRU->(BRU_FILIAL+BRU_CODIGO) == xFilial("BRU")+cTabCop)
				If nVltCop >= BRU->BRU_VLRINI .AND. nVltCop <= BRU->BRU_VLRFIM
					nVlCopart 	:= BRU->BRU_VLRCOP
					lAplica	:= .T.
					Exit
				EndIf
				BRU->(Dbskip())
			EndDo
		EndIf
	EndIf
EndIf

//lAplica: indica se a regra � aplicada
//nVlCopart: indica o valor de coparticipa��o da faixa que foi enquadrada
return {lAplica, nVlCopart }

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSID33F
Fun��o para atualizar os BD6 e BD7 que estejam vinculadas � guia de interna��o que
foi informada. Vai zerar os BD6/BD7 abertos e por o valor de coparticipa��o no
primeiro BD6/BD7 das guias vinculadas
@author Oscar Zanin
@since 08/01/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLSID33F(cNumGui, lAtualiza, nValCopart, cNumBE4)

Local cSql := ""
Local cSqlCab	:= "" 
Local aAreaBD6 := BD6->(GetArea())
Local aAreaBD7 := BD7->(GetArea())
Local aAreaBD5 := BD5->(GetArea())
Local aAreaBE4 := BE4->(GetArea())
Local nLoop	:= 0
Local lID33BD6 := ExistBlock("PLID33BD6")
Default cNumGui := "Batata"
Default lAtualiza := .F.
Default nValCopart := 0
Default cNumBE4 := ""

cSqlcab += " Select BE4_CODOPE OPE, BE4_CODLDP LDP, BE4_CODPEG PEG, BE4_NUMERO NUM, 'BE4' CAB From " + retSqlName("BE4")
cSqlCab += " Where "
cSqlCab += " BE4_FILIAL = '" + xFilial("BE4") + "' AND "
cSqlCab += " BE4_GUIINT = '" + IIF( EmpTy(cNumBE4), cNumgui, cNumBE4) + "' AND "
cSqlCab += " BE4_TIPGUI = '05' AND "
cSqlCab += " BE4_FASE IN ('3', '4') AND "
cSqlCab += " BE4_SITUAC = '1' AND "
cSqlCab += " BE4_SEQPF = ' ' AND "
cSqlCab += " BE4_CODLDP NOT IN " + cCLNotIN + " AND "
cSqlCab += " D_E_L_E_T_ = ' ' "
cSqlCab += " Union All "
cSqlCab += " Select BD5_CODOPE OPE, BD5_CODLDP LDP, BD5_CODPEG PEG, BD5_NUMERO NUM, 'BD5' CAB From " + RetsqlName("BD5")
cSqlCab += " Where "
cSqlCab += " BD5_FILIAL = '" + xFilial("BD5") + "' AND "
cSqlCab += " BD5_GUIINT = '" + cNumGui + "' AND "
cSqlCab += " BD5_TIPGUI <> '04' AND "
cSqlCab += " BD5_FASE IN ('3', '4') AND "
cSqlCab += " BD5_SITUAC = '1' AND "
cSqlCab += " BD5_SEQPF = ' ' AND "
cSqlCab += " BD5_CODLDP NOT IN " + cCLNotIN + " AND "
cSqlCab += " D_E_L_E_T_ = ' ' "

OPEN QUERY cSqlCab ALIAS "PLSID33F"

If !(PLSID33F->(EoF()))

	//Tira coparticipa��o
	While !(PLSID33F->(EoF()))
		cSql := ""
		cSql += " UPDATE " + retSqlName("BD6") + " SET BD6_VLRPF = 0, BD6_VLRBPF = 0, BD6_VLRTPF = 0, BD6_ALIAPF = 'BRT' Where "
		cSql += " BD6_FILIAL = '" + xFilial("BD6") + "' AND "
		cSql += " BD6_CODOPE = '" + PLSID33F->OPE + "' AND "
		cSql += " BD6_CODLDP = '" + PLSID33F->LDP + "' AND "
		cSql += " BD6_CODPEG = '" + PLSID33F->PEG + "' AND "
		cSql += " BD6_NUMERO = '" + PLSID33F->NUM + "' AND "
		cSql += " BD6_FASE IN ('3','4') AND "
		cSql += " BD6_CODLDP NOT IN " + cCLNotIN + " AND "
		cSql += " BD6_SEQPF = ' ' AND "
		cSql += " D_E_L_E_T_ =  ' ' "
		TcSqlExec(cSql)
		cSql := ""
		cSql += " UPDATE " + retSqlName("BD7") + " SET BD7_COEFPF = 0, BD7_VLRTPF = 0, BD7_VLRBPF = 0, BD7_ALIPF = 'BRT' Where "
		cSql += " BD7_FILIAL = '" + xFilial("BD7") + "' AND "
		cSql += " BD7_CODOPE = '" + PLSID33F->OPE + "' AND "
		cSql += " BD7_CODLDP = '" + PLSID33F->LDP + "' AND "
		cSql += " BD7_CODPEG = '" + PLSID33F->PEG + "' AND "
		cSql += " BD7_NUMERO = '" + PLSID33F->NUM + "' AND "
		cSql += " BD7_FASE IN ('3','4') AND "
		cSql += " BD7_CODLDP NOT IN " + cCLNotIN + " AND "
		cSql += " D_E_L_E_T_ =  ' ' "
		TcSqlExec(cSql)
		
		PLSID33F->(Dbskip())
	EndDo

	//P�e coparticipa��o
	If lAtualiza .AND. nValCopart > 0
		PLSID33F->(dbGoTop())
		BD6->(DbSetOrder(1))
		BD7->(DbSetOrder(1))
		BD5->(DbSetOrder(1))
		BE4->(DbSetOrder(1))
		While (!(PLSID33F->(EoF())))
			If BD6->(MsSeek(Xfilial("BD6") + PLSID33F->(OPE+LDP+PEG+NUM)))
				
				If nLoop == 0
					BD6->(RecLock("BD6", .F.))
						BD6->BD6_VLRPF  := nValCopart
						BD6->BD6_VLRTPF := nValCopart
						BD6->BD6_VLRBPF := nValCopart
						BD6->BD6_PERCOP := 100
						BD6->BD6_ALIAPF := "BRT"
					BD6->(MsUnLock())
		
					// ponto de entrada para gravar informacoes adicionais na Tabela BD6 (campos customizados). 
					If lID33BD6
						ExecBlock("PLID33BD6",.F.,.F.,{ BD6->(RecNo()) })				
					EndIf
		
					//BD7->(DbSetOrder(1))
					If BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
						BD7->(RecLock("BD7", .F.))
							BD7->BD7_COEFPF := nValCopart
							BD7->BD7_VLRTPF := nValCopart
							BD7->BD7_VLRBPF := nValCopart
							BD7->BD7_PERPF := 100
							BD7->BD7_ALIPF := "BRT"
						BD7->(MsUnLock())
					EndIf
				else
					nValCopart := 0
				EndIf
				
				If PLSID33F->CAB == "BD5"
					//BD5->(DbSetOrder(1))
					If BD5->(MsSeek(xFilial("BD5")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
						BD5->(RecLock("BD5", .F.))
							BD5->BD5_VLRPF  := nValCopart
							BD5->BD5_VLRTPF := nValCopart
						BD5->(MsUnLock())
					EndIf
					RestArea(aAreaBD5)
				elseIf PLSID33F->CAB == "BE4"
					//BE4->(DbSetOrder(1))
					If BE4->(MsSeek(xFilial("BE4")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
						BE4->(RecLock("BE4", .F.))
							BE4->BE4_VLRPF  := nValCopart
							BE4->BE4_VLRTPF := nValCopart
						BE4->(MsUnLock())
					EndIf
					restarea(aAreaBE4)
				EndIf
				nLoop++
			EndIf
			PLSID33F->(DbSkip())
		EndDo
	EndIf
EndIf
CLOSE QUERY "PLSID33F"

RestArea(aAreaBD6)
RestArea(aAreaBD7)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSID33q0
Query para ver quais guias, dentro dos par�metros informados para a consolida��o,
possuem uma guia de interna��o vinculada.
@author Oscar Zanin
@since 08/01/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLSID33q0(aDadCons)
//aDadCons {cCodOpe, cCodEmpDe, cCodEmpAte, cAnoRef, cMesRef, cLocDe, cLocAte, cTipPre /* 8 */, dDatAte, cMatDe, cMatAte, cContrDe, cContrAte, cSubconDe, cSubconAte}
Local cSql 		:= "" 

cSql += " Select Distinct Z.GUIA, Z.OPE, Z.EMP, Z.MAT, Z.REG, Z.DIG "
cSql += " From ( "
cSql += " Select BD5_GUIINT GUIA, BD5_OPEUSR OPE, BD5_CODEMP EMP,  BD5_MATRIC MAT, BD5_TIPREG REG, BD5_DIGITO DIG "
cSql += " From " + RetSqlName("BD5") + " BD5 "
cSql += " Where "
cSql += " BD5_FILIAL =  '" + xFilial("BD5") + "' AND "
cSql += " BD5_OPEUSR =  '" + aDadCons[1] + "' AND " 
cSql += " BD5_CODEMP >= '" + aDadCons[2] + "' AND "
cSql += " BD5_CODEMP <= '" + aDadCons[3] + "' AND "
cSql += " ( BD5_ANOPAG <  '" + aDadCons[4] + "' OR ( BD5_ANOPAG =  '" + aDadCons[4] + "' AND BD5_MESPAG <=  '" + aDadCons[5] + "' )) AND "
cSql += " BD5_CODLDP >= '" + aDadCons[6] + "' AND "
cSql += " BD5_CODLDP <= '" + aDadCons[7] + "' AND "
cSql += " BD5_MATRIC >= '" + aDadCons[10] + "' AND "
cSql += " BD5_MATRIC <= '" + aDadCons[11] + "' AND "
cSql += " BD5_CONEMP >= '" + aDadCons[12] + "' AND "
cSql += " BD5_CONEMP <= '" + aDadCons[13] + "' AND "
cSql += " BD5_SUBCON >= '" + aDadCons[14] + "' AND "
cSql += " BD5_SUBCON <= '" + aDadCons[15] + "' AND "
cSql += " BD5_FASE IN ('3','4') AND "
cSql += " BD5_GUIINT <> ' ' AND "
cSql += " BD5_TIPGUI <> '04' AND "
cSql += " BD5_SITUAC = '1'   AND "
cSql += " BD5_CODLDP NOT IN " + cCLNotIN + " "
cSql += " AND BD5.D_E_L_E_T_ = ' ' " 
cSql += " UNION "
cSql += " Select BE4_GUIINT GUIA, BE4_OPEUSR OPE, BE4_CODEMP EMP,  BE4_MATRIC MAT, BE4_TIPREG REG, BE4_DIGITO DIG "
cSql += " From " + RetSqlName("BE4") + " BE4 "
cSql += " Where "
cSql += " BE4_FILIAL =  '" + xFilial("BE4") + "' AND "
cSql += " BE4_OPEUSR =  '" + aDadCons[1] + "' AND " 
cSql += " BE4_CODEMP >= '" + aDadCons[2] + "' AND "
cSql += " BE4_CODEMP <= '" + aDadCons[3] + "' AND "
cSql += " ( BE4_ANOPAG <  '" + aDadCons[4] + "' OR ( BE4_ANOPAG =  '" + aDadCons[4] + "' AND BE4_MESPAG <=  '" + aDadCons[5] + "' )) AND "
cSql += " BE4_CODLDP >= '" + aDadCons[6] + "' AND "
cSql += " BE4_CODLDP <= '" + aDadCons[7] + "' AND "
cSql += " BE4_MATRIC >= '" + aDadCons[10] + "' AND "
cSql += " BE4_MATRIC <= '" + aDadCons[11] + "' AND "
cSql += " BE4_CONEMP >= '" + aDadCons[12] + "' AND "
cSql += " BE4_CONEMP <= '" + aDadCons[13] + "' AND "
cSql += " BE4_SUBCON >= '" + aDadCons[14] + "' AND "
cSql += " BE4_SUBCON <= '" + aDadCons[15] + "' AND "
cSql += " BE4_FASE IN ('3','4') AND "
cSql += " BE4_GUIINT <> ' ' AND "
cSql += " BE4_SITUAC = '1'  AND "
cSql += " BE4_CODLDP NOT IN " + cCLNotIN + " "
cSql += " AND BE4.D_E_L_E_T_ = ' ' "
csql += " ) Z "

return cSql

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSID33H0
Fun��o para limpar os BDH em aberto para os benefici�rios identificados com
guias � pagar com guias vinculadas
@author Oscar Zanin
@since 08/01/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSID33H0(cOpe, cEmp, cMat, cReg)
                                                         
Local cSql	:= ""
Local aAreaBDH	:= BDH->(GetArea())

//Talvez tenha que por o m�s e ano aqui.. talvez..
cSql += " Select R_E_C_N_O_ REC From " + RetsqlName("BDH")
cSql += " Where "
cSql += " BDH_CODINT = '" + cOpe + "' AND "
cSql += " BDH_CODEMP = '" + cEmp + "' AND "
cSql += " BDH_MATRIC = '" + cMat + "' AND "
cSql += " BDH_TIPREG = '" + cReg + "' AND "
cSql += " BDH_STATUS = '1' AND "
cSql += " D_E_L_E_T_ = ' ' "

BDH->(dbSetOrder(1))

OPEN QUERY cSql ALIAS "PLSID33H0"

If !(PLSID33H0->(EoF()))
	While !(PLSID33H0->(EoF()))
		BDH->(DbGoTo(PLSID33H0->REC))
				
		PLSM180Del() //limpa seqpf a partir de um bdh

// Ver depois qual � a desse peda�o do fonte		
//		If lB80Field// Limpa o parcelamento
//			PLSM180PAR() 
//		EndIf
		
		BDH->(RecLock("BDH",.F.))
			BDH->(DbDelete())
		BDH->(MsUnLock())
				
		PLSID33H0->(DbSkip())
	EndDo
EndIf
CLOSE QUERY "PLSID33H0"

restArea(aAreaBDH)

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSID33K
Verifica se tem alguma guia vinculada � interna��o que esteja pendente de consolida��o
@author Oscar Zanin
@since 08/01/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSID33K(cNumGui)
Local cSql 		:= ""
Local lAchou		:= .F.

cSql += " SELECT 1 FROM "
cSql += " ( "
cSql += " SELECT RES.BE4_CODOPE CODOPE, RES.BE4_CODLDP CODLDP, RES.BE4_CODPEG CODPEG, RES.BE4_NUMERO NUMERO, "
cSql += " RES.BE4_ORIMOV ORIMOV, RES.BE4_SITUAC SITUAC, RES.BE4_FASE FASE "
cSql += " FROM " + RetSqlName("BE4") + " RES "
cSql += " WHERE RES.BE4_FILIAL = '" + xFilial("BE4") + "' "
cSql += " AND RES.BE4_TIPGUI = '05' "
cSql += " AND RES.BE4_FASE IN ('3', '4') "
cSql += " AND RES.BE4_SITUAC = '1' "
cSql += " AND RES.BE4_GUIINT = '" + cNumGui + "' "
cSql += " AND RES.BE4_CODLDP NOT IN " + cCLNotIN + " "
cSql += " AND RES.D_E_L_E_T_ = ' ' "
cSql += " UNION "
cSql += " SELECT HON.BD5_CODOPE CODOPE, HON.BD5_CODLDP CODLDP, HON.BD5_CODPEG CODPEG, HON.BD5_NUMERO NUMERO, "
cSql += " HON.BD5_ORIMOV ORIMOV, HON.BD5_SITUAC SITUAC, HON.BD5_FASE FASE "
cSql += " FROM  " + RetSqlName("BD5") + " HON "
cSql += " WHERE HON.BD5_FILIAL = '" + xFilial("BD5") + "' "
cSql += " AND HON.BD5_TIPGUI = '06' "
cSql += " AND HON.BD5_FASE IN ('3', '4') "
cSql += " AND HON.BD5_SITUAC = '1' "
cSql += " AND HON.BD5_GUIINT = '" + cNumGui + "' "
cSql += " AND HON.BD5_CODLDP NOT IN " + cCLNotIN + " "
cSql += " AND HON.D_E_L_E_T_ = ' ' "
cSql += " UNION " 
cSql += " SELECT SADT.BD5_CODOPE CODOPE, SADT.BD5_CODLDP CODLDP, SADT.BD5_CODPEG CODPEG, SADT.BD5_NUMERO NUMERO, "
cSql += " SADT.BD5_ORIMOV ORIMOV, SADT.BD5_SITUAC SITUAC, SADT.BD5_FASE FASE "
cSql += " FROM " + RetSqlName("BD5") + " SADT "
cSql += " WHERE SADT.BD5_FILIAL = '" + xFilial("BD5") + "' "
cSql += " AND SADT.BD5_TIPGUI = '02' "
cSql += " AND SADT.BD5_FASE IN ('3', '4') "
cSql += " AND SADT.BD5_SITUAC = '1' "
cSql += " AND SADT.BD5_GUIINT = '" + cNumGui + "' "
cSql += " AND SADT.BD5_CODLDP NOT IN " + cCLNotIN + " "
cSql += " AND SADT.D_E_L_E_T_ = ' ' "
cSql += "  ) TEMP_INT "
cSql += " INNER JOIN " + RetSqlName("BD6") + " BD6 "
cSql += " ON BD6.BD6_FILIAL = '" + xFilial("BD6") +  "' "
cSql += " AND BD6.BD6_CODOPE = TEMP_INT.CODOPE "
cSql += " AND BD6.BD6_CODLDP = TEMP_INT.CODLDP "
cSql += " AND BD6.BD6_CODPEG = TEMP_INT.CODPEG "
cSql += " AND BD6.BD6_NUMERO = TEMP_INT.NUMERO "
cSql += " AND BD6.BD6_ORIMOV = TEMP_INT.ORIMOV "
cSql += " AND BD6.BD6_SITUAC = TEMP_INT.SITUAC "
cSql += " AND BD6.BD6_FASE   = TEMP_INT.FASE "
cSql += " AND BD6.BD6_SEQPF  = ' ' "
cSql += " AND BD6.BD6_CODLDP NOT IN " + cCLNotIN + " "
//	[colocar demais codi��es ex: seqpf, blocpa, etc (vide consolida��o padr�o)	
cSql += " AND BD6.D_E_L_E_T_ = ' ' "

OPEN QUERY cSql ALIAS "PLSID33K"

If !(PLSID33K->(EoF()))
	lAchou  := .T.
EndIf
CLOSE QUERY "PLSID33K"

return lAchou

//-------------------------------------------------------------------
/*/{Protheus.doc} PLID33Set
P�e valor nas varia�veis STATIC que controlam o total de custo e coparticipa��o
do reembolso que est� sendo processado atualmente
@author Oscar Zanin
@since 10/01/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLID33Set(lZera, nVlRee, nVlCp)

Default lZera  := .F.
Default nVlRee := 0
default nVlCp  := 0

If lZera
	nSTvlRee := 0
	nSTvlCpR := 0
else
	nSTvlRee += nVlRee
	nSTvlCpR += nVlCp
EndIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLID33Get
retorna o valor das vari�veis que controlam o total de custo e coparticipa�a� do reembolso
que est� sendo processado atualmente
1 - Custo total (soma dos B45_VLRMAN)
2 - Coparticipa��o total (Soma dos B45_VLRPF)
@author Oscar Zanin
@since 10/01/2018
@version P12
/*/
//-------------------------------------------------------------------
function PLID33Get(nVar)

Local nRet := 0
Default nVar := 0

If nVar == 1
	nRet := nSTvlRee
else
	nRet := nSTvlCpR
EndIf

return nRet