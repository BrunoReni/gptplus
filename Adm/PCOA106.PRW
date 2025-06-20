#INCLUDE "PCOA106.CH"
#INCLUDE "PROTHEUS.CH"

Static cChave    
Static nQtdEntid 
Static __oSeekAK2
Static __oNewAK2

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOA106   �Autor  �Daniel Carlos       � Data �  10/27/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para Preencher a Planilha Atual com dados da Area   ���
���          � de Integra��o.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOA106(cPlanOri, cRevOri, cCtaOri, aPeriodo)
Local oWizard
Local cArquivo
Local aAreaAK1 := AK1->(GetArea())
Local aAreaAK2 := AK2->(GetArea())
Local aAreaAK3 := AK3->(GetArea())
Local aAreaAKE := AKE->(GetArea())
Local lRet 		:= .F.
Local lParamAMJ, lParamOri, lParamCpos, lBrowse:=.T., lParam2 

Local aBoxAMJ 		:= {}
Local aRetBoxAMJ	:= {}

Local aBoxOri 		:= {}
Local aRetBoxOri 	:= {}   

Local aCampos		:= {	{"AMJ_CLASSE"	,.T.},;
								{"AMJ_OPER"		,.T.},;
								{"AMJ_CC"		,.T.},;
								{"AMJ_ITCTB"	,.T.},;
								{"AMJ_CLVLR"	,.T.}}
Local aBoxCpos 	:= { 	{ 5, Posicione("SX3",2,aCampos[1][1],"X3Titulo()"),.T.,120,,.F.},;
								{ 5, Posicione("SX3",2,aCampos[2][1],"X3Titulo()"),.T.,120,,.F.},;
								{ 5, Posicione("SX3",2,aCampos[3][1],"X3Titulo()"),.T.,120,,.F.},;
								{ 5, Posicione("SX3",2,aCampos[4][1],"X3Titulo()"),.T.,120,,.F.},;
								{ 5, Posicione("SX3",2,aCampos[5][1],"X3Titulo()"),.T.,120,,.F.} }
Local aRetBoxCpos	:= {	.T.,;
								.T.,;
								.T.,;
								.T.,;
								.T.}

Local cAK1Fase 	:= AK1->AK1_FASE 

Local nI := 0 

DEFAULT cPlanOri 	:= AK1->AK1_CODIGO
DEFAULT cRevOri 	:= IF(Empty(AK1->AK1_VERREV), AK1->AK1_VERSAO, AK1->AK1_VERREV)
DEFAULT cCtaOri 	:= AK3->AK3_CO
DEFAULT aPeriodo 	:= PcoRetPer()  

aAdd(aCampos,		{"AMJ_UNIORC",.T.})
aAdd(aBoxCpos,	{ 5, Posicione("SX3",2,aCampos[6][1],"X3Titulo()"),.T.,120,,.F.})
aAdd(aRetBoxCpos,	.T.)

If nQtdEntid == NIL 
	If cPaisLoc == "RUS" 
		nQtdEntid := PCOQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
	Else
		nQtdEntid := CtbQtdEntd()//sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf

For nI := 5 to nQtdEntid
	aAdd(aCampos, {"AMJ_ENT" + StrZero(nI,2,0),.T.})
	aAdd(aBoxCpos, { 5, Posicione("SX3",2,aCampos[nI+2][1],"X3Titulo()"),.T.,120,,.F.})
	aAdd(aRetBoxCpos, .T.)
Next nI 

aBoxAMJ 		:= {	{ 1 ,STR0001,Replicate(" ",LEN(AMK->AMK_PROCESS)) ,"@!" 	 ,"Vazio() .Or. ExistCpo('AKB')"  ,"AKB" ,"" ,65 ,.F. }, ; //"Processo"
						{ 1 ,STR0002,Replicate(" ",LEN(AMK->AMK_ITEM)) ,"@!" 	 ,""  ,"" ,"" ,65 ,.F. }, ; // "Item"
						{ 1, STR0003,CTOD("  /  /  "),"@d" 	 ,"MV_PAR03>=CtoD('"+Subs(aPeriodo[1], 1, 10)+"')"  ,""    ,"" ,50 ,.T. },; //"Per�odo de"
						{ 1, STR0004,CTOD("  /  /  "),"@d" 	 ,"MV_PAR04>=MV_PAR03 .And. MV_PAR04<=CtoD('"+Alltrim(Subs(aPeriodo[Len(aPeriodo)], 14))+"')"  ,""    ,"" ,50 ,.T. },; //"Per�odo At�"
						{ 7, STR0005,"AMJ",""}} //"Filtro Integra��o - AMJ"

aRetBoxAMJ	:= {	Replicate(" ",LEN(AMK->AMK_PROCESS)),;
						Replicate(" ",LEN(AMK->AMK_ITEM)),;
						CtoD(Subs(aPeriodo[1], 1, 10)),;
						CtoD(Alltrim(Subs(aPeriodo[Len(aPeriodo)], 14))),;
						" "}   

AK3->(DbSetOrder(1))
AK3->(dbSeek(xFilial("AK3")+cPlanOri+cRevOri+cPlanOri))

cChave := "" //-- Vari�vel Est�tica para controle do Parambox de Filtro de Origem no Wizard

//-- Controle de Fases
If PcoVldFase('AMR',cAK1Fase,'0004',.T.) .And. PcoVldFase('AMR',cAK1Fase,'0005',.T.)

	oWizard := APWizard():New(	STR0006/*<chTitle>*/,; //"Atencao"
								STR0013/*<chMsg>*/  ,; //"Este assistente lhe ajudar� importar dados da �rea de Integra��o para a planilha atual."
								STR0014/*<cTitle>*/ ,; //"Importar Dados da �rea de Integra��o"
								STR0015+CRLF+CRLF+; //"O sistema ir� importar os dados da �rea de integra��o conforme os par�metros solicitados."
								STR0035+CRLF+CRLF+; //"Caso os dados sejam importados do ERP, configurados atrav�s dos processos e pontos de lan�amento, na pr�xima tela, preencha os campos 'Processo?' e 'Item?'."
								STR0036+CRLF+CRLF+; //"Caso os dados sejam importados do arquivo XML, na pr�xima tela, n�o preencha os campos 'Processo?' e 'Item?'."
								STR0037/*<cText>*/,;//"Desta forma, o sistema consegue identificar qual a oigem dos dados importados na tabela AMJ (�rea de integra��o)." 
								{||.T.}/*<bNext>*/ ,{||.T.}/*<bFinish>*/,/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

	oWizard:NewPanel( STR0008/*<chTitle>*/,; //"Configura��o da Integra��o"
						 STR0009/*<chMsg>*/, ; //"Neste passo, voc� dever� selecionar os par�metros para filtrar a �rea de Integra��o"
						 {||.T.}/*<bBack>*/, ;
						 {||ParamOk(aBoxAMJ, aRetBoxAMJ) }/*<bNext>*/, ;
						 {||.T.}/*<bFinish>*/,;
						 .T./*<.lPanel.>*/,;
						 {||A106Box(oWizard,@lParamAMJ, aBoxAMJ, aRetBoxAMJ)}/*<bExecute>*/ )
					  
	oWizard:NewPanel( STR0010/*<chTitle>*/,; //"Configura��o da Origem"
						 STR0017/*<chMsg>*/, ; //"Neste passo, voc� dever� selecionar os par�metros para filtrar a dados da tabela de Origem"
						 {||.T.}/*<bBack>*/, ;
						 {||ParamOk(aBoxOri, aRetBoxOri) }/*<bNext>*/, ;
						 {||.T.}/*<bFinish>*/,;
						 .T./*<.lPanel.>*/,;
						 {|| A106Ori(aRetBoxAMJ,aBoxOri,aRetBoxOri), A106Box(oWizard,@lParamOri, aBoxOri, aRetBoxOri, .T. )}/*<bExecute>*/ )

	oWizard:NewPanel( STR0018/*<chTitle>*/,; //"Configura��o de Campos"
						 STR0019/*<chMsg>*/, ; //"Neste passo, voc� dever� selecionar os Campos que ser�o trazidos da �rea de Integra��o"
						 {|| .T.}/*<bBack>*/, ;
						 {|| ParamOk(aBoxCpos, aRetBoxCpos) }/*<bNext>*/, ;
						 {|| Processa({|| lRet := A106Proc(cPlanOri, cRevOri, cCtaOri, aRetBoxAMJ, aRetBoxORI, aRetBoxCpos, aPeriodo, aCampos) },"Aguarde","Buscando Informa��es Integradas..."),.T.}/*<bFinish>*/,;
						 .T./*<.lPanel.>*/,;
						 {|| A106Box(oWizard,@lParamCpos, aBoxCpos, aRetBoxCpos)}/*<bExecute>*/ )

	oWizard:Activate( .T./*<.lCenter.>*/,;
						 {||.T.}/*<bValid>*/, ;
						 {||.T.}/*<bInit>*/, ;
						 {||.T.}/*<bWhen>*/ )

Else

	Help("   ",1,"NOAK1FASEPCOA106",,STR0020,3,0) // "A��o n�o permitida pelo Controle de Fases!"
	lRet := .F.

EndIf

RestArea(aAreaAK1)
RestArea(aAreaAK2)
RestArea(aAreaAK3)
RestArea(aAreaAKE)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A106Proc  �Autor  �Daniel Carlos       � Data �  10/28/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao principal do processamento da Importacao dos dados  ���
���          � da Area de Integracao com a Planilha Orcamentaria.         ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A106Proc(cPlanOri, cRevOri, cCtaOri,aRetBoxAMJ,aRetBoxORI,aRetBoxCpos,aPeriodo,aCampos)
Local aAreas 	:= {	AKB->(GetArea()),;
							AMJ->(GetArea()),;
							AK3->(GetArea()),;
							SX3->(GetArea()),;
							GetArea()}

Local lJoin := A106Join(aRetBoxAMJ)

Local cQuery 		:= ""
Local cSelect		:= ""
Local cFrom  		:= ""
Local cJoin  		:= ""
Local cWhere 		:= ""
Local cGrpBy 		:= ""
Local cOrdBy 		:= ""
Local cWhereAux 	:= ""
Local cWhereAMD 	:= ""
Local cAliasQry 	:= ""

Local cFiltAux 	:= ""
Local cFiltOri 	:= ""

Local lContinua 	:= .T.
Local lResolvQry 	:= .T.
Local lGrava 		:= .T.
Local lValidSQL	:= .F.
Local bError

Local aCtasSup		:= {}
Local aCtasInf		:= {}

Local nI, nJ, nTo, nCta, nLenCta, nTentativas, nLimRubrica, nValAcum  

Local aParA106 := {} 
Local nX := 0
                      
IncProc(STR0021) // "Criando mecanismo de Pesquisa..."

//-- Montagem da Clausula "SELECT"
cSelect := " SELECT "

//-- Somente Campos Selecionados para agrupamento ser�o preenchidos
aEval(aCampos,{ |x,y| cSelect += Iif(aRetBoxCpos[y], x[1]+ ", ", "") })

//-- Soma os campos de Valor de 1 a 5
nTo := 5
For nI := 1 To nTo
	cSelect += "    SUM(CASE "
	cSelect += "             WHEN AMJ_TIPO = '1' THEN" //-- Credito - Soma
	cSelect += "                  AMJ_VALOR"+AllTrim(Str(nI))
	cSelect += "             WHEN AMJ_TIPO = '2' THEN" //-- Debito - Subtrai
	cSelect += "                  AMJ_VALOR"+AllTrim(Str(nI))+" * (-1) "
	cSelect += "             ELSE 0 "
	cSelect += "        END) AMJ_VALOR" + AllTrim(Str(nI)) + ", "

Next nI
cSelect := Left(cSelect,Len(cSelect)-2) + " "

//-- Montagem da clausula "FROM"
cFrom := " FROM " + RetSqlName("AMJ") + " AMJ "

//-- Verifica se foi informado Processo+Item para realizar JOIN entre a �rea de Integra��o e a Tabela de Origem.
//-- Importante: Quando preenchido, Processo+Item � o mesmo para todos os n�veis da estrutura
If lContinua .And. lJoin
	        
	//-- Posicionar AKB
	AKB->(DbSetOrder(1)) //-- AKB_FILIAL+AKB_PROCES+AKB_ITEM
	lContinua := AKB->(MsSeek(xFilial("AKB") + aRetBoxAMJ[1] + aRetBoxAMJ[2] ))
	
	If lContinua

		//-- Verifica se � poss�vel resolver express�o SQL para ligar a �rea de Integra��o � tabela de Origem
		cJoin := PCOSQLJoin( AKB->AKB_ENTIDA /*cAlias*/, AKB->AKB_INDICE /*nIndice*/, "AMJ_CHAVE"/*cCpoChave*/)
	
		//-- Se houver como resolver express�o de igualdade para o JOIN, liga-o � query
		If !Empty( cJoin ) 

			cJoin := " JOIN " + RetSqlName(AKB->AKB_ENTIDA) + " " + AKB->AKB_ENTIDA + " ON " + cJoin
			
		Else
			
			lJoin := .F.
	
		EndIf

	EndIf

EndIf

//-- Montagem da Clausula "WHERE"
cWhere := " WHERE "
cWhere += "    AMJ_FILIAL = '"+xFilial("AMJ")+"' "
cWhere += "    AND AMJ.D_E_L_E_T_ = ' ' "
If lContinua .And. !Empty(aRetBoxAMJ[1]) .And. !Empty(aRetBoxAMJ[2])
	cWhere += "    AND AMJ_PROCES = '"+aRetBoxAMJ[1]+"' "	
	cWhere += "    AND AMJ_ITEM   = '"+aRetBoxAMJ[2]+"' "	
ElseIf lContinua .And. Empty(aRetBoxAMJ[1]) .And. Empty(aRetBoxAMJ[2])
	cWhere += "    AND AMJ_PROCES = '"+Space(Len(AMK->AMK_PROCESS))+"' "	
	cWhere += "    AND AMJ_ITEM   = '"+Space(Len(AMK->AMK_ITEM))+"' "	
EndIf
//-- Data maior ou igual � menor data do primeiro per�odo
cWhere += "    AND AMJ_DATPLA >= '" + DtoS(aRetBoxAMJ[3]) + "' "
//-- Data menor ou igual � maior data do �ltimo per�odo
cWhere += "    AND AMJ_DATPLA <= '" + DtoS(aRetBoxAMJ[4]) + "' "

//-- Verifica se possui filtro na tabela de integra��o e se � poss�vel resolv�-lo na Query
If !Empty(aRetBoxAMJ[5])
  	cWhereAux := PcoParseFil(aRetBoxAMJ[5], "AMJ")
	If Empty(cWhereAux)
		lResolvQry 	:= .F.
   	cFiltAux += If( !Empty(cFiltAux), " .And. ", "") + "( " + aRetBoxAMJ[5] + ")"
	Else
		cWhere += " AND (" + cWhereAux + ") "
	EndIf
EndIf

//-- Verifica se possui filtro na tabela de Origem e se � poss�vel resolv�-lo na Query
If lContinua .And. lJoin .And. Len(aRetBoxOri) > 0 .And. !Empty(aRetBoxOri[1])
	If !Empty( cJoin ) 
	  	cWhereAux := PcoParseFil(aRetBoxOri[1], AKB->AKB_ENTIDA)
		If Empty(cWhereAux)
			lResolvQry 	:= .F.
	   	cFiltOri += If( !Empty(cFiltOri), " .And. ", "") + "( " + aRetBoxOri[1] + ")"
		Else
			cWhere += " AND (" + cWhereAux + ") "
		EndIf
	Else
		Help("   ",1,"NOTABORIPCOA106",,STR0022,3,0) // "N�o foi poss�vel a liga��o com a tabela de Origem. Verifique os par�metros de Importa��o!"
		lContinua := .F.
	EndIf
EndIf

//-- Montagem da Clausula "GROUP BY"
cGrpBy := " GROUP BY "
aEval(aCampos,{ |x,y| cGrpBy += Iif(aRetBoxCpos[y], x[1]+", ", "")  })
cGrpBy := Left(cGrpBy, Len(cGrpBy)-2)

//-- Montagem da Clausula "ORDER BY" 
cOrdBy := " "

//-- Se for necess�rio aplica��o de Filtro Advpl, n�o agrupa as informa��es.                                                             
If !lResolvQry

	//-- Limpa a Cl�sula "GROUP BY" da query
	cGrpBy := ""

	//-- Adiciona o Recno da tabela de Integra��o - AMJ - aos campos do Select
	cSelect += ", AMJ.R_E_C_N_O_ REC_AMJ "

	//-- Adiciona o Recno da tabela de origem aos campos do Select, se houver Join
	If !Empty(cJoin)
		cSelect += ", " + AKB->AKB_ENTIDA +".R_E_C_N_O_ REC_ORIG "
   EndIf

	//-- Retira a Sumariza��o do select, pois n�o haver� "GROUP BY"
	cSelect := StrTran(cSelect, "SUM", "")

EndIf          

AK3->(DbSetorder(1))
//-- Posiciona AK3
If (lContinua := lContinua .And. AK3->(DbSeek(xFilial("AK3")+cPlanOri+cRevOri+cCtaOri)) )

	If AK3->AK3_TIPO == '2'
		aAdd(aCtasInf,cCtaOri)
	EndIf
	a106CtaInf(cPlanOri,cRevOri,cCtaOri,aCtasInf,"AK3_TIPO == '2'")

EndIf

nLenCta	:= Len(aCtasInf)
nTo 	:= Len(aPeriodo)

ProcRegua( nTo * nLenCta )

//-- Percorre as Contas Orcamentarias para restringir a leitura na AMJ, pois n�o ser�o incluidas contas na Planilha Orcament�ria
For nCta := 1 To nLenCta

	//-- Bloqueia a conta orcamentaria 
	nTentativas := 0
	Do While (lContinua := (lContinua .And. ++nTentativas < 5)) .And. 	;
							!LockByName(xFilial("AK3")+cPlanOri+cRevOri+aCtasInf[nCta],.T.,.T.,.T.)
							
		Help("   ",1,"GRVITCOPCOA106",,STR0024 + RTrim(aCtasInf[nCta]) + STR0025,3,0) // "Aguardando o t�rmino da grava��o dos itens da conta " ## " por outro usu�rio."
		
	EndDo

	//-- Verifica se Conta Orcament�ria n�o fora exclu�da em outra sess�o.
	If lContinua
		aCtasSup := {}
		A106CtaSup( cPlanOri, cRevOri, aCtasInf[nCta], aCtasSup)
	
		//-- Isto somente vai ocorrer quando usuario excluir a conta orcamentaria em outra sessao
		If Empty(aCtasSup)  
			Help("   ",1,"NOCOPCOA106",,STR0016,3,0)// "Conta Orcamentaria nao encontrada, portanto as alteracoes nao foram gravadas. Verifique!!"
			lContinua := .F.
		EndIf					
	EndIf

	Begin Transaction
	
	PcoIniLan("000252")
   
	//-- Busca o Limite de Rubrica da Conta
	nLimRubrica := A106LimRub( cPlanOri, cRevOri, aCtasInf[nCta] )

	nValAcum    := 0

	//-- Se houver Limite de Rubrica, controla Valor na Conta
	If nLimRubrica > 0 
		nValAcum := A106VrCta( cPlanOri, cRevOri, aCtasInf[nCta] )
	EndIf
   
	For nI := 1  To nTo
	
		//-- Montagem da(s) query(ies) para cada per�odo do planejamento
		dIni := CtoD(Subs(aPeriodo[nI], 1, 10))
		dFim := CtoD(Alltrim(Subs(aPeriodo[nI], 14)))
	
		IncProc(STR0026) // "Processando Informa��es..."

		//-- Verifica se o Periodo da Planilha est� no Intervalo de datas da integra��o
		If !(dIni > aRetBoxAMJ[4] .Or. dFim < aRetBoxAMJ[3]) 
			cAliasQry := GetNextAlias()
			cWhereAux := " AND AMJ_DATPLA >= '" + DtoS(dIni) + "' "
			cWhereAux += " AND AMJ_DATPLA <= '" + DtoS(dFim) + "' "
			cWhereAux += " AND AMJ_CO = '" + aCtasInf[nCta] + "'" 
			
			cQuery := cSelect + cFrom + cJoin + cWhere + cWhereAux + cGrpBy + cOrdBy
			cQuery := ChangeQuery(cQuery)
		         
			If lContinua .And. !lValidSQL
				lValidSQL := .T.
				If !(lContinua := TcSQLExec( cQuery ) == 0)
					DisarmTransaction()
					Help("   ",1,"PRBLQRYPCOA106",,STR0027,3,0) //"Problemas encontrados na Constru��o da Consulta aos Dados de Integra��o! Verifique a configura��o de Integra��o!"
				EndIf			
			EndIf			

			If lContinua
				DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
				aEval(AMJ->(DbStruct()), {|x| Iif(x[2] <> 'C' .And. FieldPos(x[1]) > 0, TcSetField(cAliasQry,x[1],x[2],x[3],x[4]),Nil)})
			EndIf	
			
			Do While lContinua .And. (cAliasQry)->(!Eof())
			                        
				lGrava := .T.
				
				//-- Se existir filtro ADVPL dever� posicionar registros da AMJ / Join
				//-- para o correto funcionamento do Filtro
				If lContinua .And. (!Empty(cFiltAux) .Or. !Empty(cFiltOri))
					AMJ->(DbGoto((cAliasQry)->REC_AMJ))
					If !Empty(cJoin)
						(AKB->AKB_ENTIDA)->(DbGoto((cAliasQry)->REC_ORIG))
					EndIf
		
					//-- Se houver necessidade de execu��o de filtro definido pelo usu�rio, dever� ser executado em bloco de execu��o para que n�o
					//--    provoque ERROR.LOG
					bError := ErrorBlock({|| A106Error(@lContinua) })
					Begin Sequence
						lGrava := lGrava .And. (Empty(cFiltAux) .Or. AMJ->(&(cFiltAux)))
						lGrava := lGrava .And. (Empty(cFiltOri) .Or. (AKB->AKB_ENTIDA)->(&(cFiltOri)))
					End Sequence
					ErrorBlock(bError)
		
					If !lContinua
						DisarmTransaction()
						Help("   ",1,"PRBLFLTPCOA106",,STR0028,3,0) //"Problemas encontrados na Aplica��o do Filtro! Verifique os Par�metros!"
					EndIf
				EndIf
				
				If lContinua .And. lGrava
				
					//-- Se houver Limite de Rubrica, controla Valor na Conta
					If nLimRubrica > 0 
						nValAcum += (cAliasQry)->AMJ_VALOR1
						If !(lContinua := (nValAcum <= nLimRubrica) )
							DisarmTransaction()
							Help("   ",1,"LIMRBRPCOA106",,STR0029+AllTrim(aCtasInf[nCta])+STR0030,3,0) // "O Limite de Rubrica da Conta " ## " foi ultrapassado!"
						EndIf
					EndIf
               
					If lContinua 

						aParA106 := {}

						For nX := 5 to nQtdEntid 
							aAdd(aParA106, If( "AMJ_ENT" + StrZero(nX,2,0) $ cSelect, (cAliasQry)->&("AMJ_ENT" + StrZero(nX,2,0)), Space(Len( &("AMJ->AMJ_ENT" + StrZero(nX,2,0)) )) ) )	
						Next nX

						lContinua := A106Grv(	cPlanOri,;
														cRevOri,;
														aCtasInf[nCta],;
														If("AMJ_CC" $ cSelect, (cAliasQry)->AMJ_CC, Space(Len(AMJ->AMJ_CC)) ),;
														If("AMJ_ITCTB" $ cSelect, (cAliasQry)->AMJ_ITCTB, Space(Len(AMJ->AMJ_ITCTB)) ),;
														If("AMJ_CLVLR" $ cSelect, 	(cAliasQry)->AMJ_CLVLR, Space(Len(AMJ->AMJ_CLVLR)) ),;
														If("AMJ_CLASSE" $ cSelect, (cAliasQry)->AMJ_CLASSE, Space(Len(AMJ->AMJ_CLASSE)) ),;
														If("AMJ_OPER" $ cSelect, (cAliasQry)->AMJ_OPER, Space(Len(AMJ->AMJ_OPER)) ),;
														dIni,;
														dFim,;
														(cAliasQry)->AMJ_VALOR1,; 
														If("AMJ_UNIORC" $ cSelect, (cAliasQry)->AMJ_UNIORC, Space(Len(AMJ->AMJ_UNIORC)) ),; 
														aParA106)

					EndIf  
				EndIf  
	
				(cAliasQry)->(DbSkip())
			EndDo
		
			//-- A constru��o da query � condicional, portanto eh necessario testar se ela foi construida
			If Select(cAliasQry) > 0
				(cAliasQry)->(DbCloseArea())
			EndIf

			//-- Caso tenha encontrado algum problema, sai do laco de Periodos
			If !lContinua
				DisarmTransaction()
				Break
			EndIf

		EndIf //-- Verifica��o do Per�odo da Planilha x Periodo Integra��o Selecionado

	Next nI

	PcoFinLan("000252")

	End Transaction
	

	//-- Libera conta orcamentaria
	UnLockByName(xFilial("AK3")+cPlanOri+cRevOri+aCtasInf[nCta],.T.,.T.,.T.)
	
	AK3->(MsUnlockAll())  //-- Libera registro travado com softlock para garantir integridade

	//-- Caso tenha encontrado algum problema, sai do laco de Contas Orcament�rias
	If !lContinua
		Exit
	EndIf

Next nCtas

//-- Restaura Areas ap�s final do processo
aEval(aAreas,{|x| RestArea(x) })

Return lContinua

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A106Grv   �Autor  �Daniel Carlos       � Data �  10/29/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para gravacao do valor obtido na area de integracao ���
���          � na planilha orcamentaria.                                  ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A106Grv(cOrcame,cVersao,cCo,cCC,cITCTB,cCLVLR,cClasse,cOper,dDataIni,dDataFim,nValor,cUniOrc,aParA106) 

Local aArea		  := GetArea()
Local cAliasTRB	  := ""
Local cAK2Id   	  := Space(Len(AK2->AK2_ID))
Local lContinua   := .T.
Local lExiste	  := .F.
Local cQuery	  := "" 
Local nI          := 0     
Local nPar		  := 0
Local cChaveAK2	  := ""
Local nChaveAK2	  := 0
Local lPco106Grv  := ExistBlock("PCOA106GRV")

//-- Posiciona em AK3
AK3->(DbSetorder(1))
lContinua := lContinua .And. AK3->(DbSeek(xFilial("AK3")+cOrcame+cVersao+cCo))

//-- Procura AK2 para o Registro posicionado
If lContinua

	If __oSeekAK2  == NIL
		cQuery := " SELECT R_E_C_N_O_ RECNOAK2, AK2_ID, AK2_PERIOD "
		cQuery += "  FROM ? "
		cQuery += " WHERE "  
		cQuery += "    AK2_FILIAL     = ? "  
		cQuery += "    AND AK2_ORCAME = ? "  
		cQuery += "    AND AK2_VERSAO = ? "
		cQuery += "    AND AK2_CO     = ? "
		cQuery += "    AND AK2_CC     = ? "
		cQuery += "    AND AK2_ITCTB  = ? "
		cQuery += "    AND AK2_CLVLR  = ? " 
		cQuery += "    AND AK2_UNIORC = ? "
		For nI := 5 to nQtdEntid 
			cQuery += "    AND AK2_ENT" + StrZero(nI,2,0) + " = ? "
		Next nI  
		cQuery += "    AND AK2_CLASSE = ? "
		cQuery += "    AND AK2_OPER   = ? "	
		cQuery += "    AND D_E_L_E_T_ = ' '"
		cQuery += " ORDER BY AK2_ID"
		
		cQuery := ChangeQuery(cQuery)
		__oSeekAK2 := FWPreparedStatement():New(cQuery)
	EndIf
	__oSeekAK2:SetNumeric(1,RetSqlName("AK2"))
	__oSeekAK2:SetString(2,xFilial('AK2'))
	__oSeekAK2:SetString(3,cOrcame)
	__oSeekAK2:SetString(4,cVersao)
	__oSeekAK2:SetString(5,cCo)
	__oSeekAK2:SetString(6,cCC)
	__oSeekAK2:SetString(7,cITCTB)
	__oSeekAK2:SetString(8,cCLVLR)
	__oSeekAK2:SetString(9,cUniOrc)
	nI := 5
	nPar := 10
	For nI := 5 to nQtdEntid 
		__oSeekAK2:SetString(nPar,aParA106[nI-4])
		nPar++
	Next nI  
	__oSeekAK2:SetString(nPar,cClasse)
	__oSeekAK2:SetString(nPar+1,cOper)

	cAliasTRB := GetNextAlias()
	cAliasTRB := MPSYSOpenQuery(__oSeekAK2:GetFixQuery(),cAliasTRB)

	lExiste := .F.
	While (cAliasTRB)->(!Eof())
		nRecAK2	:= (cAliasTRB)->RECNOAK2
		cAK2Id	:= (cAliasTRB)->AK2_ID
		If (cAliasTRB)->AK2_PERIOD == DTOS(dDataIni)
			lExiste	:= .T.
			Exit
		EndIf

		(cAliasTRB)->(DbSkip())
	EndDo
	(cAliasTRB)->(DbCloseArea())
EndIf

//-- Busca o Pr�ximo ID para registro Novo
If lContinua .And. Empty(cAK2Id)
	If __oNewAK2 == NIL
		cQuery := " SELECT MAX(AK2_ID) AK2_ID "
		cQuery += "  FROM ? "
		cQuery += " WHERE "  
		cQuery += "    AK2_FILIAL     = ? "  
		cQuery += "    AND AK2_ORCAME = ? "  
		cQuery += "    AND AK2_VERSAO = ? "
		cQuery += "    AND AK2_CO     = ? "
		cQuery += "    AND D_E_L_E_T_ = ' '"
		
		cQuery := ChangeQuery(cQuery)
		__oNewAK2 := FWPreparedStatement():New(cQuery)
	EndIf
	__oNewAK2:SetNumeric(1,RetSqlName("AK2"))
	__oNewAK2:SetString(2,xFilial('AK2'))
	__oNewAK2:SetString(3,cOrcame)
	__oNewAK2:SetString(4,cVersao)
	__oNewAK2:SetString(5,cCo)

	cAliasTRB := GetNextAlias()
	cAliasTRB := MPSYSOpenQuery(__oNewAK2:GetFixQuery(),cAliasTRB)

	If (cAliasTRB)->(!Eof())
		cAK2Id := (cAliasTRB)->AK2_ID
	EndIf			
	cAk2Id := StrZero(Val(cAk2Id)+1, Len(AK2->AK2_ID))
	(cAliasTRB)->(DbCloseArea())
EndIf

//-- Bloqueia registro com o ID, se sucesso, efetua grava��o
If (lContinua := lContinua .And. PcoLockAK2( AK3->( xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO )+cAk2Id ) )

	If lExiste
		AK2->(DbGoto(nRecAK2))
		RecLock("AK2",.F.)
	Else
		RecLock("AK2",.T.)
		AK2->AK2_FILIAL := xFilial('AK2')
		AK2->AK2_ORCAME := cOrcame
		AK2->AK2_VERSAO := cVersao
		AK2->AK2_CO     := cCo
		AK2->AK2_ID     := cAK2Id
		AK2->AK2_MOEDA	:= Iif(M->AK2_MOEDA == 0,1,M->AK2_MOEDA)
		AK2->AK2_CC     := cCC
		AK2->AK2_ITCTB  := cITCTB
		AK2->AK2_CLVLR  := cCLVLR
		AK2->AK2_CLASSE := cClasse
		AK2->AK2_OPER   := cOper
		AK2->AK2_PERIOD := dDataIni
		AK2->AK2_DATAI  := dDataIni
		AK2->AK2_DATAF  := dDataFim
		AK2->AK2_UNIORC := cUniOrc

		For nI := 5 to nQtdEntid 
			&("AK2->AK2_ENT" + StrZero(nI,2,0)) := aParA106[nI-4]
		Next nI 

	EndIf
	AK2->AK2_VALOR += nValor

	IF lPco106Grv
		ExecBlock( "PCOA106GRV", .F., .F.,{nValor,nQtdEntid,aParA106})
    EndIf

	MsUnlock()
	AK2->(DbCommit())
	
	If AK2->AK2_VALOR < 0
		DisarmTransaction()
		Help("   ",1,"NOVLRNEGPCOA106",,STR0031,3,0) //"N�o � Permitido Valores negativos na Planilha Or�ament�ria! Verifique a �rea de Integra��o!"
		lContinua := .F.
	EndIf
	
	//-- Posiciona em AK3
	AK3->(DbSetorder(1))
	lContinua := lContinua .And. AK3->(MsSeek(xFilial("AK3")+cOrcame+cVersao+cCo))
   
	//-- Libera registro da Planilha
	PcoUnLockAK2(AK3->(xFilial("AK3")+AK3_ORCAME+AK3_VERSAO+AK3_CO)+AK2->AK2_ID )

	If lContinua	
		If lSimulac
			PcoDetLan("000252","03","PCOA100")
		ElseIf lRevisao
			PcoDetLan("000252","02","PCOA100")
		Else
			PcoDetLan("000252","01","PCOA100")
		EndIf
	EndIf
	
EndIf

RestArea(aArea)

Return lContinua

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A106Join  �Autor  �Daniel Carlos       � Data �  10/28/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao que retorna se a construcao do JOIN com a entidade  ���
���          � de origem sera possivel na query da area de integracao     ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A106Join(aRetBoxAMJ)
Local lCanJoin  := .F.
Local cAliasQry, cQuery

If !Empty(aRetBoxAMJ[1]) .And. !Empty(aRetBoxAMJ[2])

	//-- Somente ser� poss�vel ligar a Integra��o � Origem (JOIN) se todos os registros da Integra��o possuirem Chave (Integra��o sem Acumular)
	cAliasQry := GetNextAlias()
	cQuery := " SELECT COUNT(*) NRECS"
	cQuery += " FROM " + RetSqlName("AMJ") + " AMJ "
	cQuery += " WHERE "
	cQuery += "    AMJ_FILIAL				= '"+xFilial("AMJ")+"' "
	cQuery += "    AND AMJ_PROCES 		= '"+aRetBoxAMJ[1]+"' "	
	cQuery += "    AND AMJ_ITEM   		= '"+aRetBoxAMJ[2]+"' "	
	cQuery += "    AND AMJ_CHAVE  		= ' ' "	
	cQuery += "    AND AMJ.D_E_L_E_T_ 	= ' ' " 
	
	//-- Data maior ou igual � menor data do primeiro per�odo
	cQuery += " AND AMJ_DATPLA >= '" + DtoS(aRetBoxAMJ[3]) + "' "
	//-- Data menor ou igual � maior data do �ltimo per�odo
	cQuery += " AND AMJ_DATPLA <= '" + DtoS(aRetBoxAMJ[4]) + "' "

	DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
	lCanJoin := (cAliasQry)->(Eof()) .Or. (cAliasQry)->NRECS == 0
	(cAliasQry)->(DbCloseArea())

EndIf

Return lCanJoin


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A106Box   �Autor  �Daniel Carlos       � Data �  10/28/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao de controle de contrucao do Parambox no Wizard      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A106Box(oWizard, lParam, aParametros, aRet, lReset)

Default lReset := .F.

If lReset
	oWizard:oMPanel[oWizard:nPanel]:FreeChildren()
EndIf

aEval(aRet, { |x,y| &("MV_PAR"+StrZero(y,2,0)) := x } )
If lParam == NIL .Or. lReset
	ParamBox(aParametros ,STR0032, aRet, , , .F., 120,  3, oWizard:oMPanel[oWizard:nPanel] ) // "Par�metros"
	lParam := .T.
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A106Ori   �Autor  �Daniel Carlos       � Data �  10/28/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para construir o array de perguntas sobre a entida- ���
���          � de de origem, conforme processo/item selecionado           ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A106Ori(aRetBoxAMJ,aBoxOri,aRetBoxOri)

//-- Se Processo e Item foram preenchidos e houve altera��o, refaz os arrays da Origem
If !Empty(aRetBoxAMJ[1]) .And. !Empty(aRetBoxAMJ[2]) .And. cChave != aRetBoxAMJ[1]+aRetBoxAMJ[2]

	aBoxOri 		:= { { 7, STR0033+GetEntFilt(aRetBoxAMJ[1],aRetBoxAMJ[2]),GetEntFilt(aRetBoxAMJ[1],aRetBoxAMJ[2]),""}} //"Filtro Origem - "
	aRetBoxOri 	:= {	" "}
	cChave 		:= aRetBoxAMJ[1]+aRetBoxAMJ[2]

//-- Se Processo e Item n�o foram preenchidos, zera os Arrays, para n�o haver filtro
ElseIf Empty(aRetBoxAMJ[1]) .Or. Empty(aRetBoxAMJ[2])
	aBoxOri 		:= { { 7, STR0034,"AMJ","",".F."}} //"N�o aplic�vel   "
	aRetBoxOri 	:= {	" "}
	cChave 		:= ""
EndIf

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GetEntFilt�Autor  �Daniel Carlos       � Data �  10/28/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para retornar a tabela de origem a partir de um     ���
���          � Processo/Item                                              ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function GetEntFilt(cProcesso,cItem)
Local aArea		:= GetArea()
Local aAreaAKB	:= AKB->(GetArea())
Local cRet		:= ""

DbSelectArea('AKB')
DbSetOrder(1)
If MsSeek(xFilial()+cProcesso+cItem)
	cRet	:=	AKB->AKB_ENTIDA
	
	If cProcesso == "000002" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV")
		cRet	:=	"SE2"                                                                       
	ElseIf cProcesso == "000001" .And. (AKB->AKB_ENTIDA == "SEZ" .OR.AKB->AKB_ENTIDA == "SEV")
		cRet	:=	"SE1"       
	ElseIf cProcesso == "000054" .And. AKB->AKB_ENTIDA == "SDE"
		cRet	:=	"SD1"       
	EndIf	                                                                	
EndIf

RestArea(aAreaAKB)
RestArea(aArea)

Return cRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A106Error �Autor  �Daniel Leme         � Data �  10/28/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para tratamento de erro para prote��o de falhas     ���
���          � dentro de um Begin Sequence                                ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A106Error(lRet)
lRet := .F.
Break
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A106CtaSup�Autor  �Daniel Carlos       � Data �  10/30/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao recursiva para subir os nives de contas orcamentarias���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A106CtaSup(cOrcame, cRevisa, cConta, aCtas)
Local aArea		:= GetArea()
Local aAreaAK3	:= AK3->(GetArea())

DEFAULT aCtas := {}

If !Empty(cConta)
	AK3->(DbSetOrder(1))
	If AK3->(DbSeek(xFilial("AK3")+cOrcame+cRevisa+PadR(cConta, Len(AK3->AK3_CO))))
		aAdd(aCtas, AK3->AK3_CO)
		A106CtaSup(cOrcame, cRevisa, AK3->AK3_PAI, aCtas)	
	EndIf
EndIf

RestArea(aAreaAK3)
RestArea(aArea)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A106CtaInf�Autor  �Daniel Carlos       � Data �  10/30/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao Recursiva para descer os niveis de contas Orcamenta-���
���          � rias da planilha Orcamentaria                              ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A106CtaInf(cOrcame, cRevisa, cConta, aCtas, cCond )
Local aArea		:= GetArea()
Local aAreaAK3	:= AK3->(GetArea())

DEFAULT aCtas := {}

If !Empty(cConta)
	AK3->(DbSetOrder(2)) //-- AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_PAI+AK3_CO
	If AK3->(MsSeek(xFilial("AK3")+cOrcame+cRevisa+PadR(cConta, Len(AK3->AK3_PAI))))
		
		Do While AK3->(!Eof()) .And. xFilial("AK3")+cOrcame+cRevisa+PadR(cConta, Len(AK3->AK3_PAI)) == AK3->(AK3_FILIAL+AK3_ORCAME+AK3_VERSAO+AK3_PAI)
			If Empty(cCond) .Or. AK3->&(cCond)
				aAdd(aCtas, AK3->AK3_CO)
			EndIf
			A106CtaInf(cOrcame, cRevisa, AK3->AK3_CO, aCtas, cCond )	
			AK3->(DbSkip())
		EndDo
	EndIf
EndIf

RestArea(aAreaAK3)
RestArea(aArea)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A106LimRub�Autor  �Daniel Carlos       � Data �  11/23/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao que retorna o Limite de Rubrica de contas Orcamenta-���
���          � rias                                                       ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A106LimRub(  cOrcame, cVersao, cCo )
Local aAreas 		:= {	AMX->(GetArea()),;
								AMV->(GetArea()),;
								GetArea()}
Local cQuery		:= ""
Local cAliasTRB	:= GetNextAlias()
Local nValor		:= 0 

AMX->( DbSetOrder(2) )
If AMX->( DbSeek( xFilial("AMX") + cOrcame ) )
		
	AMV->( DbSetOrder(1) )
	If AMV->( DbSeek( xFilial("AMV") + AMX->AMX_CODIGO + cCo ) )
		cQuery := " SELECT SUM(AMV_LIMITE) AS LIMITE "
		cQuery += " FROM " + RetSqlName("AMV") + " AMV "
		cQuery += " LEFT JOIN " + RetSqlName("AMX") + " AMX ON "
		cQuery += "    AMX.AMX_FILIAL     = '" + xFilial("AMX") + "' "		
		cQuery += "    AND AMX.AMX_CODIGO = AMV.AMV_PROJOR " 
		cQuery += "    AND AMX.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE "
		cQuery += "    AMV.AMV_FILIAL     = '" + xFilial("AMV")	+ "'"
		cQuery += "    AND AMV.AMV_CODCON = '" + cCo					+ "'"
		cQuery += "    AND AMX.AMX_PLNORC = '" + cOrcame			+ "'"
		cQuery += "    AND AMV.D_E_L_E_T_ = ' '"
		
		cQuery := ChangeQuery(cQuery)
		
		DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasTRB, .F., .T. )
		
		If (cAliasTRB)->( !Eof() )
			nValor := (cAliasTRB)->LIMITE
		EndIf
		
		(cAliasTRB)->(DbCloseArea())
	EndIf
EndIf

//-- Restaura Areas ap�s final do processo
aEval(aAreas,{|x| RestArea(x) })

Return nValor

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �A106VrCta �Autor  �Daniel Carlos       � Data �  11/23/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao que retorna o Valor de uma conta orcamentaria da    ���
���          � Planilha                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � PCOA106                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A106VrCta( cOrcame, cVersao, cCo)
Local aAreas 		:= {	GetArea()}
Local cQuery		:= ""
Local cAliasTRB	:= GetNextAlias()
Local nValor		:= 0 

cQuery := " SELECT SUM(AK2_VALOR) AS AK2_VALOR "
cQuery += " FROM " + RetSqlName("AK2") + " AK2 "
cQuery += " WHERE "
cQuery += "    AK2_FILIAL     = '" + xFilial("AK2")+ "'"
cQuery += "    AND AK2_ORCAME = '" + cOrcame			+ "'"
cQuery += "    AND AK2_VERSAO = '" + cVersao			+ "'"
cQuery += "    AND AK2_CO     = '" + cCo				+ "'"
cQuery += "    AND D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)

DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery),cAliasTRB,.F.,.T. )

If (cAliasTRB)->( !Eof() )
	nValor := (cAliasTRB)->AK2_VALOR
EndIf

(cAliasTRB)->(DbCloseArea())

//-- Restaura Areas ap�s final do processo
aEval(aAreas,{|x| RestArea(x) })

Return nValor
