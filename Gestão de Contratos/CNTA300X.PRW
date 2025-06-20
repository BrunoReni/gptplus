/*******************************************************************************************************************************
* CNTA300X.PRX
* Arquivo fonte contendo as fun��es para desfazer a revis�o do contrato
*******************************************************************************************************************************/
#INCLUDE "CNTA300X.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GCTXDEF.CH"

//-- Variaveis Est�ticas
Static lRollBack 	:= .F.  

//==============================================================================================================================
/*/{Protheus.doc} A300GRlbck() - Fun��o para recuperar a variavel estatica lRollBack
@author Hermes Ferreira
@since 17/08/2015
@version 12.7

/*/
//==============================================================================================================================
Function A300GRlbck()
Return lRollback

//==============================================================================================================================
/*/{Protheus.doc} A300SRlbck(lValor) - Fun��o para atribuir a variavel estatica lRollBack
@author Israel Escorizza
@since 19/02/2016
@version 12.7
/*/
//==============================================================================================================================
Function A300SRlbck(lValor)
	lRollback := lValor
Return

//==============================================================================================================================
/*/{Protheus.doc} CN300DesRv - Fun��o respons�vel por desfazer a revis�o do contrato
@author		Israel.Escorizza
@since		16/03/2018
@version	P12.1.21

Original	Cn300RlBk()
@author 	Hermes Ferreira
@since 		17/08/2015
@version 	12.7
/*/
//==============================================================================================================================
Function CN300DesRv(cMsgErro)
	Local aArea		:= GetArea()
	Local aSaveLine	:= FWSaveRows()
	Local lRet		:= .F.
	Local lAuto     := IsBlind()
	Local aErroAuto := {}
	Default cMsgErro:= ""
	
	If  !lAuto
		lRet := CnDrValid()
		If lRet .And. MsgNoYes(STR0006,STR0008)//Deseja realmente retornar a revis�o para o estado de elabora��o?
			lRet := FwMsgRun(Nil, {||CnDrProces() }, Nil,STR0007) //- "Aguarde, atualizando situa��o da revis�o..." 
		EndIf
	Else
		Private lAutoErrNoFile := .T.
		Private lMsHelpAuto    := .T.
		Private lMsErroAuto    := .F.

		Pergunte( "CNT100", .F. )

		MsExecAuto({||( CnDrValid() .And. CnDrProces() )})

		If !(lRet := (!lMsErroAuto))			
			aErroAuto := GetAutoGRLog()

			aEval(aErroAuto,{|x| cMsgErro += x + CRLF})
		EndIf
	EndIf

	FWRestRows( aSaveLine )
	FwFreeArray(aSaveLine)
	RestArea(aArea)
	FwFreeArray(aArea)
Return lRet

//==============================================================================================================================
/*/{Protheus.doc} CnDrValid - Fun��o respons�vel por realizar as chamadas de valida��o para desfazer a revis�o
@author		Israel.Escorizza
@since		19/03/2018
@version	P12.1.21
/*/
//==============================================================================================================================
Function CnDrValid()
Local aArea		:= GetArea() 
Local aSaveLine	:= FWSaveRows()
Local lRet		:= .F.

lRet :=	CnDrVlUser() .And.;		//- Valida usu�rio para opera��o de exclus�o
		A300CheckM() .And.;		//- Valida se h� medi��es em aberto
		CnDrVlRvVg() .And.;		//- Valida revis�o vigente do contrato
 		CnDrVlNEmp() .And.;		//- Valida notas de empenho
 		CnDrVlAdia() .And.;		//- Valida adiantamentos
 		CnDrVlCauc(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_FILCTR) .And.;		//- Valida cau��es
 		CNDRVlMed(CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_FILCTR) .And.;	//- Valida medi��es	
 		CN9->(CNEXDatFin(CN9_NUMERO, CN9_REVISA, CN9_FILCTR)) .And.;//Valida o MV_DATAFIN caso existam t�tulos provis�rios a serem removidos
 		CnDrVlGs()				//- Valida��es do GS



FWRestRows( aSaveLine )     
RestArea(aArea)
Return lRet

//==============================================================================================================================
/*/{Protheus.doc} CnDrProces - Fun��o respons�vel por realizar as chamadas de processamento para desfazer a revis�o
@author		Israel.Escorizza
@since		19/03/2018
@version	P12.1.21
/*/
//==============================================================================================================================
Function CnDrProces()
Local aArea		:= GetArea() 
Local aSaveLine	:= FWSaveRows()
Local lRet		:= .F.
Local lPcoInte	:= SuperGetMV("MV_PCOINTE",.F.,"2") == "1"
Local lCN300ESP := ExistBlock("CN300ESP")

Begin Transaction
	lRet :=	CnDrPrGs() 	.And.;		//- Realiza tratativas do m�dulo SIGATEC
	 		CnDrPrTit()	.And.;		//- Realiza estorno dos titulos provis�rios
	 		CnDrPrAFor() .And.;		//- Realiza estorno das avalia��es de fornecedores.
	 		CNDRSituac( CN9->CN9_NUMERO , CN9->CN9_REVISA )	.And.;		//-- Altera situacao das revisoes atual e anterior
			CNDRcalc(CN9->CN9_NUMERO , CN9->CN9_REVISA )  // Altera Cal��o
	If lRet		
		CNA300RvMd(CN9->CN9_NUMERO, CnRevAnt(.F.,CN9->CN9_REVISA), CN9->CN9_REVISA, CN9->CN9_FILCTR, .T.)	//-- Desfaz revis�o das medi��es
		DelCPDRev(CN9->CN9_FILCTR, CN9->CN9_NUMERO, CN9->CN9_REVISA)//Remove as permiss�es das planilhas incluidas no processo de revis�o, deixando apenas da revis�o anterior.

		If lPcoInte
		   A300PCOINT( , , , CN9->CN9_NUMERO , CN9->CN9_REVISA , "DR" , .T. ) //-- Estorno dos lancamentos do PCO
		Endif
		//Chama a contabiliza��o da estorno da revis�o, por item da planilha
		CN100ConIt( "69O" )		
	EndIf

	// Permite a execu��o de tratativas complementares
	If (lCN300ESP)
		ExecBlock("CN300ESP", .F., .F.)
	EndIf

	If !lRet
		DisarmTransaction()
	EndIf
	
End Transaction

FWRestRows( aSaveLine )     
RestArea(aArea)
Return lRet

//==============================================================================================================================
/*/{Protheus.doc} A300Dsapr  ---- VALIDAR UTILIZA��O
Fun��o para Rollback da Revis�o do contrato, na grava��o do model
Estorna titulos provisorio, contabilidade, Cau��o e Situa��o do contrato

@param oModel, objeto, Model CNTA300
@param cRev, character, Revis�o atual do contrato
@author Hermes Ferreira
@since 21/08/2015
@version 12.7
/*/
//==============================================================================================================================
Function A300Dsapr(oModel,cRev)
Local aAreaCN9  := CN9->(GetArea())
Local cRevAnt  	:= CnRevAnt()
Local oModelCN9	:= oModel:GetModel("CN9MASTER")
Local cContra		:= oModelCN9:GetValue("CN9_NUMERO")
Local cRevisa		:= oModelCN9:GetValue("CN9_REVISA")

Local lRollBack	:= .T.
Local lTitProv	:= SuperGetMV("MV_CNPROVI",.F.,"S") == "S"

CN300GerApr(oModelCN9,3,oModel:GetOperation()) 	//- Exclui SCRs geradas para revis�o

// Excluir titulos da Revis�o Atual
MsAguarde({||CN100ETit(cContra,cRevisa)},"Estornando t�tulos provis�rios") //- "Estornando t�tulos provis�rios"
CnCauAtu(oModel,cRevAnt) 					//Atualiza cau��o manual para a revis�o restaurada
CnSitAtu(CN9->CN9_NUMERO,cRev,lRollBack)	//Atualiza situa��o da revis�o restaurada (anterior) para 05 (Vigente)
CNContab("69H")								//Lan�amentos cont�beis Rollback da Revis�o do Contrato

If lTitProv
	// Posiciona da Revis�o anterior, para atualizar os lan�amentos referentes ao Rollback, da revis�o anterior
	CN9->(dbSetOrder(1))
	If CN9->(dbSeek(xFilial("CN9")+ cContra + cRevAnt ))
		// Gera os novos titulos, da revis�o anterior
		MsAguarde({||CN100CTit(cContra,cRevAnt)},"Processando t�tulos provis�rios")	//- "Processando t�tulos provis�rios"
		MsAguarde({||CN100RecTi(cContra,cRev)},"Processando t�tulos recorrentes")	// "Processando t�tulos recorrentes"
		CNContab("69G")										// Lan�amento Cont�bil na Aprova��o da Revisao
	EndIf
EndIf
RestArea(aAreaCN9)
Return Nil

//==============================================================================================================================
/*/{Protheus.doc} CnDrVlUser- Fun��o respons�vel por verificar acesso do usu�rio � opera��o de exclus�o
@author		Israel.Escorizza
@since		16/03/2018
@version	P12.1.21
/*/
//==============================================================================================================================
Function CnDrVlUser()
Local aArea		:= GetArea() 
Local aSaveLine	:= FWSaveRows()
Local lRet 		:= .T.

lRet := CN240VldUsr(CN9->CN9_NUMERO,DEF_TRAEXC,.F.)	//Valida Transacao de Exclus�o // Estorno

If !lRet
	Help(" ",1, 'Help','CNDRVLUS01',,4,0) 	//- "Usuario sem acesso a esta opera��o. // Verifique acesso a opera��o de exclus�o de revis�es."
EndIf

FWRestRows(aSaveLine)
RestArea(aArea)
Return lRet
//==============================================================================================================================
/*/{Protheus.doc} CnDrVlRvVg- Fun��o respons�vel por verificar se est� sendo desfeita a revis�o vigente do contrato
@author		Israel.Escorizza
@since		16/03/2018
@version	P12.1.21
/*/
//==============================================================================================================================
Function CnDrVlRvVg()
Local aArea		:= GetArea() 
Local aSaveLine	:= FWSaveRows()
Local lRevExist := !Empty(CN9->CN9_REVISA)							//- Valida se registro posicionado � uma revis�o
Local lRevAtual	:= CN9->CN9_REVISA == CnGetRevAt(CN9->CN9_NUMERO)	//- Valida se a revis�o posicionada � a atual
Local lRevVig	:= CN9->CN9_SITUAC $ DEF_SVIGE+'|'+DEF_SPARA		//- Valida situa��o de Vigente ou Paralizado
Local lRet 		:= .T.

DO	CASE
	CASE !lRevExist
		 lRet := .F.
		 Help(" ",1, 'Help','CNDRVLRV01',,4,0) 	//- "N�o � possivel desfazer revis�o da vers�o original do contrato. // Altere a situa��o do contrato para 'Em Elabora��o' utilizando a op��o 'Situa��o'."
	CASE !lRevAtual
		 lRet := .F.
		 Help(" ",1, 'Help','CNDRVLRV02',,4,0)	//- "N�o � possivel desfazer esta revis�o // A revis�o selecionada n�o � a revis�o atual do contrato."
	CASE !lRevVig
		 lRet := .F.
		 Help(" ",1, 'Help','CNDRVLRV03',,4,0)	//, "N�o � possivel desfazer esta revis�o // Somentes revis�es vigentes ou paralizadas podem ser desfeitas."
	OTHERWISE
		lRet := .T.
END DO

FWRestRows(aSaveLine)
RestArea(aArea)
Return lRet
//==============================================================================================================================
/*/{Protheus.doc} CnDrVlNEmp - Fun��o que valida o total empenhado X valor do produto do contrato da revisao anterior
@author		Israel.Escorizza
@since		16/03/2018
@version	P12.1.21

Original	A300GEmpAnt()
@author 	Hermes Ferreira
@since 		17/08/2015
@version 	12.7
/*/
//==============================================================================================================================
Function CnDrVlNEmp(cCtrFil, cCtrNum, cCtrRev)
Local aArea		:= GetArea() 
Local aAreaCN9	:= CN9->(GetArea())
Local aSaveLine	:= FWSaveRows()

Local lRet 		:= .T.

Local clAlias	:= ""
Local cRevAnt	:= ""
Local cQuery		:= ""

Default cCtrFil	:= CN9->CN9_FILIAL
Default	cCtrNum	:= CN9->CN9_NUMERO
Default cCtrRev	:= CN9->CN9_REVISA


If Cn300RetSt('COMPRA')
	cRevAnt  	:= CnRevAnt(.F.)
	
	cQuery := " SELECT "
	cQuery += " CNB_PRODUT, CNB_DESCRI "
	cQuery += " ,SUM(CX1_VLREMP) AS CX1_VLREMP "
	cQuery += " ,SUM(CNB_VLTOT ) AS CNB_VLTOT  "
	cQuery += " FROM "+RetSqlName("CN9")+" CN9 "
	
	cQuery += " JOIN  "+RetSqlName("CNA")+" CNA "
	cQuery += " ON CNA_FILIAL = CN9_FILIAL "
	cQuery += " AND CNA_CONTRA =  CN9_NUMERO ""
	cQuery += " AND CNA_REVISA =  CN9_REVISA "
	cQuery += " AND CNA_NUMERO  > ' ' "
	cQuery += " AND CNA.D_E_L_E_T_= ' ' "
	
	cQuery += " JOIN  "+RetSqlName("CNB")+" CNB "
	cQuery += " ON CNB_FILIAL = CNA_FILIAL "
	cQuery += " AND CNB_CONTRA = CNA_CONTRA "
	cQuery += " AND CNB_REVISA = CNA_REVISA "
	cQuery += " AND CNB_NUMERO = CNA_NUMERO "
	cQuery += " AND CNB_ITEM > ' ' "
	cQuery += " AND CNB.D_E_L_E_T_= ' ' "
	
	cQuery += " JOIN  "+RetSqlName("CX0")+" CX0 "
	cQuery += " ON CX0_FILIAL = '"+xFilial("CX0")+"' "
	/*cQuery += " AND CX0_CTR = CN9_NUMERO "*/
	cQuery += " AND CX0_CODEDT = CN9_CODED "
	cQuery += " AND CX0_NUMPRO = CN9_NUMPR "
	/*cQuery += " AND CX0_NUMPLA = CNA_NUMERO "*/
	cQuery += " AND CX0_TPEMP IN (' ', '3') "
	cQuery += " AND CX0.D_E_L_E_T_= ' ' "
	
	cQuery += " JOIN  "+RetSqlName("CX1")+" CX1 "
	cQuery += " ON CX1_FILIAL = CX0_FILIAL "
	cQuery += " AND CX1_CODNE = CX0_CODNE "
	cQuery += " AND CX1_CODPRO = CNB_PRODUT "
	cQuery += " AND CX1.D_E_L_E_T_= ' ' "
	
	cQuery += " WHERE "
	cQuery += " 	CN9_FILIAL = '" + cCtrFil +"' "
	cQuery += " AND CN9_NUMERO = '" + cCtrNum +"' "
	cQuery += " AND CN9_REVISA = '" + cRevAnt +"' "
	cQuery += " AND CN9.D_E_L_E_T_= ' ' "
	
	cQuery += " GROUP BY CNB_PRODUT,CNB_DESCRI "
	
	cQuery := ChangeQuery(cQuery)
	clAlias := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),clAlias,.F.,.T.)
	
	TcSetField(clAlias,"CX1_VLREMP"	,GetSx3Cache("CX1_VLREMP","X3_TIPO"),TamSx3("CX1_VLREMP")[1],TamSx3("CX1_VLREMP")[2])
	TcSetField(clAlias,"CNB_VLTOT"	,GetSx3Cache("CNB_VLTOT","X3_TIPO")	,TamSx3("CNB_VLTOT")[1]	,TamSx3("CNB_VLTOT")[2]	)
	
	(clAlias)->(dbGoTop())
	If (clAlias)->(! Eof())
		While lRet .And. (clAlias)->(!Eof())
			If (clAlias)->CX1_VLREMP > (clAlias)->CNB_VLTOT
				lRet := .F.
				Help(,,"CnDrVlNEmp",,"O valor empenhado deve ser menor ou igual ao valor do produto do Contrato da revis�o anterior." + CRLF + CRLF; //- "O valor empenhado deve ser menor ou igual ao valor do produto do Contrato da revis�o anterior."
					+ "Produto: " + Alltrim((clAlias)->CNB_PRODUT) + " - "+ Alltrim((clAlias)->CNB_DESCRI)+ CRLF ; //- "Produto: "
					+ "Valor Empenhado: " + Alltrim(Transform((clAlias)->CX1_VLREMP,PesqPict("CX1", "CX1_VLREMP")))+ CRLF ;//- "Valor Empenhado: "
					+ "Valor Contrato/Edital: " + Alltrim(Transform((clAlias)->CNB_VLTOT,PesqPict("CNB", "CNB_VLTOT"))), 1, 0)	 //- "Valor Contrato/Edital: "
			EndIf
			(clAlias)->(dbSkip())
		EndDo
	EndIf
	(clAlias)->(dbCloseArea())
EndIf

FWRestRows(aSaveLine)
RestArea(aAreaCN9)
RestArea(aArea)
Return lRet

//==============================================================================================================================
/*/{Protheus.doc} CnDrVlAdia- Fun��o respons�vel por verificar se existe adiantamento para a revis�o sendo desfeita
@author		Israel.Escorizza
@since		16/03/2018
@version	P12.1.21
/*/
//==============================================================================================================================
Function CnDrVlAdia(cCtrFil, cCtrNum, cCtrRev)
Local aArea     := GetArea() 
Local aSaveLine := FWSaveRows()

Local lRet      := .T.
Local lRevGer   := CNX->(Columnpos('CNX_REVGER')) > 0

Local cAliasCNX := ""
Local cQuery	  := ""

Default cCtrFil := CN9->CN9_FILIAL
Default cCtrNum := CN9->CN9_NUMERO
Default cCtrRev := CN9->CN9_REVISA

cQuery += " SELECT CNX.R_E_C_N_O_ "
cQuery += " FROM " + RetSqlName("CNX") + " CNX 	"

If Cn300RetSt('COMPRA')
	cQuery += " INNER JOIN " + RetSqlName("SE2") + " SE2 ON "
	cQuery += "		SE2.D_E_L_E_T_= ' ' AND "
	cQuery += "		SE2.E2_FILIAL  = CNX.CNX_FILIAL AND "
	cQuery += "		SE2.E2_MDCONTR = CNX.CNX_CONTRA AND "
	cQuery += "		(
	If lRevGer
		cQuery += "		SE2.E2_MDREVIS = CNX.CNX_REVGER OR "
	EndIf
	cQuery += "			SE2.E2_MDREVIS = '" + cCtrRev + "'"
	cQuery += "		)"
Else
	cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 ON "
	cQuery += "		SE1.D_E_L_E_T_= ' ' AND "
	cQuery += "		SE1.E1_FILIAL  = CNX.CNX_FILIAL AND "
	cQuery += "		SE1.E1_MDCONTR = CNX.CNX_CONTRA AND "
	cQuery += "		(
	If lRevGer
		cQuery += "		SE1.E1_MDREVIS = CNX.CNX_REVGER OR "
	EndIf
	cQuery += "			SE1.E1_MDREVIS = '" + cCtrRev + "'"
	cQuery += "		)"
EndIf

cQuery += "WHERE "
cQuery += "		CNX.D_E_L_E_T_= ' '	AND"
cQuery += "		CNX.CNX_FILIAL = '" + cCtrFil + "' 	AND"
cQuery += "		CNX.CNX_CONTRA = '" + CN9->CN9_NUMERO + "'"

If lRevGer
	cQuery += "	AND CNX.CNX_REVGER = '" + cCtrRev + "'  "
EndIf

cQuery 		:= ChangeQuery(cQuery)
cAliasCNX 	:= GetNextAlias()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNX,.F.,.T.)

If !(cAliasCNX)->(EOF())
	lRet := .F.
	Help(" ",1,'CNDRVLAD01',,"N�o � possivel desfazer esta revis�o. Existem adiantamentos vinculados a esta revis�o.",4,0)	// "N�o � possivel desfazer esta revis�o // Existem adiantamentos vinculados a esta revis�o."
EndIf
(cAliasCNX)->(dbCloseArea())

FWRestRows(aSaveLine)
RestArea(aArea)
Return lRet

//==============================================================================================================================
/*/{Protheus.doc} CnDrVlCauc - Fun��o respons�vel por verificar se existe cau��o para a revis�o sendo desfeita
@author		Eduardo Gomes J�nior
@since		21/03/2018
@version	P12.1.21
/*/
//==============================================================================================================================
Function CnDrVlCauc(cContra , cRev , cFiCtr, lDesfazRV)
	Local aArea		:= GetArea()
	Local cAliasCN8	:= GetNextAlias()
	Local lRevGer	:= CN8->(Columnpos('CN8_REVGER')) > 0
	Local lRet		:= .T.
	Local cWhere	:= "%%"
	Default lDesfazRV:= FwIsInCallStack("CN300DesRv")
 	
	If	lRevGer
		If lDesfazRV//Se for durante o processo de desfazer uma revis�o
			cWhere := "% AND CN8_DTBX <> '"+ Space(8) +"'%" //valida apenas os cau��es baixados
		EndIf

		BeginSQL Alias cAliasCN8
		
			SELECT	CN8.CN8_CODIGO
			FROM 	%Table:CN8% CN8
			WHERE	CN8.CN8_FILIAL = %Exp:cFiCtr% AND
					CN8.CN8_CONTRA = %Exp:cContra% AND
					CN8.CN8_REVGER = %Exp:cRev% AND
					CN8.%NotDel%
					%exp:cWhere%					
		EndSQL
		
		If !(lRet := (cAliasCN8)->(EOF()))
			Help(,,"CNDRVLCAUC",,I18N(STR0001, {IIF(lDesfazRV, STR0003, STR0002)});//N�o foi poss�vel #1 pois existem cau��es para o contrato.
								,1,0,,,,,,{I18N(STR0004, {IIF(lDesfazRV, STR0005, " ")})})//Verifique a exist�ncia de cau��es #1 para o contrato			
		
		EndIf
		(cAliasCN8)->(dbCloseArea())
	EndIf

	RestArea(aArea)
	FwFreeArray(aArea)
Return lRet

//==============================================================================================================================
/*/{Protheus.doc} CNRDVlMed()
Valida se existem medicoes geradas para uma determinada revisao

@param 	cContra	, Numero do Contrato
		cRev	, Numero da Revisao
		cFilCtr	, Filial do contrato
		
@return L�gico	, .T. - Existe Medicoes geradas na revisao
				  .F. - Nao existem medicoes geradas na revisao
				  
@author jose.delmondes
@since 16/03/2018
/*/
//==============================================================================================================================
Function CNDRVlMed( cContra , cRev , cFiCtr )
Local aArea	:= GetArea()
Local cAliasCND	:= GetNextAlias()
Local lRet	:= .F.

BeginSQL Alias cAliasCND

	SELECT	CND.CND_NUMMED
	FROM 	%Table:CND% CND
	WHERE	CND.%NotDel% AND
			CND.CND_FILCTR = %Exp:cFiCtr% AND
			CND.CND_CONTRA = %Exp:cContra% AND
			CND.CND_REVGER = %Exp:cRev%
	
EndSQL

If (cAliasCND)->(EOF())
	lRet := .T.
Else	
	Help(" ",1,'Help','CNDRVLMD01',,4,0)	//, "N�o � possivel desfazer esta revis�o // Existem medi��es encerradas na revis�o."
EndIf

(cAliasCND)->(dbCloseArea())
RestArea(aArea)	
Return lRet
//==============================================================================================================================
/*/{Protheus.doc} CnDrPrTit - Fun��o respons�vel por estornar os titulos provis�rios da revis�o sendo desfeita e restaurar os da
revis�o anterior.

@author		Israel.Escorizza
@since		16/03/2018
@version	P12.1.21
/*/
//==============================================================================================================================
Function CnDrPrTit(cCtrFil, cCtrNum,cCtrRev)
Local aArea		:= GetArea() 
Local aSaveLine	:= FWSaveRows()
Local aAreaCN9		:= CN9->(GetArea()) 

Local lRet		:= .T.
Local lTitProv	:= SuperGetMV("MV_CNPROVI",.F.,"S") == "S"
Local cRevAnt  	:= ""

Default cCtrFil	:= CN9->CN9_FILIAL
Default cCtrNum	:= CN9->CN9_NUMERO
Default cCtrRev	:= CN9->CN9_REVISA

cRevAnt  	:= CnRevAnt(.F.)

//- Estorna titulos provis�rios
CN100ETit(cCtrNum,cCtrRev)
CnContab("69K")					//- Lan�amentos cont�beis ao desfazer revis�o do contrato

If 	lTitProv
	CN9->(dbSetOrder(1))
	If 	CN9->(dbSeek(cCtrFil + cCtrNum + cRevAnt ))
		CN100CTit(cCtrNum,cRevAnt)
		CN100RecTi(cCtrNum,cRevAnt)
	EndIf
EndIf

FWRestRows(aSaveLine)
RestArea(aArea)
RestArea(aAreaCN9)
Return lRet

//==============================================================================================================================
/*/{Protheus.doc} CNDRSituac( cContra, cRevAtu)
Atualiza situa��o das revis�es atual e anterior

@param 	cContra	, Numero do Contrato
		cRev	, Numero da Revisao
				  
@author jose.delmondes
@since 16/03/2018
/*/
//==============================================================================================================================
Function CNDRSituac( cContra, cRevAtu)
Local aArea	:= GetArea()
Local aAreaCN9	:= CN9->(GetArea())
Local cRevAnt	:= CnRevAnt( .F. , cRevAtu )
Local lRet	:= .T.

dbSelectArea("CN9")
dbsetOrder(1)

// Atualiza situa��o da revis�o anterior para vigente
If dbseek( xFilial("CN9") + cContra + cRevAnt )
	If !Empty(CN9->CN9_MOTPAR) .And. Empty(CN9->CN9_DTREIN)
		RecLock("CN9",.F.)
		CN9->CN9_SITUAC := '06'
		CN9->(MsUnlock())
	Else
		RecLock("CN9",.F.)
		CN9->CN9_SITUAC := '05'
		CN9->(MsUnlock())
	EndIf
EndIf

// Atualiza situa��o da revis�o atual para em revis�o
If dbseek( xFilial("CN9") + cContra + cRevAtu )
	RecLock("CN9",.F.)
	CN9->CN9_SITUAC := '09'
	CN9->(MsUnlock())
EndIf

RestArea(aAreaCN9)
RestArea(aArea)
Return lRet

//==============================================================================================================================
/*/{Protheus.doc} CnDrPrAFor - Fun��o respons�vel por estornar as avalia��es de fornecedores da revis�o sendo desfeita.

@author		Israel.Escorizza
@since		20/03/2018
@version	P12.1.21
/*/
//==============================================================================================================================
Function CnDrPrAFor(cCtrFil, cCtrNum,cCtrRev)
Local aArea		:= GetArea() 
Local aSaveLine	:= FWSaveRows()
Local lValida	:= CNM->(Columnpos('CNM_REVGER')) > 0
Local lRet		:= .T.
Local cAliasCNM	:= GetNextAlias()

Default cCtrFil	:= CN9->CN9_FILIAL
Default cCtrNum	:= CN9->CN9_NUMERO
Default cCtrRev	:= CN9->CN9_REVISA

If lValida
	CNM->(dbSetOrder(1))
	CN9->(dbSetOrder(1))
	lRet := CN9->(dbSeek(cCtrFil + cCtrNum + cCtrRev ))
	
	If 	lRet
		BeginSQL Alias cAliasCNM
			SELECT 	CNM.R_E_C_N_O_ RECNO
			FROM 	%Table:CNM% CNM
			WHERE	CNM.%NotDel% AND
					CNM.CNM_FILIAL = %Exp:cCtrFil% AND
					CNM.CNM_CONTRA = %Exp:cCtrNum% AND
					CNM.CNM_REVGER = %Exp:cCtrRev%
		EndSQL
		
		While lRet .And. !(cAliasCNM)->(EOF())
			CNM->(dbGoTo( (cAliasCNM)->RECNO ) )
			RecLock('CNM', .F.)
			CNM->(dbDelete())
			CNM->(MsUnLock())
			
			(cAliasCNM)->(dbSkip())
		EndDo
	EndIf

	If !lRet
		Help(" ",1,'Help','CNDDPRAF01',,4,0)	//, "N�o foi possivel excluir  // ."
	EndIf
EndIf

FWRestRows(aSaveLine)
RestArea(aArea)
Return lRet

//==============================================================================================================================
/*/{Protheus.doc} CNDRcalc - Fun��o respons�vel por estornar o Cal��o

@author		Ronaldo.Tadeu
@since		21/03/2018
@version	P12.1.21
/*/
//==============================================================================================================================

Function CNDRcalc(cContra, cRevAtu )
	Local cRevAnt	:= CnRevAnt( .F. , cRevAtu )
	Local lRet	:= .T.
	Local cAliasCN8	:= GetNextAlias()
	
	BeginSql Alias cAliasCN8
		Select *
		From %table:CN8% CN8
		Where
		CN8.CN8_FILIAL = %xfilial:CN8% and CN8.%notdel%
		and CN8.CN8_CONTRA = %exp:cContra%
		and CN8.CN8_REVISA = %exp:cRevAtu%
	EndSql
	
	While !(cAliasCN8)->(EOF())
		DbSelectArea("CN8")
		CN8->(dbSetOrder(1))
		If DbSeek(xFilial('CN8')+(cAliasCN8)->CN8_CODIGO)
			Reclock( "CN8", .F.)
			CN8->CN8_REVISA := cRevAnt
			CN8->(MsUnlock())
		EndIf
		
		(cAliasCN8)->(DbSkip())
	EndDo
	
Return lRet

/*/{Protheus.doc} DelCPDRev
	Deleta os registros gerados na CPD durante a aprova��o de uma revis�o que incluiu alguma planilha.
A query busca todas as planilhas da revis�o atual(cRevAtu) que n�o tem uma correspondente na revis�o anterior.
@author philipe.pompeu
@since 17/06/2021
@param cFilCtr, caractere, filial do contrato
@param cContra, caractere, numero do contrato
@param cRevAtu, caractere, revisao atual
@return Nil, indefinido
/*/
Static Function DelCPDRev(cFilCtr  as character, cContra  as character, cRevAtu as Character)
	Local cMyAlias	:= GetNextAlias()	
	Local cCNAFil 	:= xFilial("CNA", cFilCtr)
	Local cCPDFil 	:= xFilial("CPD", cFilCtr)
	Local cRevAnt	:= CnRevAnt(.F., cRevAtu)

	BeginSql Alias cMyAlias

		SELECT CPD.R_E_C_N_O_ RECCPD, CNA1.CNA_NUMERO, CNA1.CNA_REVISA, ISNULL(CNA2.CNA_REVISA, 'DEL') REVANT 
		FROM %table:CNA% CNA1		
		LEFT JOIN %table:CNA% CNA2 ON(
				CNA2.CNA_FILIAL = CNA1.CNA_FILIAL
			AND CNA2.CNA_CONTRA = CNA1.CNA_CONTRA
			AND CNA2.CNA_NUMERO = CNA1.CNA_NUMERO
			AND CNA2.CNA_REVISA	= %exp:cRevAnt%
			AND CNA2.%notdel%)		
		INNER JOIN %table:CPD% CPD ON(CPD_FILIAL = %exp:cCPDFil% AND CPD_CONTRA = CNA1.CNA_CONTRA AND CPD_NUMPLA = CNA1.CNA_NUMERO AND CPD.%notdel%)
		WHERE 
			CNA1.CNA_FILIAL = %exp:cCNAFil%
		AND CNA1.CNA_CONTRA = %exp:cContra%
		AND CNA1.CNA_REVISA = %exp:cRevAtu%
		AND CNA1.%notdel%
		AND ISNULL(CNA2.CNA_REVISA, 'DEL') = 'DEL'
	EndSql
	
	While (cMyAlias)->(!Eof())		
		CPD->(DbGoTo((cMyAlias)->RECCPD))
		RecLock("CPD",.F.)
		CPD->(DbDelete())
		CPD->(MsUnlock())
		(cMyAlias)->(DbSkip())
	EndDo
	
	(cMyAlias)->(dbCloseArea())
Return Nil
