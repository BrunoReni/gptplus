#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXCtCnt
Devolve os saldos e movimentos das entidades contábeis (conta, centro de custo, item contábil e classe de valor)

É devolvido um arquivo temporário com os campos:
	CONTA		Código da conta
	CUSTO		Código do centro de custos
	ITEM		Código do item contábil
	CLVL		Código da classe de valor
	ANTSLD		Saldo anterior
	CRD			Crédito no período
	DEB			Débito no período
	MOV			Movimento no período
	ATUSLD		Saldo no fim do período


@param dDataIni		Data inicial da extração
@param dDataFim		Data final da extração

@return cRetAlias	Nome do arquivo temporário
/*/
//-------------------------------------------------------------------------------------   
Static aTables := {}

Function BIXCtCnt( dDataIni, dDataFim )
	Local cTabCTI		:= ""
	Local cTabCT4		:= ""
	Local cTabCT3		:= ""
	Local cTabCT7		:= ""
	Local cQuery		:= ""
	Local cRetAlias	:= getNextAlias()
                      
	cTabCTI := BIXCTI( dDataIni, dDataFim )
	cTabCT4 := BIXCT4( dDataIni, dDataFim, cTabCTI)
	cTabCT3 := BIXCT3( dDataIni, dDataFim, cTabCTI, cTabCT4)
	cTabCT7 := BIXCT7( dDataIni, dDataFim, cTabCTI, cTabCT4, cTabCT3)   
	 
	BIXPutGC( cTabCTI )
	BIXPutGC( cTabCT4 )	
	BIXPutGC( cTabCT3 )	
	BIXPutGC( cTabCT7 )

	cQuery := " SELECT CTI.CONTA, CTI.CUSTO, CTI.ITEM, CTI.CLVL, CTI.ANTSLD, CTI.CRD, CTI.DEB, CTI.MOV, CTI.ATUSLD FROM " + cTabCTI + " CTI "
	cQuery += " UNION "
	cQuery += " SELECT CT4.CONTA, CT4.CUSTO, CT4.ITEM, CT4.CLVL, CT4.ANTSLD, CT4.CRD, CT4.DEB, CT4.MOV, CT4.ATUSLD FROM " + cTabCT4 + " CT4 "
	cQuery += " UNION "
	cQuery += " SELECT CT3.CONTA, CT3.CUSTO, CT3.ITEM, CT3.CLVL, CT3.ANTSLD, CT3.CRD, CT3.DEB, CT3.MOV, CT3.ATUSLD FROM " + cTabCT3 + " CT3 "
	cQuery += " UNION "
	cQuery += " SELECT CT7.CONTA, CT7.CUSTO, CT7.ITEM, CT7.CLVL, CT7.ANTSLD, CT7.CRD, CT7.DEB, CT7.MOV, CT7.ATUSLD FROM " + cTabCT7 + " CT7 "

	cQuery := ChangeQuery(cQuery)

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cRetAlias, .T., .F.)
	DBSelectArea(cRetAlias)
Return cRetAlias


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXCtCntO
Devolve os movimentos real, orçado e empenhado das entidades contábeis (conta, centro de custo, item contábil e classe de valor)
	
É devolvido um arquivo temporário com os campos:
	CONTA		Código da conta
	CUSTO		Código do centro de custos
	ITEM		Código do item contábil
	CLVL		Código da classe de valor
	MOVORC		Movimento orçado no período
	MOVEMP		Movimento empenhado no período
	MOVREAL		Movimento real no período
	MOVPREV	Movimento previsto no período

@protected
@param dDataIni		Data inicial da extração
@param dDataFim		Data final da extração

@return cRetAlias	Nome do arquivo temporário
/*/
//-------------------------------------------------------------------------------------
Function BIXCtCntO( dDataIni, dDataFim )
	Local cTabCTI		:= ""
	Local cTabCT4		:= ""
	Local cTabCT3		:= ""
	Local cTabCT7		:= ""
	Local cQuery		:= ""
	Local cRetAlias	:= getNextAlias()

	cTabCTI := BIXCTIO( dDataIni, dDataFim )
	cTabCT4 := BIXCT4O( dDataIni, dDataFim, cTabCTI )
	cTabCT3 := BIXCT3O( dDataIni, dDataFim, cTabCTI, cTabCT4 )
	cTabCT7 := BIXCT7O( dDataIni, dDataFim, cTabCTI, cTabCT4, cTabCT3 )
     
 	BIXPutGC( cTabCTI )
	BIXPutGC( cTabCT4 )	
	BIXPutGC( cTabCT3 )	
	BIXPutGC( cTabCT7 ) 

	cQuery := " SELECT	CONTA,"
	cQuery += "			CUSTO,"
	cQuery += "			ITEM,"
	cQuery += "			CLVL,"
	cQuery += "			SUM(CASE WHEN TPSALD = '0' THEN MOV ELSE 0 END) as MOVORC,"
	cQuery += "			SUM(CASE WHEN TPSALD = '4' THEN MOV ELSE 0 END) as MOVEMP,"
	cQuery += "			SUM(CASE WHEN TPSALD = '1' THEN MOV ELSE 0 END) as MOVREAL,"
	cQuery += "			SUM(CASE WHEN TPSALD = '2' THEN MOV ELSE 0 END) as MOVPREV"
	cQuery += "	FROM ("
	cQuery += " 	SELECT CTI.CONTA, CTI.CUSTO, CTI.ITEM, CTI.CLVL, CTI.TPSALD, CTI.MOV FROM " + cTabCTI + " CTI "
	cQuery += " 	UNION "
	cQuery += " 	SELECT CT4.CONTA, CT4.CUSTO, CT4.ITEM, CT4.CLVL, CT4.TPSALD, CT4.MOV FROM " + cTabCT4 + " CT4 "
	cQuery += " 	UNION "
	cQuery += " 	SELECT CT3.CONTA, CT3.CUSTO, CT3.ITEM, CT3.CLVL, CT3.TPSALD, CT3.MOV FROM " + cTabCT3 + " CT3 "
	cQuery += " 	UNION "
	cQuery += " 	SELECT CT7.CONTA, CT7.CUSTO, CT7.ITEM, CT7.CLVL, CT7.TPSALD, CT7.MOV FROM " + cTabCT7 + " CT7 "
	cQuery += "	) tAux"
	cQuery += "	GROUP BY	CONTA,"
	cQuery += "				CUSTO,"
	cQuery += "				ITEM,"
	cQuery += "				CLVL"

	cQuery := ChangeQuery(cQuery)
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cRetAlias, .T., .F.)
	DBSelectArea(cRetAlias)
Return cRetAlias


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXCtGerInd
Devolve os saldos e movimentos das contas gerenciais no mês de referência informado

É devolvido um arquivo temporário com os campos:
	CONTA		Código da conta
	MOVIMENTO	Movimento do período (CRÉDITOS - DÉBITOS)
	SALDOATU	Saldo no fim do período
	TIPOCONTA	'1' = Sintética, '2' = Analítica

@param cBook		Código do livro contábil
@param dDataIni	Data de início da consulta
@param dDataFim	Data de final da consulta

@return cArqTmp	Nome do arquivo temporário
/*/
//-------------------------------------------------------------------------------------
Function BIXCtGerInd( cBook, dDataIni, dDataFim )
	CTGerPlan(	  /*01*/,;
				  /*02*/,;
			      /*03*/,;
		          /*04*/.F.,;
		          /*05*/,;
		          /*06*/dDataIni,;
		          /*07*/dDataFim,;
		          /*08*/"CT7",;
		          /*09*/"",;
		          /*10*/"",;
		          /*11*/Repl("Z",Len(CT1->CT1_CONTA)),;
		          /*12*/"",;
		          /*13*/Repl("Z", Len(CTT->CTT_CUSTO)),;
		          /*14*/"",;
		          /*15*/Repl("Z", Len(CTD->CTD_ITEM)),;
		          /*16*/"",;
		          /*17*/Repl("Z", Len(CTH->CTH_CLVL)),;
		          /*18*/'01',;
		          /*19*/'1',;
		          /*20*/CTBSetOf(cBook),;
		          /*21*/,;
		          /*22*/"",;
		          /*23*/Repl("Z",20),;
		          /*24*/,;
		          /*25*/.T.,;
		          /*26*/,;
		          /*27*/,;
		          /*28*/'',;
		          /*29*/.F.,;
		          /*30*/,;
		          /*31*/1,;
		          /*32*/.T.,;
		          /*33*/,;
		          /*34*/,;
		          /*35*/,;
		          /*36*/,;
		          /*37*/,;
		          /*38*/,;
		          /*39*/,;
		          /*40*/,;
		          /*41*/,;
		          /*42*/,;
		          /*43*/,;
		          /*44*/,;
		          /*45*/,;
		          /*46*/.T.,;
		          /*47*/,;
		          /*48*/,;
		          /*49*/,;
		          /*50*/,;
		          /*51*/,;
		          /*52*/,;
		          /*53*/,;
		          /*54*/,;
		          /*55*/,;
		          /*56*/,;
		          /*57*/'01',;
		          /*58*/.F.,;
		          /*59*/,;
		          /*60*/,;
		          /*61*/.T.,;
		          /*62*/.T.,;
		          /*63*/,;
				  /*64*/,;
				  /*65*/,;
				  /*66*/,;
				  /*67*/.F.,;
				  /*68*/,;
				  /*69*/,;
			  	  /*70*/ )

	DBSelectArea("cArqTmp")
Return "cArqTmp"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXCTI
Devolve os saldos e movimentos das classes de valor

É devolvido um arquivo temporário com os campos:
	CONTA		Código da conta
	CUSTO		Código do centro de custo
	ITEM		Código do item contábil
	CLVL		Código da classe de valor
	ANTSLD		Saldo anterior
	CRD			Crédito no período
	DEB			Débito no período
	MOV			Movimento no período
	ATUSLD		Saldo no fim do período

@param dDataIni		Data inicial da extração
@param dDataFim		Data final da extração

@return cTabCTI	Nome do arquivo temporário
/*/
//-------------------------------------------------------------------------------------
Static Function BIXCTI( dDataIni, dDataFim )
	Local cQuery		:= ""
	Local cTabCTI		:= BIXTblTmpAlias( )
	Local cFilCTI		:= xFilial("CTI")
	Local lSQL			:= "SQL" $ TcGetDB()

	cQuery += " SELECT " 
	cQuery += " 	CONTA ,  " 
	cQuery += " 	CUSTO , " 
	cQuery += " 	ITEM , " 
	cQuery += " 	CLVL , " 
	cQuery += " 	ANTCRED - ANTDEB	ANTSLD, " 
	cQuery += " 	ATUCRED - ANTCRED	CRD, " 
	cQuery += " 	ATUDEB - ANTDEB DEB, " 
	cQuery += " 	(ATUCRED - ATUDEB) - (ANTCRED - ANTDEB ) as MOV, " 
	cQuery += " 	ATUCRED - ATUDEB as ATUSLD " 
	If lSQL
		cQuery += " INTO " + cTabCTI 
	EndIf
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " 	SELECT  " 
	cQuery += " 		CONTA,  " 
	cQuery += " 		CUSTO, " 
	cQuery += " 		ITEM, " 
	cQuery += " 		CLVL, " 
	cQuery += " 		SUM(ANTDEB) ANTDEB  , " 
	cQuery += " 		SUM(ANTCRED) ANTCRED , " 
	cQuery += " 		SUM(ATUDEB) ATUDEB	, " 
	cQuery += " 		SUM(ATUCRED) ATUCRED  " 
	cQuery += " 	FROM " 
	cQuery += " 	( " 
	cQuery += " 		SELECT  " 
	cQuery += " 			CQ6_CONTA CONTA	,  " 
	cQuery += " 			CQ6_CCUSTO CUSTO	, " 
	cQuery += " 			CQ6_ITEM ITEM	, " 
	cQuery += " 			CQ6_CLVL CLVL	, " 
	cQuery += " 			SUM(CQ6_DEBITO) ANTDEB  , " 
	cQuery += " 			SUM(CQ6_CREDIT) ANTCRED , " 
	cQuery += " 			0 ATUDEB	, " 
	cQuery += " 			0 ATUCRED  " 
	cQuery += " 		FROM  " 
	cQuery += " 			" + retSqlName("CQ6") + " CQ6 " 
	cQuery += " 		WHERE " 
	cQuery += " 			CQ6.CQ6_TPSALD	=	'1'	 and " 
	cQuery += " 			CQ6.CQ6_MOEDA	=	'01'    and " 
	cQuery += " 			CQ6.CQ6_FILIAL	=	'" + xFilial("CQ6") + "' and " 
	cQuery += " 			CQ6.D_E_L_E_T_	=	' '	 and " 
	cQuery += " 			CQ6.CQ6_DATA	<	'" + dTos(dDataIni) + "' " 
	cQuery += " 		GROUP BY " 
	cQuery += " 			CQ6_CONTA	,  " 
	cQuery += " 			CQ6_CCUSTO	, " 
	cQuery += " 			CQ6_ITEM	, " 
	cQuery += " 			CQ6_CLVL  " 
	cQuery += " 		UNION ALL " 
	cQuery += " 		SELECT  " 
	cQuery += " 			CQ6_CONTA	 CONTA	,  " 
	cQuery += " 			CQ6_CCUSTO	 CUSTO	, " 
	cQuery += " 			CQ6_ITEM	 ITEM	, " 
	cQuery += " 			CQ6_CLVL	 CLVL	, " 
	cQuery += " 			0			 ANTDEB  , " 
	cQuery += " 			0			 ANTCRED , " 
	cQuery += " 			SUM(CQ6_DEBITO) ATUDEB	, " 
	cQuery += " 			SUM(CQ6_CREDIT) ATUCRED  " 
	cQuery += " 		FROM  " 
	cQuery += " 			" + retSqlName("CQ6") + " CQ6 " 
	cQuery += " 		WHERE	 "  
	cQuery += " 			CQ6.CQ6_TPSALD	=	'1' and " 
	cQuery += " 			CQ6.CQ6_MOEDA	=	'01'	 and " 
	cQuery += " 			CQ6.CQ6_FILIAL	=	'" + xFilial("CQ6") + "' and " 
	cQuery += " 			CQ6.D_E_L_E_T_	=	' '	 and " 
	cQuery += " 			CQ6.CQ6_DATA	<=	'" + dTos(dDataFim) + "' " 
	cQuery += " 		GROUP BY " 
	cQuery += " 			CQ6_CONTA	,  " 
	cQuery += " 			CQ6_CCUSTO	, " 
	cQuery += " 			CQ6_ITEM	, " 
	cQuery += " 			CQ6_CLVL	 " 
	cQuery += " 	) T1 " 
	cQuery += " 	GROUP BY " 
	cQuery += " 		CONTA	,  " 
	cQuery += " 		CUSTO	, " 
	cQuery += " 		ITEM	, " 
	cQuery += " 		CLVL " 
	cQuery += " ) TFIM	 " 
	
	If !(lSQL)
		cQuery := BIXCtbTable( cQuery, @cTabCTI , 1 )
	Else
		cQuery := ChangeQuery(cQuery)
		
		If ( TCSQLExec ( cQuery ) < 0 )
			Conout( TCSQLError() )
			MemoWrite( "BIXCTI.log", cQuery ) 	 
		EndIf
	EndIf
Return cTabCTI


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXCT4
Devolve os saldos e movimentos dos itens contábeis

É devolvido um arquivo temporário com os campos:
	CONTA		Código da conta
	CUSTO		Código do centro de custo
	ITEM		Código do item contábil
	CLVL		Em branco
	ANTSLD		Saldo anterior
	CRD			Crédito no período
	DEB			Débito no período
	MOV			Movimento no período
	ATUSLD		Saldo no fim do período

@param dDataIni		Data inicial da extração
@param dDataFim		Data final da extração
@param cTabCTI			Arquivo temporário (gerado com BIXCTI) com os saldos das entidades contábeis até o nível de classe de valor

@return cTabCT4	Nome do arquivo temporário
/*/
//-------------------------------------------------------------------------------------
Static Function BIXCT4( dDataIni, dDataFim, cTabCTI)
	Local cQuery		:= ""
	Local cTabCT4		:= BIXTblTmpAlias( )
	Local cFilCT4		:= xFilial("CT4")
	Local lSQL			:= "SQL" $ TcGetDB()

	cQuery += " SELECT "
	cQuery += " 	TFIM.CONTA	 CONTA,  "
	cQuery += " 	TFIM.CUSTO CUSTO	, "
	cQuery += " 	TFIM.ITEM	ITEM, "
	cQuery += " 	TFIM.CLVL	CLVL , "
	cQuery += " 	TFIM.ANTCRED - TFIM.ANTDEB	- coalesce(tCTI.ANTSLD,0) ANTSLD, "
	cQuery += " 	TFIM.ATUCRED - TFIM.ANTCRED	- coalesce(tCTI.CRD,0)  CRD, "
	cQuery += " 	TFIM.ATUDEB - TFIM.ANTDEB	- coalesce(tCTI.DEB,0)	DEB, "
	cQuery += " 	(TFIM.ATUCRED - TFIM.ATUDEB) - (TFIM.ANTCRED - TFIM.ANTDEB ) - coalesce(tCTI.MOV,0) as MOV, "
	cQuery += " 	TFIM.ATUCRED - TFIM.ATUDEB - coalesce(tCTI.ATUSLD,0) as ATUSLD "
	
	If lSQL
		cQuery += " INTO " + cTabCT4
	EndIf
	
	cQuery += " FROM "
	cQuery += " ( "
	cQuery += " 	SELECT  "
	cQuery += " 		CONTA ,  "
	cQuery += " 		CUSTO , "
	cQuery += " 		ITEM , "
	cQuery += " 		CLVL , "
	cQuery += " 		SUM(ANTDEB) ANTDEB  , "
	cQuery += " 		SUM(ANTCRED) ANTCRED , "
	cQuery += " 		SUM(ATUDEB) ATUDEB	, "
	cQuery += " 		SUM(ATUCRED) ATUCRED  "
	cQuery += " 	FROM "
	cQuery += " 	( "
	cQuery += " 		SELECT  "
	cQuery += " 			CQ4_CONTA CONTA	,  "
	cQuery += " 			CQ4_CCUSTO CUSTO	, "
	cQuery += " 			CQ4_ITEM ITEM	, "
	cQuery += " 			'" + space( TamSX3("CTH_CLVL")[1] ) + "' CLVL	, "
	cQuery += " 			SUM(CQ4_DEBITO) ANTDEB  , "
	cQuery += " 			SUM(CQ4_CREDIT) ANTCRED , "
	cQuery += " 			0 ATUDEB , "
	cQuery += " 			0 ATUCRED  "
	cQuery += " 		FROM  "
	cQuery += " 			" + retSqlName("CQ4") + " CQ4 "
	cQuery += " 		WHERE	 "
	cQuery += " 			CQ4.CQ4_TPSALD = '1'  and "
	cQuery += " 			CQ4.CQ4_MOEDA  = '01' and "
	cQuery += " 			CQ4.CQ4_FILIAL = '" + xFilial("CQ4") + "' and "
	cQuery += " 			CQ4.D_E_L_E_T_ = ' ' and "
	cQuery += " 			CQ4.CQ4_DATA   < '" + dTos(dDataIni) + "' "
	cQuery += " 		GROUP BY "
	cQuery += " 			CQ4_CONTA	,  "
	cQuery += " 			CQ4_CCUSTO	, "
	cQuery += " 			CQ4_ITEM			 "		
	cQuery += " 		UNION ALL "
	cQuery += " 		SELECT  "
	cQuery += " 			CQ4_CONTA CONTA	,  "
	cQuery += " 			CQ4_CCUSTO CUSTO	, "
	cQuery += " 			CQ4_ITEM ITEM	, "
	cQuery += " 			'" + space( TamSX3("CTH_CLVL")[1] ) + "' CLVL	, "
	cQuery += " 			0 ANTDEB  , "
	cQuery += " 			0 ANTCRED , "
	cQuery += " 			SUM(CQ4_DEBITO) ATUDEB	, "
	cQuery += " 			SUM(CQ4_CREDIT) ATUCRED  "
	cQuery += " 		FROM  "
	cQuery += " 			" + retSqlName("CQ4") + " CQ4 "
	cQuery += " 		WHERE	 "
	cQuery += " 			CQ4.CQ4_TPSALD =	'1' and "
	cQuery += " 			CQ4.CQ4_MOEDA =	'01'	and "
	cQuery += " 			CQ4.CQ4_FILIAL = '" + xFilial("CQ4") + "'	and "
	cQuery += " 			CQ4.D_E_L_E_T_ = ' '	and "
	cQuery += " 			CQ4.CQ4_DATA <=	'" + dTos(dDatafim) + "' "
	cQuery += " 		GROUP BY "
	cQuery += " 			CQ4_CONTA	,  "
	cQuery += " 			CQ4_CCUSTO	, "
	cQuery += " 			CQ4_ITEM	 "
	cQuery += " 	) T1 "
	cQuery += " 	GROUP BY "
	cQuery += " 		CONTA	,  "
	cQuery += " 		CUSTO	, "
	cQuery += " 		ITEM	, "
	cQuery += " 		CLVL "
	cQuery += " ) TFIM	 "
	cQuery += " LEFT JOIN ( "
	cQuery += " 	SELECT "
	cQuery += " 		CONTA	,  "
	cQuery += " 		CUSTO	, "
	cQuery += " 		ITEM	, "
	cQuery += " 		SUM(ANTSLD) ANTSLD , "
	cQuery += " 		SUM(CRD) CRD     , "
	cQuery += " 		SUM(DEB) DEB     , "
	cQuery += " 		SUM(MOV) MOV     ,  "
	cQuery += " 		SUM(ATUSLD) ATUSLD   "
	cQuery += " 	FROM "
	cQuery += " 	"+cTabCTI+" TMPAUXCTI "
	cQuery += " 	GROUP BY "
	cQuery += " 		CONTA	,  "
	cQuery += " 		CUSTO	, "
	cQuery += " 		ITEM	 "
	cQuery += " 	) tCTI "
	cQuery += " ON "
	cQuery += " 	TFIM.CONTA	= tCTI.CONTA AND  "
	cQuery += " 	TFIM.CUSTO	= tCTI.CUSTO AND "
	cQuery += " 	TFIM.ITEM	= tCTI.ITEM	 "
	
	
	If !( lSQL )
		cQuery := BIXCtbTable( cQuery, @cTabCT4 ,1 )
	Else
		cQuery := ChangeQuery(cQuery)
		If ( TCSQLExec ( cQuery ) < 0 )
			Conout( TCSQLError() )
			MemoWrite( "BIXCT4.log", cQuery ) 	
		EndIf
	EndIf
Return cTabCT4


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXCT3
Devolve os saldos e movimentos dos centros de custos

É devolvido um arquivo temporário com os campos:
	CONTA		Código da conta
	CUSTO		Código do centro de custo
	ITEM		Em branco
	CLVL		Em branco
	ANTSLD		Saldo anterior
	CRD			Crédito no período
	DEB			Débito no período
	MOV			Movimento no período
	ATUSLD		Saldo no fim do período

@param dDataIni		Data inicial da extração
@param dDataFim		Data final da extração
@param cTabCTI			Arquivo temporário (gerado com BIXCTI) com os saldos das entidades contábeis até o nível de classe de valor
@param cTabCT4			Arquivo temporário (gerado com BIXCT4) com os saldos das entidades contábeis até o nível de item cotábil

@return cTabCT3	Nome do arquivo temporário
/*/
//-------------------------------------------------------------------------------------
Static Function BIXCT3( dDataIni, dDataFim, cTabCTI, cTabCT4 )
	Local cQuery		:= ""
	Local cTabCT3		:= BIXTblTmpAlias( )
	Local cFilCT3		:= xFilial("CT3")
	Local lSQL			:= "SQL" $ TcGetDB()

	cQuery += " SELECT " 
	cQuery += " 	TFIM.CONTA	 CONTA,  " 
	cQuery += " 	TFIM.CUSTO	 CUSTO, " 
	cQuery += " 	TFIM.ITEM	ITEM, " 
	cQuery += " 	TFIM.CLVL	CLVL, " 
	cQuery += " 	TFIM.ANTCRED - TFIM.ANTDEB	- coalesce(tCTI.ANTSLD,0) - coalesce(tCT4.ANTSLD,0) ANTSLD, " 
	cQuery += " 	TFIM.ATUCRED - TFIM.ANTCRED	- coalesce(tCTI.CRD,0)  - coalesce(tCT4.CRD,0) CRD, " 
	cQuery += " 	TFIM.ATUDEB - TFIM.ANTDEB	- coalesce(tCTI.DEB,0)	- coalesce(tCT4.DEB,0) DEB, " 
	cQuery += " 	(TFIM.ATUCRED - TFIM.ATUDEB) - (TFIM.ANTCRED - TFIM.ANTDEB ) - coalesce(tCTI.MOV,0)  - coalesce(tCT4.MOV,0) MOV, " 
	cQuery += " 	(TFIM.ATUCRED - TFIM.ATUDEB) - coalesce(tCTI.ATUSLD,0) - coalesce(tCT4.ATUSLD,0) ATUSLD " 
	
	If  lSQL
		cQuery += " INTO " + cTabCT3
	EndIf
	
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " 	SELECT  " 
	cQuery += " 		CONTA ,  " 
	cQuery += " 		CUSTO , " 
	cQuery += " 		ITEM , " 
	cQuery += " 		CLVL , " 
	cQuery += " 		SUM(ANTDEB) ANTDEB  , " 
	cQuery += " 		SUM(ANTCRED) ANTCRED , " 
	cQuery += " 		SUM(ATUDEB) ATUDEB	, " 
	cQuery += " 		SUM(ATUCRED) ATUCRED  " 
	cQuery += " 	FROM " 
	cQuery += " 	( " 
	cQuery += " 		SELECT  " 
	cQuery += " 			CQ2_CONTA CONTA	,  " 
	cQuery += " 			CQ2_CCUSTO CUSTO	, " 
	cQuery += " 		'" + space( TamSX3("CTD_ITEM")[1] ) + "' ITEM,"
	cQuery += " 		'" + space( TamSX3("CTH_CLVL")[1] ) + "' CLVL,"
	cQuery += " 			SUM(CQ2_DEBITO) ANTDEB  , " 
	cQuery += " 			SUM(CQ2_CREDIT) ANTCRED , " 
	cQuery += " 			0 ATUDEB , " 
	cQuery += " 			0 ATUCRED  " 
	cQuery += " 		FROM  " 
	cQuery += " 			" + retSqlName("CQ2") + " CQ2 " 
	cQuery += " 		WHERE	 " 
	cQuery += " 			CQ2.CQ2_TPSALD = '1'  and " 
	cQuery += " 			CQ2.CQ2_MOEDA  = '01' and " 
	cQuery += " 			CQ2.CQ2_FILIAL = '"+xFilial("CQ2")+"' and " 
	cQuery += " 			CQ2.D_E_L_E_T_ = ' ' and " 
	cQuery += " 			CQ2.CQ2_DATA   < '"+DTOS(dDataIni)+"' " 
	cQuery += " 		GROUP BY " 
	cQuery += " 			CQ2_CONTA	,  " 
	cQuery += " 			CQ2_CCUSTO		 " 
	cQuery += " 		UNION ALL " 
	cQuery += " 		SELECT  " 
	cQuery += " 			CQ2_CONTA CONTA	,  " 
	cQuery += " 			CQ2_CCUSTO CUSTO	, " 
	cQuery += " 		'" + space( TamSX3("CTD_ITEM")[1] ) + "' ITEM,"
	cQuery += " 		'" + space( TamSX3("CTH_CLVL")[1] ) + "' CLVL,"
	cQuery += " 			0 ANTDEB  , " 
	cQuery += " 			0 ANTCRED , " 
	cQuery += " 			SUM(CQ2_DEBITO) ATUDEB	, " 
	cQuery += " 			SUM(CQ2_CREDIT) ATUCRED  " 
	cQuery += " 		FROM  " 
	cQuery += " 			" + retSqlName("CQ2") + " CQ2 " 
	cQuery += " 		WHERE	 " 
	cQuery += " 			CQ2.CQ2_TPSALD =	'1' and " 
	cQuery += " 			CQ2.CQ2_MOEDA =	'01'	and " 
	cQuery += " 			CQ2.CQ2_FILIAL = '"+xFilial("CQ2")+"'	and " 
	cQuery += " 			CQ2.D_E_L_E_T_ = ' '	and " 
	cQuery += " 			CQ2.CQ2_DATA <=	'"+DTOS(dDatafim)+"' " 
	cQuery += " 		GROUP BY " 
	cQuery += " 			CQ2_CONTA	,  " 
	cQuery += " 			CQ2_CCUSTO	 " 
	cQuery += " 	) T1 " 
	cQuery += " 	GROUP BY " 
	cQuery += " 		CONTA	,  " 
	cQuery += " 		CUSTO	, " 
	cQuery += " 		ITEM	, " 
	cQuery += " 		CLVL " 
	cQuery += " ) TFIM	 " 
	cQuery += " LEFT JOIN ( " 
	cQuery += " 	SELECT " 
	cQuery += " 		CONTA	,  " 
	cQuery += " 		CUSTO	, " 
	cQuery += " 		SUM(ANTSLD) ANTSLD , " 
	cQuery += " 		SUM(CRD) CRD     , " 
	cQuery += " 		SUM(DEB) DEB     , " 
	cQuery += " 		SUM(MOV) MOV     ,  " 
	cQuery += " 		SUM(ATUSLD) ATUSLD   " 
	cQuery += " 	FROM " 
	cQuery += " 		" + cTabCTI + " TMPAUXCTI " 
	cQuery += " 	GROUP BY " 
	cQuery += " 		CONTA	,  " 
	cQuery += " 		CUSTO	 " 
	cQuery += " 	) tCTI " 
	cQuery += " ON " 
	cQuery += " 	TFIM.CONTA	= tCTI.CONTA AND  " 
	cQuery += " 	TFIM.CUSTO	= tCTI.CUSTO  " 
	cQuery += " LEFT JOIN ( " 
	cQuery += " 	SELECT " 
	cQuery += " 		CONTA	,  " 
	cQuery += " 		CUSTO	, " 
	cQuery += " 		SUM(ANTSLD) ANTSLD , " 
	cQuery += " 		SUM(CRD) CRD     , " 
	cQuery += " 		SUM(DEB) DEB     , " 
	cQuery += " 		SUM(MOV) MOV     ,  " 
	cQuery += " 		SUM(ATUSLD) ATUSLD   " 
	cQuery += " 	FROM " 
	cQuery += " 		" + cTabCT4 + " TMPAUXCT4 " 
	cQuery += " 	GROUP BY " 
	cQuery += " 		CONTA	,  " 
	cQuery += " 		CUSTO	 " 
	cQuery += " 	) tCT4 " 
	cQuery += " ON " 
	cQuery += " 	TFIM.CONTA	= tCT4.CONTA AND  " 
	cQuery += " 	TFIM.CUSTO	= tCT4.CUSTO  " 
	
	
	If !( lSQL )
		cQuery := BIXCtbTable( cQuery, @cTabCT3, 1 )
	Else
		cQuery := ChangeQuery(cQuery)
		If ( TCSQLExec ( cQuery ) < 0 )
			Conout( TCSQLError() )
			MemoWrite( "BIXCT3.log", cQuery ) 	
		EndIf
	EndIf
Return cTabCT3


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXCT7
Devolve os saldos e movimentos das contas contábeis

É devolvido um arquivo temporário com os campos:
	CONTA		Código da conta
	CUSTO		Em branco
	ITEM		Em branco
	CLVL		Em branco
	ANTSLD		Saldo anterior
	CRD			Crédito no período
	DEB			Débito no período
	MOV			Movimento no período
	ATUSLD		Saldo no fim do período

@param dDataIni		Data inicial da extração
@param dDataFim		Data final da extração
@param cTabCTI			Arquivo temporário (gerado com BIXCTI) com os saldos das entidades contábeis até o nível de classe de valor
@param cTabCT4			Arquivo temporário (gerado com BIXCT4) com os saldos das entidades contábeis até o nível de item cotábil
@param cTabCT3			Arquivo temporário (gerado com BIXCT3) com os saldos das entidades contábeis até o nível de centro de custo

@return cTabCT7	Nome do arquivo temporário
/*/
//-------------------------------------------------------------------------------------
Static Function BIXCT7( dDataIni, dDataFim, cTabCTI, cTabCT4, cTabCT3 )
	Local cQuery		:= ""
	Local cTabCT7		:= BIXTblTmpAlias( )
	Local cAliasCT7	:= retSqlName("CT7")
	Local cFilCT7		:= xFilial("CT7")
	Local lSQL			:= "SQL" $ TcGetDB()

	cQuery += " SELECT "
	cQuery += " 	TFIM.CONTA	 CONTA,  "
	cQuery += " 	TFIM.CUSTO	 CUSTO, "
	cQuery += " 	TFIM.ITEM	ITEM, "
	cQuery += " 	TFIM.CLVL	CLVL, "
	cQuery += " 	TFIM.ANTCRED - TFIM.ANTDEB	- coalesce(tCTI.ANTSLD,0) - coalesce(tCT4.ANTSLD,0)- coalesce(tCT3.ANTSLD,0) ANTSLD, "
	cQuery += " 	TFIM.ATUCRED - TFIM.ANTCRED	- coalesce(tCTI.CRD,0)  - coalesce(tCT4.CRD,0) - coalesce(tCT3.CRD,0) CRD, "
	cQuery += " 	TFIM.ATUDEB - TFIM.ANTDEB	- coalesce(tCTI.DEB,0)	- coalesce(tCT4.DEB,0) - coalesce(tCT3.DEB,0) DEB, "
	cQuery += " 	(TFIM.ATUCRED - TFIM.ATUDEB) - (TFIM.ANTCRED - TFIM.ANTDEB ) - coalesce(tCTI.MOV,0)  - coalesce(tCT4.MOV,0) - coalesce(tCT3.MOV,0) MOV, "
	cQuery += " 	(TFIM.ATUCRED - TFIM.ATUDEB) - coalesce(tCTI.ATUSLD,0) - coalesce(tCT4.ATUSLD,0)- coalesce(tCT3.ATUSLD,0) ATUSLD "
	
	If ( lSQL )
		cQuery += " INTO " + cTabCT7
	EndIf
	
	cQuery += " FROM "
	cQuery += " ( "
	cQuery += " 	SELECT  "
	cQuery += " 		CONTA ,  "
	cQuery += " 		CUSTO , "
	cQuery += " 		ITEM , "
	cQuery += " 		CLVL , "
	cQuery += " 		SUM(ANTDEB) ANTDEB  , "
	cQuery += " 		SUM(ANTCRED) ANTCRED , "
	cQuery += " 		SUM(ATUDEB) ATUDEB	, "
	cQuery += " 		SUM(ATUCRED) ATUCRED  "
	cQuery += " 	FROM "
	cQuery += " 	( "
	cQuery += " 		SELECT "
	cQuery += " 			CQ0_CONTA CONTA	, "
	cQuery += " 			'" + space( TamSX3("CTT_CUSTO")[1] ) + "' CUSTO	, "
	cQuery += " 			'" + space( TamSX3("CTD_ITEM")[1] ) + "' ITEM	, "
	cQuery += " 			'" + space( TamSX3("CTH_CLVL")[1] ) + "' CLVL	, "
	cQuery += " 			SUM(CQ0_DEBITO) ANTDEB  , "
	cQuery += " 			SUM(CQ0_CREDIT) ANTCRED , "
	cQuery += " 			0 ATUDEB , "
	cQuery += " 			0 ATUCRED  "
	cQuery += " 		FROM  "
	cQuery += " 			" + retSqlName("CQ0") + " CQ0 "
	cQuery += " 		WHERE	 "
	cQuery += " 			CQ0.CQ0_TPSALD = '1'  and "
	cQuery += " 			CQ0.CQ0_MOEDA  = '01' and "
	cQuery += " 			CQ0.CQ0_FILIAL = '" + xFilial("CQ0") + "' and "
	cQuery += " 			CQ0.D_E_L_E_T_ = ' ' and "
	cQuery += " 			CQ0.CQ0_DATA   < '" + dTos(dDataIni) + "' "
	cQuery += " 		GROUP BY "
	cQuery += " 			CQ0_CONTA		 "
	cQuery += " 		UNION ALL "
	cQuery += " 		SELECT  "
	cQuery += " 			CQ0_CONTA CONTA	,  "
	cQuery += " 			'" + space( TamSX3("CTT_CUSTO")[1] ) + "' CUSTO	, "
	cQuery += " 			'" + space( TamSX3("CTD_ITEM")[1] ) + "' ITEM	, "
	cQuery += " 			'" + space( TamSX3("CTH_CLVL")[1] ) + "' CLVL	, "
	cQuery += " 			0 ANTDEB  , "
	cQuery += " 			0 ANTCRED , "
	cQuery += " 			SUM(CQ0_DEBITO) ATUDEB	, "
	cQuery += " 			SUM(CQ0_CREDIT) ATUCRED  "
	cQuery += " 		FROM  "
	cQuery += " 			" + retSqlName("CQ0") + " CQ0 "
	cQuery += " 		WHERE	 "
	cQuery += " 			CQ0.CQ0_TPSALD =	'1' and "
	cQuery += " 			CQ0.CQ0_MOEDA =	'01'	and "
	cQuery += " 			CQ0.CQ0_FILIAL = '" + xFilial("CQ0") + "'	and "
	cQuery += " 			CQ0.D_E_L_E_T_ = ' '	and "
	cQuery += " 			CQ0.CQ0_DATA <=	'" + dTos(dDataFim) + "' "
	cQuery += " 		GROUP BY "
	cQuery += " 			CQ0_CONTA	 "
	cQuery += " 	) T1 "
	cQuery += " 	GROUP BY "
	cQuery += " 		CONTA	,  "
	cQuery += " 		CUSTO	, "
	cQuery += " 		ITEM	, "
	cQuery += " 		CLVL "
	cQuery += " ) TFIM	 "
	cQuery += " LEFT JOIN ( "
	cQuery += " 	SELECT "
	cQuery += " 		CONTA	,  "
	cQuery += " 		SUM(ANTSLD) ANTSLD , "
	cQuery += " 		SUM(CRD) CRD     , "
	cQuery += " 		SUM(DEB) DEB     , "
	cQuery += " 		SUM(MOV) MOV     ,  "
	cQuery += " 		SUM(ATUSLD) ATUSLD   "
	cQuery += " 	FROM "
	cQuery += " 		" + cTabCTI + " TMPAUXCTI "
	cQuery += " 	GROUP BY "
	cQuery += " 		CONTA	 "
	cQuery += " 	) tCTI "
	cQuery += " ON "
	cQuery += " 	TFIM.CONTA	= tCTI.CONTA "
	cQuery += " LEFT JOIN ( "
	cQuery += " 	SELECT "
	cQuery += " 		CONTA	,  "
	cQuery += " 		SUM(ANTSLD) ANTSLD , "
	cQuery += " 		SUM(CRD) CRD     , "
	cQuery += " 		SUM(DEB) DEB     , "
	cQuery += " 		SUM(MOV) MOV     ,  "
	cQuery += " 		SUM(ATUSLD) ATUSLD   "
	cQuery += " 	FROM "
	cQuery += " 		" + cTabCT4 + " TMPAUXCT4 "
	cQuery += " 	GROUP BY "
	cQuery += " 		CONTA	 "
	cQuery += " 	) tCT4 "
	cQuery += " ON "
	cQuery += " 	TFIM.CONTA	= tCT4.CONTA  "
	cQuery += " LEFT JOIN ( "
	cQuery += " 	SELECT "
	cQuery += " 		CONTA	,  "
	cQuery += " 		SUM(ANTSLD) ANTSLD , "
	cQuery += " 		SUM(CRD) CRD     , "
	cQuery += " 		SUM(DEB) DEB     , "
	cQuery += " 		SUM(MOV) MOV     ,  "
	cQuery += " 		SUM(ATUSLD) ATUSLD   "
	cQuery += " 	FROM "
	cQuery += " 		" + cTabCT3 + " TMPAUXCT3 "
	cQuery += " 	GROUP BY "
	cQuery += " 		CONTA	 "
	cQuery += " 	) tCT3 "
	cQuery += " ON "
	cQuery += " 	TFIM.CONTA	= tCT3.CONTA "
	
	If !( lSQL )
		cQuery := BIXCtbTable( cQuery, @cTabCT7,1 )
	Else
		cQuery := ChangeQuery(cQuery)
		If ( TCSQLExec ( cQuery ) < 0 )
			Conout( TCSQLError() )
			MemoWrite( "BIXCT7.log", cQuery ) 	
		EndIf
	EndIf
Return cTabCT7


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXCTIO
Devolve os movimentos das classes de valor

É devolvido um arquivo temporário com os campos:
	CONTA		Código da conta
	CUSTO		Código do centro de custo
	ITEM		Código do item contábil
	CLVL		Código da classe de valor
	MOVORC		Movimento orçado no período
	MOVEMP		Movimento empenhado no período
	MOVREAL	Movimento real no período
	MOVPREV	Movimento previsto no período
	

@protected
@param dDataIni		Data inicial da extração
@param dDataFim		Data final da extração

@return cTabCTI	Nome do arquivo temporário
/*/
//-------------------------------------------------------------------------------------
Static Function BIXCTIO( dDataIni, dDataFim )
	Local cQuery		:= ""
	Local cTabCTI		:= BIXTblTmpAlias( )
	Local cFilCTI		:= xFilial("CTI")
	Local lSQL			:= "SQL" $ TcGetDB()

	cQuery += " SELECT "
	cQuery += " 	CONTA	,  "
	cQuery += " 	CUSTO	, "
	cQuery += " 	ITEM	, "
	cQuery += " 	CLVL	, "
	cQuery += " 	TPSALD  , "
	cQuery += " 	(ATUCRED - ATUDEB) - (ANTCRED - ANTDEB ) as MOV "
	
	If ( lSQL )
		cQuery += " INTO " + cTabCTI
	EndIf
	
	cQuery += " FROM "
	cQuery += " ( "
	cQuery += " 	SELECT  "
	cQuery += " 		CONTA	,  "
	cQuery += " 		CUSTO	, "
	cQuery += " 		ITEM	, "
	cQuery += " 		CLVL	, "
	cQuery += " 		TPSALD  , "
	cQuery += " 		SUM(ANTDEB)		ANTDEB  , "
	cQuery += " 		SUM(ANTCRED)	ANTCRED , "
	cQuery += " 		SUM(ATUDEB)		ATUDEB	, "
	cQuery += " 		SUM(ATUCRED)	ATUCRED  "
	cQuery += " 	FROM "
	cQuery += " 	( "
	cQuery += " 		SELECT  "
	cQuery += " 			CQ6_CONTA			CONTA	,  "
	cQuery += " 			CQ6_CCUSTO			CUSTO	, "
	cQuery += " 			CQ6_ITEM			ITEM	, "
	cQuery += " 			CQ6_CLVL			CLVL	, "
	cQuery += " 			CQ6_TPSALD			TPSALD	, "
	cQuery += " 			SUM(CQ6_DEBITO)		ANTDEB  , "
	cQuery += " 			SUM(CQ6_CREDIT)		ANTCRED , "
	cQuery += " 			0					ATUDEB	, "
	cQuery += " 			0					ATUCRED  "
	cQuery += " 		FROM  "
	cQuery += " 			" + retSqlName("CQ6") + " CQ6 "
	cQuery += " 		WHERE	 "
	cQuery += " 			CQ6.CQ6_TPSALD	in ('0','1','2','4')		and "
	cQuery += " 			CQ6.CQ6_MOEDA	=	'01'		and "
	cQuery += " 			CQ6.CQ6_FILIAL	=	'" + xFilial("CQ6") + "'		and "
	cQuery += " 			CQ6.D_E_L_E_T_	=	' '			and "
	cQuery += " 			CQ6.CQ6_DATA	<	'" + dTos(dDataIni) + "' "
	cQuery += " 		GROUP BY "
	cQuery += " 			CQ6_CONTA	,  "
	cQuery += " 			CQ6_CCUSTO	, "
	cQuery += " 			CQ6_ITEM	, "
	cQuery += " 			CQ6_CLVL	, "
	cQuery += " 			CQ6_TPSALD		 "
	cQuery += " 		UNION ALL "
	cQuery += " 		SELECT  "
	cQuery += " 			CQ6_CONTA			CONTA	,  "
	cQuery += " 			CQ6_CCUSTO			CUSTO	, "
	cQuery += " 			CQ6_ITEM			ITEM	, "
	cQuery += " 			CQ6_CLVL			CLVL	, "
	cQuery += " 			CQ6_TPSALD			TPSALD	, "
	cQuery += " 			0					ANTDEB  , "
	cQuery += " 			0					ANTCRED , "
	cQuery += " 			SUM(CQ6_DEBITO)		ATUDEB	, "
	cQuery += " 			SUM(CQ6_CREDIT)		ATUCRED  "
	cQuery += " 		FROM  "
	cQuery += " 			" + retSqlName("CQ6") + " CQ6 "
	cQuery += " 		WHERE	 "
	cQuery += " 			CQ6.CQ6_TPSALD	in ('0','1','2','4') and "
	cQuery += " 			CQ6.CQ6_MOEDA	=	'01'		and "
	cQuery += " 			CQ6.CQ6_FILIAL	=	'" + xFilial("CQ6") + "'		and "
	cQuery += " 			CQ6.D_E_L_E_T_	=	' '	 and "
	cQuery += " 			CQ6.CQ6_DATA	<=	'" + dTos(dDataFim) + "' "
	cQuery += " 		GROUP BY "
	cQuery += " 			CQ6_CONTA	,  "
	cQuery += " 			CQ6_CCUSTO	, "
	cQuery += " 			CQ6_ITEM	, "
	cQuery += " 			CQ6_CLVL	, "
	cQuery += " 			CQ6_TPSALD	 "
	cQuery += " 	) T1 "	
	cQuery += " 	GROUP BY "
	cQuery += " 		CONTA	,  "
	cQuery += " 		CUSTO	, "
	cQuery += " 		ITEM	, "
	cQuery += " 		CLVL	, "
	cQuery += " 		TPSALD "
	cQuery += " ) TFIM	 "	
	cQuery += " ORDER BY  "
	cQuery += " 		CONTA	,  "
	cQuery += " 		CUSTO	, "
	cQuery += " 		ITEM	, "
	cQuery += " 		CLVL	, "
	cQuery += " 		TPSALD "
	
	If !( lSQL )
		BIXCtbTable( cQuery, @cTabCTI,2 )
	Else
		cQuery := ChangeQuery(cQuery)
		If ( TCSQLExec ( cQuery ) < 0 )
			Conout( TCSQLError() )
			MemoWrite( "BIXCTIO.log", cQuery ) 	
		EndIf
	EndIf
Return cTabCTI


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXCT4O
Devolve os movimentos dos itens contábeis

É devolvido um arquivo temporário com os campos:
	CONTA		Código da conta
	CUSTO		Código do centro de custo
	ITEM		Código do item contábil
	CLVL		Em branco
	MOVORC		Movimento orçado no período
	MOVEMP		Movimento empenhado no período
	MOVREAL	Movimento real no período
	MOVPREV	Movimento previsto no período

@protected
@param dDataIni		Data inicial da extração
@param dDataFim		Data final da extração
@param cTabCTI	Arquivo temporário (gerado com BIXCTIO) com os movimentos das entidades contábeis até o nível de classe de valor

@return cTabCT4	Nome do arquivo temporário
/*/
//-------------------------------------------------------------------------------------
Static Function BIXCT4O( dDataIni, dDataFim, cTabCTI )
	Local cQuery		:= ""
	Local cTabCT4		:= BIXTblTmpAlias( )
	Local cFilCT4		:= xFilial("CT4")
	Local lSQL			:= "SQL" $ TcGetDB()

	cQuery += " SELECT " 
	cQuery += " 	TFIM.CONTA	CONTA ,  " 
	cQuery += " 	TFIM.CUSTO	CUSTO , " 
	cQuery += " 	TFIM.ITEM	ITEM , " 
	cQuery += " 	TFIM.CLVL	CLVL, " 
	cQuery += " 	TFIM.TPSALD	TPSALD, " 
	cQuery += " 	(TFIM.ATUCRED - TFIM.ATUDEB) - (TFIM.ANTCRED - TFIM.ANTDEB ) - coalesce(tCTI.MOV,0)  MOV " 
	
	If ( lSQL )
		cQuery += " INTO " + cTabCT4
	EndIf
	
	cQuery += " FROM " 
	cQuery += " ( " 
	cQuery += " 	SELECT  " 
	cQuery += " 		CONTA ,  " 
	cQuery += " 		CUSTO , " 
	cQuery += " 		ITEM , " 
	cQuery += " 		CLVL , " 
	cQuery += " 		TPSALD, " 
	cQuery += " 		SUM(ANTDEB) ANTDEB  , " 
	cQuery += " 		SUM(ANTCRED) ANTCRED , " 
	cQuery += " 		SUM(ATUDEB) ATUDEB	, " 
	cQuery += " 		SUM(ATUCRED) ATUCRED  " 
	cQuery += " 	FROM " 
	cQuery += " 	( " 
	cQuery += " 		SELECT  " 
	cQuery += " 			CQ4_CONTA CONTA	,  " 
	cQuery += " 			CQ4_CCUSTO CUSTO	, " 
	cQuery += " 			CQ4_ITEM ITEM	, " 
	cQuery += " 			'" + space( TamSX3("CTH_CLVL")[1] ) + "' CLVL	, " 
	cQuery += " 			CQ4_TPSALD TPSALD, " 
	cQuery += " 			SUM(CQ4_DEBITO) ANTDEB  , " 
	cQuery += " 			SUM(CQ4_CREDIT) ANTCRED , " 
	cQuery += " 			0 ATUDEB , " 
	cQuery += " 			0 ATUCRED  " 
	cQuery += " 		FROM  " 
	cQuery += " 			 " + retSqlName("CQ4") + "  CQ4 " 
	cQuery += " 		WHERE	 " 
	cQuery += " 			CQ4.CQ4_TPSALD in ('0','1','2','4')  and " 
	cQuery += " 			CQ4.CQ4_MOEDA  = '01' and " 
	cQuery += " 			CQ4.CQ4_FILIAL = '" + xFilial("CQ4") + "' and " 
	cQuery += " 			CQ4.D_E_L_E_T_ = ' ' and " 
	cQuery += " 			CQ4.CQ4_DATA   < '" + dTos(dDataIni) + "' " 
	cQuery += " 		GROUP BY " 
	cQuery += " 			CQ4_CONTA	,  " 
	cQuery += " 			CQ4_CCUSTO	, " 
	cQuery += " 			CQ4_ITEM	, " 
	cQuery += " 			CQ4_TPSALD		 " 
	cQuery += " 		UNION ALL " 
	cQuery += " 		SELECT  " 
	cQuery += " 			CQ4_CONTA CONTA	,  " 
	cQuery += " 			CQ4_CCUSTO CUSTO	, " 
	cQuery += " 			CQ4_ITEM ITEM	, " 
	cQuery += " 			'" + space( TamSX3("CTH_CLVL")[1] ) + "' CLVL	, " 
	cQuery += " 			CQ4_TPSALD TPSALD, " 
	cQuery += " 			0 ANTDEB  , " 
	cQuery += " 			0 ANTCRED , " 
	cQuery += " 			SUM(CQ4_DEBITO) ATUDEB	, " 
	cQuery += " 			SUM(CQ4_CREDIT) ATUCRED  " 
	cQuery += " 		FROM  " 
	cQuery += " 			 " + retSqlName("CQ4") + "  CQ4 " 
	cQuery += " 		WHERE	 " 
	cQuery += " 			CQ4.CQ4_TPSALD in ('0','1','2','4') and " 
	cQuery += " 			CQ4.CQ4_MOEDA =	'01'	and " 
	cQuery += " 			CQ4.CQ4_FILIAL = '" + xFilial("CQ4") + "'	and " 
	cQuery += " 			CQ4.D_E_L_E_T_ = ' '	and " 
	cQuery += " 			CQ4.CQ4_DATA <=	'" + dTos(dDataFIM) + "' " 
	cQuery += " 		GROUP BY " 
	cQuery += " 			CQ4_CONTA	,  " 
	cQuery += " 			CQ4_CCUSTO	, " 
	cQuery += " 			CQ4_ITEM, " 
	cQuery += " 			CQ4_TPSALD	 " 
	cQuery += " 	) T1 " 
	cQuery += " 	GROUP BY " 
	cQuery += " 		CONTA	,  " 
	cQuery += " 		CUSTO	, " 
	cQuery += " 		ITEM	, " 
	cQuery += " 		CLVL	, " 
	cQuery += " 		TPSALD " 
	cQuery += " ) TFIM	 " 
	cQuery += " LEFT JOIN ( " 
	cQuery += " 	SELECT " 
	cQuery += " 		CONTA	,  " 
	cQuery += " 		CUSTO	, " 
	cQuery += " 		ITEM	, " 
	cQuery += " 		TPSALD  , " 
	cQuery += " 		SUM(MOV) MOV " 
	cQuery += " 	FROM " 
	cQuery += " 		" + cTabCTI + " TMPAUXCTI " 
	cQuery += " 	GROUP BY " 
	cQuery += " 		CONTA	,  " 
	cQuery += " 		CUSTO	, " 
	cQuery += " 		ITEM	, " 
	cQuery += " 		TPSALD   " 
	cQuery += " 	) tCTI " 
	cQuery += " ON " 
	cQuery += " 	TFIM.CONTA	= tCTI.CONTA AND  " 
	cQuery += " 	TFIM.CUSTO	= tCTI.CUSTO AND " 
	cQuery += " 	TFIM.ITEM	= tCTI.ITEM AND	 " 
	cQuery += " 	TFIM.TPSALD	= tCTI.TPSALD 	 " 
	
	If !( lSQL )
		cQuery := BIXCtbTable( cQuery, @cTabCT4,2 )
	Else
		cQuery := ChangeQuery(cQuery)
		If ( TCSQLExec ( cQuery ) < 0 )
			Conout( TCSQLError() )
			MemoWrite( "BIXCT4O.log", cQuery ) 
		EndIf
	EndIf
Return cTabCT4


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXCT3O
Devolve os movimentos dos centros de custos

É devolvido um arquivo temporário com os campos:
	CONTA		Código da conta
	CUSTO		Código do centro de custo
	ITEM		Em branco
	CLVL		Em branco
	MOVORC		Movimento orçado no período
	MOVEMP		Movimento empenhado no período
	MOVREAL	Movimento real no período
	MOVPREV	Movimento previsto no período

@protected
@param dDataIni		Data inicial da extração
@param dDataFim		Data final da extração
@param cTabCTI	Arquivo temporário (gerado com BIXCTIO) com os movimentos das entidades contábeis até o nível de classe de valor
@param cTabCT4	Arquivo temporário (gerado com BIXCT4O) com os movimentos das entidades contábeis até o nível de item cotábil

@return cTabCT3	Nome do arquivo temporário
/*/
//-------------------------------------------------------------------------------------
Static Function BIXCT3O( dDataIni, dDataFim, cTabCTI, cTabCT4 )
	Local cQuery		:= ""
	Local cTabCT3		:= BIXTblTmpAlias( )
	Local cFilCT3		:= xFilial("CT3")	
	Local lSQL			:= "SQL" $ TcGetDB()

	cQuery += " SELECT "
	cQuery += " 	TFIM.CONTA	CONTA,  "
	cQuery += " 	TFIM.CUSTO	CUSTO, "
	cQuery += " 	TFIM.ITEM	ITEM, "
	cQuery += " 	TFIM.CLVL	CLVL, "
	cQuery += " 	TFIM.TPSALD	TPSALD, "
	cQuery += " 	(TFIM.ATUCRED - TFIM.ATUDEB) - (TFIM.ANTCRED - TFIM.ANTDEB ) - coalesce(tCTI.MOV,0)  - coalesce(tCT4.MOV,0) MOV "
	If ( lSQL )
		cQuery += " INTO " + cTabCT3
	EndIf
	cQuery += " FROM "
	cQuery += " ( "
	cQuery += " 	SELECT  "
	cQuery += " 		CONTA ,  "
	cQuery += " 		CUSTO , "
	cQuery += " 		ITEM , "
	cQuery += " 		CLVL , "
	cQuery += " 		TPSALD, "
	cQuery += " 		SUM(ANTDEB) ANTDEB  , "
	cQuery += " 		SUM(ANTCRED) ANTCRED , "
	cQuery += " 		SUM(ATUDEB) ATUDEB	, "
	cQuery += " 		SUM(ATUCRED) ATUCRED  "
	cQuery += " 	FROM "
	cQuery += " 	( "
	cQuery += " 		SELECT "
	cQuery += " 			CQ2_CONTA CONTA	, "
	cQuery += " 			CQ2_CCUSTO CUSTO	, "
	cQuery += " 			'" + space( TamSX3("CTD_ITEM")[1] ) + " ' ITEM	, "
	cQuery += " 			'" + space( TamSX3("CTH_CLVL")[1] ) + " ' CLVL	, "
	cQuery += " 			CQ2_TPSALD TPSALD, "
	cQuery += " 			SUM(CQ2_DEBITO) ANTDEB  , "
	cQuery += " 			SUM(CQ2_CREDIT) ANTCRED , "
	cQuery += " 			0 ATUDEB , "
	cQuery += " 			0 ATUCRED  "
	cQuery += " 		FROM  "
	cQuery += " 			" + retSqlName("CQ2") + " CQ2 "
	cQuery += " 		WHERE
	cQuery += " 			CQ2.CQ2_TPSALD  in ('0','1','2','4')   and "
	cQuery += " 			CQ2.CQ2_MOEDA  = '01' and "
	cQuery += " 			CQ2.CQ2_FILIAL = '" + xFilial("CQ2") + "' and "
	cQuery += " 			CQ2.D_E_L_E_T_ = ' ' and "
	cQuery += " 			CQ2.CQ2_DATA   < '" + dTos(dDataIni) + "' "
	cQuery += " 		GROUP BY "
	cQuery += " 			CQ2_CONTA	,  "
	cQuery += " 			CQ2_CCUSTO	, "
	cQuery += " 			CQ2_TPSALD "
	cQuery += " 		UNION ALL "
	cQuery += " 		SELECT  "
	cQuery += " 			CQ2_CONTA CONTA	, "
	cQuery += " 			CQ2_CCUSTO CUSTO	, "
	cQuery += " 			'" + space( TamSX3("CTD_ITEM")[1] ) + " ' ITEM	, "
	cQuery += " 			'" + space( TamSX3("CTH_CLVL")[1] ) + " ' CLVL	, "
	cQuery += " 			CQ2_TPSALD TPSALD, "
	cQuery += " 			0 ANTDEB  , "
	cQuery += " 			0 ANTCRED , "
	cQuery += " 			SUM(CQ2_DEBITO) ATUDEB	, "
	cQuery += " 			SUM(CQ2_CREDIT) ATUCRED  "
	cQuery += " 		FROM  "
	cQuery += " 			" + retSqlName("CQ2") + " CQ2 "
	cQuery += " 		WHERE "
	cQuery += " 			CQ2.CQ2_TPSALD  in ('0','1','2','4')  and "
	cQuery += " 			CQ2.CQ2_MOEDA =	'01'	and "
	cQuery += " 			CQ2.CQ2_FILIAL = '" + xFilial("CQ2") + "'	and "
	cQuery += " 			CQ2.D_E_L_E_T_ = ' '	and "
	cQuery += " 			CQ2.CQ2_DATA <=	'" + dTos(dDataFim) + "' "
	cQuery += " 		GROUP BY "
	cQuery += " 			CQ2_CONTA	,  "
	cQuery += " 			CQ2_CCUSTO	, "
	cQuery += " 			CQ2_TPSALD  "
	cQuery += " 	) T1 "
	
	cQuery += " 	GROUP BY "
	cQuery += " 		CONTA	,  "
	cQuery += " 		CUSTO	, "
	cQuery += " 		ITEM	, "
	cQuery += " 		CLVL	, "
	cQuery += " 		TPSALD "
	cQuery += " ) TFIM	 "
	cQuery += " LEFT JOIN ( "
	cQuery += " 	SELECT "
	cQuery += " 		CONTA	,  "
	cQuery += " 		CUSTO	, "
	cQuery += " 		TPSALD  , "
	cQuery += " 		SUM(MOV) MOV      "
	cQuery += " 	FROM "
	cQuery += " 		" + cTabCTI + " TMPAUXCTI "
	cQuery += " 	GROUP BY "
	cQuery += " 		CONTA	,  "
	cQuery += " 		CUSTO	, "
	cQuery += " 		TPSALD "
	cQuery += " 	) tCTI "
	cQuery += " ON "
	cQuery += " 	TFIM.CONTA	= tCTI.CONTA AND "
	cQuery += " 	TFIM.CUSTO	= tCTI.CUSTO  AND "
	cQuery += " 	TFIM.TPSALD	= tCTI.TPSALD 	 " 
	cQuery += " LEFT JOIN ( "
	cQuery += " 	SELECT "
	cQuery += " 		CONTA	,  "
	cQuery += " 		CUSTO	, "
	cQuery += " 		TPSALD  , "
	cQuery += " 		SUM(MOV) MOV   "
	cQuery += " 	FROM "
	cQuery += " 		" + cTabCT4 + " TMPAUXCT4 "
	cQuery += " 	GROUP BY "
	cQuery += " 		CONTA	,  "
	cQuery += " 		CUSTO	, "
	cQuery += " 		TPSALD "
	cQuery += " 	) tCT4 "
	cQuery += " ON "
	cQuery += " 	TFIM.CONTA	= tCT4.CONTA AND "
	cQuery += " 	TFIM.CUSTO	= tCT4.CUSTO  AND"
	cQuery += " 	TFIM.TPSALD	= tCT4.TPSALD 	 " 
	
	If !( lSQL )
		cQuery := BIXCtbTable( cQuery, @cTabCT3,2 )
	Else
		cQuery := ChangeQuery(cQuery)
		If ( TCSQLExec ( cQuery ) < 0 )
			Conout( TCSQLError() )
			MemoWrite( "BIXCT3O.log", cQuery ) 
		EndIf
	EndIf
Return cTabCT3


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXCT7O
Devolve os movimentos das contas contábeis

É devolvido um arquivo temporário com os campos:
	CONTA		Código da conta
	CUSTO		Em branco
	ITEM		Em branco
	CLVL		Em branco
	MOVORC		Movimento orçado no período
	MOVEMP		Movimento empenhado no período
	MOVREAL	Movimento real no período
	MOVPREV	Movimento previsto no período

@protected
@param dDataIni		Data inicial da extração
@param dDataFim		Data final da extração
@param cTabCTI	Arquivo temporário (gerado com BIXCTIO) com os movimentos das entidades contábeis até o nível de classe de valor
@param cTabCT4	Arquivo temporário (gerado com BIXCT4O) com os movimentos das entidades contábeis até o nível de item cotábil
@param cTabCT3	Arquivo temporário (gerado com BIXCT3O) com os movimentos das entidades contábeis até o nível de centro de custo

@return cTabCT7	Nome do arquivo temporário
/*/
//-------------------------------------------------------------------------------------
Static Function BIXCT7O( dDataIni, dDataFim, cTabCTI, cTabCT4, cTabCT3 )
	Local cQuery		:= ""
	Local cTabCT7		:= BIXTblTmpAlias( )
	Local cFilCT7		:= xFilial("CT7")
	Local lSQL			:= "SQL" $ TcGetDB()

	cQuery += "  SELECT "
	cQuery += "  	TFIM.CONTA	 CONTA, "
	cQuery += "  	TFIM.CUSTO	 CUSTO, "
	cQuery += "  	TFIM.ITEM	ITEM, "
	cQuery += "  	TFIM.CLVL	CLVL, "
	cQuery += "  	TFIM.TPSALD	TPSALD, "
	cQuery += "  	(TFIM.ATUCRED - TFIM.ATUDEB) - (TFIM.ANTCRED - TFIM.ANTDEB ) - coalesce(tCTI.MOV,0)  - coalesce(tCT4.MOV,0) - coalesce(tCT3.MOV,0) MOV "

	If ( lSQL )
		cQuery += " INTO " + cTabCT7
	EndIf
	
	cQuery += "  FROM  "
	cQuery += "  (  "
	cQuery += "  	SELECT   "
	cQuery += "  		CONTA ,   "
	cQuery += "  		CUSTO ,  "
	cQuery += "  		ITEM ,  "
	cQuery += "  		CLVL , "
	cQuery += "  		TPSALD,  "
	cQuery += "  		SUM(ANTDEB) ANTDEB  , "
	cQuery += "  		SUM(ANTCRED) ANTCRED ,  "
	cQuery += "  		SUM(ATUDEB) ATUDEB	,  "
	cQuery += "  		SUM(ATUCRED) ATUCRED   "
	cQuery += "  	FROM  "
	cQuery += "  	(  "
	cQuery += "  		SELECT  "
	cQuery += "  			CQ0_CONTA CONTA	, "
	cQuery += " 			'" + space( TamSX3("CTT_CUSTO")[1] ) + "' CUSTO	, "
	cQuery += "  			'" + space( TamSX3("CTD_ITEM")[1] ) + "' ITEM	,  "
	cQuery += " 			'" + space( TamSX3("CTH_CLVL")[1] ) + "' CLVL	,  "
	cQuery += "  			CQ0_TPSALD TPSALD , "
	cQuery += "  			SUM(CQ0_DEBITO) ANTDEB  ,  "
	cQuery += "  			SUM(CQ0_CREDIT) ANTCRED ,  "
	cQuery += "  			0 ATUDEB ,  "
	cQuery += "  			0 ATUCRED   "
	cQuery += "  		FROM   "
	cQuery += "  			" + retSqlName("CQ0") + " CQ0 "
	cQuery += "  		WHERE	  "
	cQuery += "  			CQ0.CQ0_TPSALD  in ('0','1','2','4')   and "
	cQuery += "  			CQ0.CQ0_MOEDA  = '01' and  "
	cQuery += "  			CQ0.CQ0_FILIAL = '" + xFilial("CQ0") + "' and "
	cQuery += "  			CQ0.D_E_L_E_T_ = ' ' and  "
	cQuery += "  			CQ0.CQ0_DATA   < '" + dTos(dDataIni) + "' "
	cQuery += "  		GROUP BY  "
	cQuery += "  			CQ0_CONTA, "
	cQuery += "  			CQ0_TPSALD	  "
	cQuery += "  		UNION ALL  "
	cQuery += "  		SELECT   "
	cQuery += "  			CQ0_CONTA CONTA	, "
	cQuery += " 			'" + space( TamSX3("CTT_CUSTO")[1] ) + "' CUSTO	, "
	cQuery += "  			'" + space( TamSX3("CTD_ITEM")[1] ) + "' ITEM	,  "
	cQuery += " 			'" + space( TamSX3("CTH_CLVL")[1] ) + "' CLVL	,  "
	cQuery += "  			CQ0_TPSALD TPSALD , "
	cQuery += "  			0 ANTDEB  ,  "
	cQuery += "  			0 ANTCRED ,  "
	cQuery += "  			SUM(CQ0_DEBITO) ATUDEB	,  "
	cQuery += "  			SUM(CQ0_CREDIT) ATUCRED   "
	cQuery += "  		FROM   "
	cQuery += "  			" + retSqlName("CQ0") + " CQ0 "
	cQuery += "  		WHERE	  "
	cQuery += "  			CQ0.CQ0_TPSALD   in ('0','1','2','4')  and "
	cQuery += " 			CQ0.CQ0_MOEDA =	'01'	and  "
	cQuery += "  			CQ0.CQ0_FILIAL = '" + xFilial("CQ0") + "'	and "
	cQuery += "  			CQ0.D_E_L_E_T_ = ' '	and  "
	cQuery += "  			CQ0.CQ0_DATA <=	'" + dTos(dDataFim) + "' "
	cQuery += "  		GROUP BY  "
	cQuery += "  			CQ0_CONTA, "
	cQuery += "  			CQ0_TPSALD  "
	cQuery += "  	) T1  "
	cQuery += "  	GROUP BY  "
	cQuery += "  		CONTA	,   "
	cQuery += "  		CUSTO	,  "
	cQuery += "  		ITEM	,  "
	cQuery += "  		CLVL , "
	cQuery += "  		TPSALD "
	cQuery += "  ) TFIM	  "
	cQuery += "  LEFT JOIN (  "
	cQuery += "  	SELECT  "
	cQuery += "  		CONTA	,   "
	cQuery += " 		TPSALD , "
	cQuery += "  		SUM(MOV) MOV   "
	cQuery += "  	FROM  "
	cQuery += "  		" + cTabCTI + " TMPAUXCTI "
	cQuery += "  	GROUP BY  "
	cQuery += "  		CONTA, "
	cQuery += "  		TPSALD	  "
	cQuery += "  	) tCTI  "
	cQuery += "  ON  "
	cQuery += "  	TFIM.CONTA	= tCTI.CONTA AND "
	cQuery += " 	TFIM.TPSALD	= tCTI.TPSALD 	 " 
	cQuery += "  LEFT JOIN (  "
	cQuery += "  	SELECT  "
	cQuery += "  		CONTA	,   "
	cQuery += " 		TPSALD , "
	cQuery += "  		SUM(MOV) MOV  "
	cQuery += "  	FROM  "
	cQuery += "  		" + cTabCT4 + " TMPAUXCT4 "
	cQuery += "  	GROUP BY  "
	cQuery += "  		CONTA, "
	cQuery += "  		TPSALD	  "
	cQuery += "  	) tCT4  "
	cQuery += "  ON  "
	cQuery += "  	TFIM.CONTA	= tCT4.CONTA AND"
	cQuery += " 	TFIM.TPSALD	= tCT4.TPSALD 	 " 
	cQuery += "  LEFT JOIN (  "
	cQuery += "  	SELECT  "
	cQuery += "  		CONTA	,   "
	cQuery += " 		TPSALD , "
	cQuery += "  		SUM(MOV) MOV     "
	cQuery += "  	FROM  "
	cQuery += "  		" + cTabCT3 + " TMPAUXCT3 "
	cQuery += "  	GROUP BY  "
	cQuery += "  		CONTA, "
	cQuery += "  		TPSALD  "
	cQuery += "  	) tCT3  "
	cQuery += "  ON  "
	cQuery += "  	TFIM.CONTA	= tCT3.CONTA AND "
	cQuery += " 	TFIM.TPSALD	= tCT3.TPSALD 	 " 
	
	If !( lSQL )
		cQuery := BIXCtbTable( cQuery, @cTabCT7,2 )
	Else
		cQuery := ChangeQuery(cQuery)
		If ( TCSQLExec ( cQuery ) < 0 )
			Conout( TCSQLError() )
			MemoWrite( "BIXCT7O.log", cQuery ) 
		EndIf
	EndIf
Return cTabCT7
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXCtbTable
Cria tabela temporária para bancos. No SQLServer isso não é necessário

@param cQuery 			Tabela que deverá ser removida. 
@param cTemporary  	Tabela temporária que será criada e populada. 
 
@author  Valdiney V GOMES
@version P11
@since   17/12/2013
/*/
//-------------------------------------------------------------------------------------
Static Function BIXCtbTable( cQuery, cTemporary ,nTipo) 
	Local aStruSQL := {}
	Local aFieldSize:= TAMSX3("CT2_VALOR")
	
	If ( TCGetDB() $ "INFORMIX*ORACLE" )
		cQuery := StrTran( cQuery, "coalesce", "NVL" )
		cQuery := StrTran( cQuery, "COALESCE", "NVL" )
	EndIf
		
	If nTipo == 1 // BIXCtCnt
		AADD(aStruSQL,{"CONTA"		,"C",TAMSX3("CT1_CONTA")[1]		,00})
		AADD(aStruSQL,{"CUSTO" 		,"C",TAMSX3("CTT_CUSTO")[1]		,00})
		AADD(aStruSQL,{"ITEM"		,"C",TAMSX3("CTD_ITEM")[1]		,00})
		AADD(aStruSQL,{"CLVL"		,"C",TAMSX3("CTH_CLVL")[1]		,00})
		AADD(aStruSQL,{"ANTSLD"		,"N",aFieldSize[1]				,aFieldSize[2]})
		AADD(aStruSQL,{"CRD"			,"N",aFieldSize[1]				,aFieldSize[2]})
		AADD(aStruSQL,{"DEB"			,"N",aFieldSize[1]				,aFieldSize[2]})
		AADD(aStruSQL,{"MOV"			,"N",aFieldSize[1]				,aFieldSize[2]})
		AADD(aStruSQL,{"ATUSLD"		,"N",aFieldSize[1]				,aFieldSize[2]})
	Else// BIXCtCntO
		AADD(aStruSQL,{"CONTA"		,"C",TAMSX3("CT1_CONTA")[1]		,00})
		AADD(aStruSQL,{"CUSTO" 		,"C",TAMSX3("CTT_CUSTO")[1]		,00})
		AADD(aStruSQL,{"ITEM"		,"C",TAMSX3("CTD_ITEM")[1]		,00})
		AADD(aStruSQL,{"CLVL"		,"C",TAMSX3("CTH_CLVL")[1]		,00})
		AADD(aStruSQL,{"TPSALD"		,"C",TAMSX3("CT2_TPSALD")[1]	,00})
		AADD(aStruSQL,{"MOV"			,"N",aFieldSize[1]				,aFieldSize[2]})
	EndIf
	
	BIXSQLToTable( cQuery, aStruSQL, @cTemporary )
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXSQLToTable
Cria uma tabela no banco de dados a partir do resultset de uma instrução SQL

@param cQuery 		Instrução SQL		
@param aStruct  	Estrutura da tabela. 
@param cTable  	Nome da tabela. 
 
@author  Marcia Junko
@version P12
@since   04/05/2015
/*/
//-------------------------------------------------------------------------------------
Static Function BIXSQLToTable( cQuery, aStruct, cTable )
	Local nField    := 0
	Local cAlias	:= GetNextAlias()
	
	Default aStruct	:= {}
	Default cQuery	:= ""
	Default cTable	:= ""
	
	//-------------------------------------------------------------------
	// Monta o alias temporário com o resultado da query. 
	//-------------------------------------------------------------------
	DBUseArea( .T., "TOPCONN", TCGenQry( ,,ChangeQuery( cQuery ) ), cAlias, .F., .T. )

	//------------------------------------------------------------------
	// Valida se a tabela existe no banco, e caso exista, pesquisa uma 
	// nova tabela que pode ser utilizada 
	//-------------------------------------------------------------------
	BIXTblTmpAlias( @cTable )
	
	//-------------------------------------------------------------------
	// Cria a estrutura da tabela no banco de dados. 
	//-------------------------------------------------------------------
	MSCreate( cTable, aStruct, "TOPCONN" ) 
	DBUseArea( .T., "TOPCONN", cTable, cTable, .T., .F. ) 
	DBSelectArea( cTable )

	//-------------------------------------------------------------------
	// Transfere os dados do alias temporário para a tabela. 
	//-------------------------------------------------------------------
	While ! ( (cAlias)->( Eof() ) )
		If ( (cTable)->( RecLock( cTable , .T. ) ) )
			For nField := 1 To Len( aStruct )
				If ( aStruct[nField][2] == "N" )
					(cTable)->&( aStruct[nField][1] ) := Round( (cAlias)->&( aStruct[nField][1] ), aStruct[nField][4] )
				Else
					(cTable)->&( aStruct[nField][1] ) := (cAlias)->&( aStruct[nField][1] )
				EndIf 
			Next nField
			
			(cTable)->( MsUnlock() )
		EndIf

		(cAlias)->( DBSkip() )
	EndDo
	
	(cAlias)->( DBCloseArea() )
Return Nil
  
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXPutGC
Indica que uma tabela deve ser removida após seu uso. 

@param cFile Tabela que deverá ser removida. 

@author  Valdiney V GOMES
@version P11
@since   17/12/2013
/*/
//-------------------------------------------------------------------------------------
Static Function BIXPutGC( cFile ) 
	Local aTemporary	:= {}
	Local nTable 		:= 1   

	For nTable := 1 To Len( aTables )
		If ! ( aTables[nTable] == Nil )
			aAdd( aTemporary, aTables[nTable] )
		EndIf      
	Next nTable 
	
	aTables := aClone( aTemporary )

	If ! ( aScan( aTables, cFile ) > 0 )
   		aAdd( aTables, cFile )  
   	EndIf
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXRunGC
Remove as tabelas temporárias da rotina

@author  Valdiney V GOMES
@version P11
@since   17/12/2013
/*/
//-------------------------------------------------------------------------------------
Function BIXRunGC() 
	Local nTable 	:= 1

	For nTable := 1 To Len( aTables )
		If ! ( aTables[nTable] == Nil ) 
			If ( Select( aTables[nTable] ) > 0 )
		 		( aTables[nTable] )->( DBCloseArea() )	
			EndIf 
			
			If( TcDelFile( aTables[nTable] ) )
			 	aTables[nTable] := Nil 
			EndIf   
		EndIf
	Next nTable	  
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXExistMoedaCtb()
Verifica se a moeda contábil utilizada para processamento da fato Indicadores 
Gerenciais foi cadastrada para que não ocorram erros durante o processo de extração.

@author  Helio Leal
@version P12
@since   13/04/2016
/*/
//-------------------------------------------------------------------------------------
Function BIXExistMoedaCtb()
	Local lRet 	:= .F.
	Local aArea	:= GetArea()

	DbSelectArea("CTO")
	CTO->( DbGotop() )
	CTO->( DbSetOrder(1) )

	//-------------------------------------------------------------------
	// O conteúdo "01" é o mesmo passado como 18º posição na função BIXCtGerInd() 
	//-------------------------------------------------------------------
	lRet := CTO->( DbSeek( xFilial("CTO") + "01" ) )

	RestArea(aArea)
Return lRet


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BIXGetCTBValue
Retorna o conteúdo da função ValorCTB em número com os tratamentos necessário para a 
gravação na Fluig Smart Data a fim de obter o mesmo resultado da CTBR040 
(Balancete Modelo 1)

@author  Helio Leal
@version P12
@since   24/01/2017
/*/
//-------------------------------------------------------------------------------------
Function BIXGetCTBValue( xValue )
	Local nValue := 0
	Local nAux	 := 0
	
	//------------------------------------------------------
	// Faz o tratamento ajustando os separadores 
	//------------------------------------------------------
	If UPPER(AllTrim(GetSrvProfString("PictFormat", ""))) == "AMERICAN"
		nAux := strtran(xValue, ",", "")
	Else
		nAux := strtran(xValue, ".", "")
		nAux := strtran(nAux, ",", ".")	
	EndIf
	
	//------------------------------------------------------
	// Transforma o caracter em número para gravar na FSD 
	//------------------------------------------------------
	nValue := Val( nAux )
Return nValue
