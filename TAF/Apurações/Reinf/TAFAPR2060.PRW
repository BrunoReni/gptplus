#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPR2060.CH"

#DEFINE MB_ICONHAND 16
#DEFINE SINTETICO 	1,1
#DEFINE ATIVIDADE 	2,1
#DEFINE COMPLEMENTO	3,1
#DEFINE PROCESSOS 	4,1
#DEFINE AJUSTE		5,1
#DEFINE DELETSINT 	1,2
#DEFINE DELETATIV 	2,2
#DEFINE DELETCMPT 	3,2
#DEFINE DELETPROC 	4,2
#DEFINE DELETAJST 	5,2
#DEFINE DEFEMP	 	1
#DEFINE DEFUND 		2
#DEFINE DEFFIL  	3

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR2060

@description Rotina de apuração do evento R-2060 - Contrib Previdenciária Receita Bruta CPRB 
@description LayOut Unico T082 (CPRB) / Legado CPRB TAFA097 / Espelho TAFA499 
				
@author Denis Souza
@since  02/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function TAFAPR2060(cReg,cPerApu,dtIni,dtFin,cIdApReinf,aFil,oProcess, lValid, cKey, lSucesso)

	Local lProc As Logical
	
	Default cReg 		:= "R-2060"
	Default cIdTrans	:= {}

	lProc := oProcess <> Nil 

	If lProc
		oProcess:IncRegua2(STR0001 + cReg ) //"Processando apuração "
	EndIf
	TAFR2060( cReg, cPerApu, dtIni, dtFin, cIdApReinf, aFil, oProcess, lValid, cKey, @lSucesso)

Return Nil

Static Function TAFR2060( cReg, cPerApu, dtIni, dtFin, cIdApReinf, aFil, oProcess, lValid, cKey, lSucesso)

	Local aLog 			As Array
	Local aMovs			As Array
	Local aApurac		As Array
	Local aAreaSM0 		As Array
	Local aInfoC1E		As Array
	Local aInfoEUF		As Array
	Local cStatReg 		As Character
	Local cNrInsc		As Character
	Local cPerApu		As Character
	Local cPerApuGrv	As Character
	Local lExecApr		As Logical
	Local lProc			As Logical
	Local lDsarm		As Logical
	Local nContApur		As Numeric
	Local nTotReg		As Numeric	
	Local nContLog		As Numeric
	LocaL nTNrInsc		As Numeric

	Default cKey := ""

	aLog  		:= {}
	aApurac		:= {}
	aAreaSM0 	:= SM0->(GetArea())
	aInfoC1E	:= {}
	aInfoEUF	:= {}
	cStatReg 	:= "Z"
	cNrInsc		:= ""
	
	cPerApuGrv 	:= cPerApu
	cPerApu 	:= SubSTR(cPerApu,3,4) + SubSTR(cPerApu,1,2)	

	lExecApr	:= .F.
	lProc 		:= oProcess <> nil
	lDsarm		:= .F.
	nContApur	:= 1
	nTotReg		:= 0	
	nContLog	:= 0
	nTNrInsc	:= TamSX3( "V0S_NRINSC" )[1]

	DbSelectArea("V0S")
	V0S->(DbSetOrder(2)) //V0S_FILIAL, V0S_PERAPU, V0S_TPINSC, V0S_NRINSC, V0S_ATIVO

	If !Empty(cPerApu)
		If lProc 
			oProcess:IncRegua2(STR0002) // "Selecionando dados a serem apurados"
		EndIf
		aInfoEUF	:= TamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
		aApurac		:= Qury2060(cPerApu,.T.,.F., aFil,aInfoEUF,@aMovs, cKey)
		lExecApr	:= iif( len(aApurac) >= 6 , aApurac[6], .F.)
	EndIf
	
	If lExecApr
		If !(aApurac[SINTETICO])->(Eof())		
			
			(aApurac[SINTETICO])->(DbSetOrder(1))
			(aApurac[SINTETICO])->(DbEval({|| ++nTotReg }))
			(aApurac[SINTETICO])->(DbGoTop())
			
			If lProc
				oProcess:IncRegua2(STR0003) //"Gravando registros"
				oProcess:SetRegua2(nTotReg)
			EndIf
	
			Begin Transaction
				While !(aApurac[SINTETICO])->(Eof())
				
					if (AllTrim((aApurac[SINTETICO])->CHAVE) $ cKey .or. Empty(cKey))
						cNrInsc := (aApurac[SINTETICO])->CNRINSC
						
						cStatus := StatsReg( cPerApuGrv , (aApurac[SINTETICO])->CTPINSC , cNrInsc )

						If lProc
							oProcess:IncRegua2(STR0004 + cValTochar(nContApur++) + "/" + cValTochar(nTotReg)) //Gravando
						EndIf

						Do Case
						//Alteração direta na base, e retorno do V0S_STATUS para branco
						Case cStatus $ ' |0|1|3|7'
							If ExcluiReg(cIdApReinf, cReg, @aLog)
								If !Grava2060(MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, V0S->V0S_VERANT, V0S->V0S_PROTPN, cIdApReinf, @aLog, V0S->V0S_ID, lValid, cStatus )							
									lDsarm := .T.
									lSucesso := .F.
								Else
									lSucesso := .T.
								EndIf 
							Else
								lDsarm := .T.
								lSucesso := .F.
							EndIf 
		
						//Registro transmitido ao governo e sem retorno, não deve ser alterado
						Case cStatus $ '2|6'
							cErro	:= STR0006 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
		
							cErro 	+= "tpInsc: " + (aApurac[SINTETICO])->CTPINSC + CRLF
							cErro 	+= "nrInsc: " + cNrInsc + CRLF
		
							cErro 	+= STR0007 + CRLF //"A apuração foi cancelada pois este registro já foi transmitido e está aguardando retorno do RET, portanto não pode ser modificado."
							Aadd(aLog, {cReg, "ERRO", cErro}) //!?
							lDsarm := .T.
							lSucesso := .F.
			
						Case cStatus == '4'
		
							cVerAnt := V0S->V0S_VERSAO
							cProTpn := V0S->V0S_PROTUL
			
							FAltRegAnt( 'V0S', '2', .F. )
			
							If !Grava2060( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, cVerAnt, cProTpn, cIdApReinf, @aLog, V0S->V0S_ID)
								lDsarm := .T.
								lSucesso := .F.
							Else
								lSucesso := .T.
							EndIf
		
						Case cStatus == "Z" // Commit do modelo em modo de inclusão

							if !Grava2060( MODEL_OPERATION_INSERT , cPerApuGrv, aApurac, aInfoC1E, , , cIdApReinf, @aLog, , lValid, cStatus ) 
								lDsarm := .T.
								lSucesso := .F.
							Else
								lSucesso := .T.
							EndIf
						
						EndCase
					EndIf
					 
					(aApurac[SINTETICO])->(DbSkip())
				EndDo

				If lDsarm
					DisarmTransaction()
				Else 
					GravaId(aMovs,cIdApReinf)
				EndIf
			End Transaction

			For nContLog := 1 to Len(aLog)
				TafXLog(cIdApReinf, aLog[nContLog][1], aLog[nContLog][2], aLog[nContLog][3] )
			Next nContLog
		EndIf

		//Destroi as tabelas temporárias
		aApurac[DELETSINT]:Delete()
		aApurac[DELETATIV]:Delete()
		aApurac[DELETCMPT]:Delete()		
		aApurac[DELETPROC]:Delete()
		aApurac[DELETAJST]:Delete()	
	Else
		//Alimenta aLog com Informação de que a Data Inicial está vazia
		TafXLog(cIdApReinf, cReg, "ALERTA", STR0005) //"Não foram localizados registros que atendam os parâmetros selecionados para processamento da apuração."
	EndIf
	
	RestArea(aAreaSM0)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} StatsReg
Verifica a existência ou não do registro que será apurado

@author Denis Souza
@since  02/04/2018
@version 1.0
@return Retorna o status do registro encontrado, caso contrário retorna status "Z", indicando que ainda não existe o registro no cadastro espelho

/*/ 
//-------------------------------------------------------------------

Static Function StatsReg( cPerApu, cTpInsc, cNrInsc )

	Local 	cRetStat As Character
	Default cPerApu	:= ""
	
	cRetStat := "Z"

	If V0S->(MsSeek(cFilAnt + cPerApu + cTpInsc + cNrInsc + '1'))
		cRetStat := V0S->V0S_STATUS
	EndIf
	
Return cRetStat

//-------------------------------------------------------------------
/*/{Protheus.doc} Qury2060
Rotina de apuração da CPRB
Registro R-2060 da Reinf

@author Denis Souza
@since  02/04/2018
@version 1.0
@return Retorna a string da query

/*/ 
//-------------------------------------------------------------------
 
Function Qury2060(cPerApu,lApur,lIdProc,aFil,aInfEUF,aMovs, cKey)

	Local cFiliais	As 	Character
	Local cQuery 	As 	Character
	Local cBd		As 	Character
	Local cAliasApr As	Character
	Local cSelect	As	Character
	Local cSelV48	As 	Character
	Local cWhere	As	Character
	Local cWhereV48	As	Character
	Local cLeftV48	As	Character
	Local cGroupC5M As 	Character
	Local cOrder 	As	Character
	Local cCmpQry	As 	Character
	Local cFromC5M	As	Character
	Local cFromV48	As	Character
	Local cIJoinC5V	As 	Character
	Local cIJoinC5M As	Character
	Local cLJoinV48 As	Character
	Local cLJoinT9T As	Character
	Local cLJoinSUM As	Character
	Local cLJSUMT9T As	Character
	Local cLJoinT9C As	Character
	Local ciJoinT9C	As	Character
	Local aRegApur	As 	Array
	Local lV48		As	Logical
	Local lProcid	As 	Logical

	Default cPerApu		:= ""	
	Default aInfEUF 	:= {}
	Default aMovs		:= {}

	cFiliais 	:= TafRetFilC("C5M", aFil) 
	cQuery		:= ""
	cBd			:= TcGetDb()
	cAliasApr	:= GetNextAlias()
	cSelect		:= ""
	cSelV48		:= ""
	ciJoinT9C	:= ""
	cGroupC5M	:= ""
	cWhere		:= ""
	cWhereV48	:= ""
	cLeftV48	:= ""
	cOrder		:= ""
	cCmpQry		:= ""
	cFromC5M	:= ""
	cFromV48	:= ""
	cIJoinC5V	:= ""
	cLJoinV48	:= ""
	cLJoinT9T	:= ""
	cIJoinC5M	:= ""
	cLJoinT9C	:= ""
	aRegApur	:= {}
	lV48		:= AliasIndic('V48')
	lProcid		:= TAFColumnPos("V48_PROCID")

	If lApur
		cSelect	:= " DISTINCT C5M.C5M_FILIAL AS FL, C5M.C5M_ID AS C5MID, C5M.C5M_STATUS AS STATUS, C5M.R_E_C_N_O_ AS C5MRECNO "
		cSelect	+= " , C5M.C5M_DTINI AS DTINI, C5M.C5M_DTFIM AS DTFIM, C5M.C5M_VTOT AS VTOT, C5M.C5M_CODATI AS IDATIV "
		cSelect	+= " , COALESCE(T9TSUM.VLRAJU,0) T9TVLRAJU, COALESCE(V48SUM.BASE,0) V48BASE "
		cSelect += Iif ( lV48, ", ISNULL((C5M.C5M_VATIV - V48SUM.BASE),C5M.C5M_VATIV) AS VLRATIV, C5M.C5M_VEXC AS VEXC " , " , C5M.C5M_VATIV AS VLRATIV, C5M.C5M_VEXC AS VEXC ")
		cSelect	+= " , C5M.C5M_BASE AS BASE, C5M.C5M_ALQCON AS ALQCON "
		cSelect += Iif ( lV48, " , CASE WHEN V48SUM.BASE > 0 OR T9TSUM.VLRAJU > 0 THEN C5M.C5M_ALQCON / 100 * (C5M.C5M_VATIV - (COALESCE(V48SUM.BASE,0) + COALESCE(T9TSUM.VLRAJU,0))) ELSE C5M.C5M_VCON END VCON " , " , C5M.C5M_VCON AS VCON")
		cSelect += " , C5M.C5M_CODCTA AS CODCTA, C5M.C5M_INFCOM AS INFCOM, C5M.C5M_VCPEXS AS VCPEXS "
		cSelect	+= " , C5V.C5V_CODIGO AS CODATIV, C5V.C5V_ALQNCM AS C5VALQNCM, C5V.C5V_DESCRI AS C5VDESCRI "
		cSelect += Iif( lV48 ,", V48.V48_VATIV AS V48VATIV, V48.V48_VCON AS V48VCON, V48.V48_VEXC V48VEXC, V48.V48_ALQCON V48ALQ, T9C.T9C_NRINSC AS T9CNRINSC, V48.R_E_C_N_O_ AS V48RECNO " , "")
	Else 
		cSelect	:= " COUNT(*) TOTAL "
		If lProcid
			cSelect		:= " C5M_FILIAL AS FILIAL, C5M.C5M_VATIV - ISNULL(V48SUM.BASE, 0 ) AS VALOR, C5M_PROCID AS PROCID, "
			cSelect		+= " '' V48FILIAL, 0 V48VATIV, '' V48PROCID, '' NRINSC "
			cSelV48		:= " 	'', 0 ,	'',   V48_FILIAL V48FILIAL, V48_VATIV V48VATIV, V48_PROCID V48PROCID, T9C_NRINSC NRINSC "
			cFromV48	:= RetSqlName("V48") + " V48 "
			cIJoinC5M	:= RetSqlName("C5M") + " C5M ON C5M.C5M_FILIAL = V48.V48_FILIAL "
			cIJoinC5M	+= "AND C5M.C5M_ID = V48.V48_ID "
			cLeftV48	:= " (SELECT SUM(V48_BASE) AS BASE, V48_ID AS ID, V48_FILIAL AS FILIAL "
			cLeftV48	+= " FROM " + RetSqlName("V48") + " V48A WHERE V48A.D_E_L_E_T_=' ' GROUP BY V48_ID, V48_FILIAL) V48SUM "
			cLeftV48	+= " ON V48SUM.ID = C5M.C5M_ID AND V48SUM.FILIAL = C5M.C5M_FILIAL "
			cGroupC5M	:= " C5M_FILIAL, C5M_VATIV, V48SUM.BASE, C5M_PROCID "
			ciJoinT9C	:= RetSqlName("T9C") + " T9C ON V48_IDCNO = T9C_ID AND V48_FILIAL = T9C_FILIAL AND T9C.D_E_L_E_T_='' " 
		EndIf
	EndIf

	cFromC5M	:= RetSqlName("C5M") + " C5M "
	cIJoinC5V	:= RetSqlName("C5V") + " C5V On C5V.D_E_L_E_T_ = ' ' AND "
	
	If lV48
		cLJoinV48	:= RetSqlName("V48") + " V48"
		cLJoinV48	+= " ON C5M.C5M_ID = V48.V48_ID AND C5M.C5M_FILIAL = V48.V48_FILIAL AND V48.D_E_L_E_T_= ' ' "
		
		If lApur
			cLJoinT9T	:= RetSqlName("T9T") + " T9T"
			cLJoinT9T	+= " ON C5M.C5M_ID = T9T.T9T_ID AND C5M.C5M_FILIAL = T9T.T9T_FILIAL AND T9T.D_E_L_E_T_= ' ' "
		EndIf

		cLJoinT9C	:= RetSqlName("T9C") + " T9C"
		cLJoinT9C	+= " ON  V48_IDCNO = T9C.T9C_ID AND T9C.D_E_L_E_T_=' ' "  
		
		cLJoinSUM	:= " ( SELECT SUM(V48_BASE) AS BASE, V48_ID AS ID, V48_FILIAL AS FILIAL "
		cLJoinSUM	+= " FROM "+ RetSqlName("V48") +" V48A WHERE V48A.D_E_L_E_T_=' ' GROUP BY V48_ID, V48_FILIAL) V48SUM ON V48SUM.ID = C5M.C5M_ID "
		cLJoinSUM	+= " AND V48SUM.FILIAL = C5M.C5M_FILIAL	AND V48.D_E_L_E_T_=' ' "

		If lApur
			cLJSUMT9T	:= " ( SELECT SUM(T9T_VLRAJU) AS VLRAJU,T9T_ID AS ID,T9T_FILIAL AS FILIAL"
			cLJSUMT9T	+= " FROM "+ RetSqlName("T9T") +" T9TA WHERE T9TA.D_E_L_E_T_ = ' ' GROUP BY T9T_ID,T9T_FILIAL) T9TSUM ON T9TSUM.ID = C5M.C5M_ID "
			cLJSUMT9T	+= " AND T9TSUM.FILIAL = C5M.C5M_FILIAL AND T9T.D_E_L_E_T_=' '"
		EndIf

		cLJoinV48	:= "%" + cLJoinV48	+ "%"
		cLJoinT9T	:= "%" + cLJoinT9T	+ "%"
		cLJoinT9C	:= "%" + cLJoinT9C	+ "%"
		cLJoinSUM	:= "%" + cLJoinSUM	+ "%"
		
		If lApur
			cLJSUMT9T	:= "%" + cLJSUMT9T	+ "%"
		EndIf

	EndIf

	If cBd $ "ORACLE|POSTGRES|DB2"
		cIJoinC5V += " SUBSTR(C5V.C5V_ID,1,6) = SUBSTR(C5M.C5M_CODATI,1,6) "
	ElseIf cBd $ "INFORMIX"
		cIJoinC5V += " C5V.C5V_ID[1,6] = C5M.C5M_CODATI[1,6] "	
	Else
		cIJoinC5V += " SUBSTRING(C5V.C5V_ID,1,6) = SUBSTRING(C5M.C5M_CODATI,1,6) "
	EndIf

	If lProcid .AND. !lApur
		cWhereV48 := " C5M.C5M_FILIAL IN " + cFiliais + " AND "
	EndIf

	cWhere := " C5M.D_E_L_E_T_ = ' ' AND C5M.C5M_FILIAL IN " + cFiliais + " AND "

	If cBd $ "ORACLE|POSTGRES|DB2"
		cWhere += " SUBSTR(C5M.C5M_DTINI,1,6) = '" + cPerApu + "' AND SUBSTR(C5M.C5M_DTFIM,1,6) = '" + cPerApu + "' "

		If lProcid .AND. !lApur
			cWhereV48 += " SUBSTR(C5M.C5M_DTINI,1,6) = '" + cPerApu + "' AND SUBSTR(C5M.C5M_DTFIM,1,6) = '" + cPerApu + "' "
		EndIf
	
	ElseIf cBd $ "INFORMIX"
		cWhere	+= " C5M.C5M_DTINI[1,6] = '" + cPerApu + "' AND C5M.C5M_DTFIM[1,6] = '" + cPerApu + "' "

		If lProcid .AND. !lApur
			cWhereV48 += " C5M.C5M_DTINI[1,6] = '" + cPerApu + "' AND C5M.C5M_DTFIM[1,6] = '" + cPerApu + "' "
		EndIf
	Else
		cWhere	+= " SUBSTRING(C5M.C5M_DTINI,1,6) = '" + cPerApu + "' AND SUBSTRING(C5M.C5M_DTFIM,1,6) = '" + cPerApu + "' "

		If lProcid .AND. !lApur
			cWhereV48 += " SUBSTRING(C5M.C5M_DTINI,1,6) = '" + cPerApu + "' AND SUBSTRING(C5M.C5M_DTFIM,1,6) = '" + cPerApu + "' "
		EndIf
	EndIf
	
	If !lApur
		If lIdProc
			If lProcid
				cWhereV48 += "  AND C5M.D_E_L_E_T_ = ' ' AND  V48.D_E_L_E_T_ = ' ' "
			Else
				cWhere	+= " AND C5M.C5M_PROCID <> '' "
			EndIf
		Else
			If lProcid
				cWhereV48 += " AND C5M.D_E_L_E_T_ = ' ' AND  V48.D_E_L_E_T_ = ' ' "
			EndIf
			cWhere	+= " AND C5M.C5M_PROCID = ' ' "
		EndIf
	EndiF

	cOrder := " C5M.C5M_FILIAL , C5M.C5M_CODATI "

	If lApur
		cSelect		:= "%" + cSelect	+ "%"
		cFromC5M	:= "%" + cFromC5M	+ "%"
		cIJoinC5V	:= "%" + cIJoinC5V	+ "%"
		cWhere		:= "%" + cWhere		+ "%"
		cOrder		:= "%" + cOrder		+ "%"

		If lV48

			BeginSql Alias cAliasApr
			
				COLUMN DTINI	AS DATE
				COLUMN DTFIM	AS DATE
		
				SELECT
					%Exp:cSelect%
				FROM
					%Exp:cFromC5M%
				INNER JOIN
					%Exp:cIJoinC5V%
				LEFT JOIN
					%Exp:cLJoinV48%
				LEFT JOIN
					%Exp:cLJoinT9T%
				LEFT JOIN
					%Exp:cLJoinT9C%
				LEFT JOIN 
					%Exp:cLJoinSUM%
				LEFT JOIN 
					%Exp:cLJSUMT9T%
				WHERE
					%Exp:cWhere%
				ORDER BY
					%Exp:cOrder%
			EndSql

		aRegApur := RegPrinc( cAliasApr, @aRegApur, cPerApu, cCmpQry, aInfEUF, @aMovs, cKey, cFiliais)

		Else

			BeginSql Alias cAliasApr
			
				COLUMN DTINI	AS DATE
				COLUMN DTFIM	AS DATE
		
				SELECT
					%Exp:cSelect%
				FROM
					%Exp:cFromC5M%
				INNER JOIN
					%Exp:cIJoinC5V%
				WHERE
					%Exp:cWhere%
				ORDER BY
					%Exp:cOrder%
			EndSql

			aRegApur := RegPrinc( cAliasApr, @aRegApur, cPerApu, cCmpQry, aInfEUF, @aMovs)

		EndIf
	Else
		If lProcid
			cQuery	:= cSelect + ' FROM ' + cFromC5M + ' INNER JOIN ' + cIJoinC5V + ' LEFT JOIN ' + cLeftV48 + ' WHERE ' + cWhere + ' GROUP BY ' + cGroupC5M + ' UNION ' 
			cQuery	+= ' SELECT ' + cSelV48 + ' FROM ' + cFromV48 + ' INNER JOIN ' + cIJoinC5M + ' INNER JOIN ' + cIJoinC5V + ' INNER JOIN ' + ciJoinT9C + ' WHERE ' + cWhereV48
			aadd(aRegApur, {cQuery} )
		Else
			cQuery := cSelect + ' FROM ' + cFromC5M + ' INNER JOIN ' + cIJoinC5V + ' WHERE ' + cWhere 
			aadd(aRegApur, {cQuery} )
		EndIf
	EndIf

Return aRegApur

//-------------------------------------------------------------------
/*/{Protheus.doc} RegPrinc
Monta a Tabela Temporária

@author Denis Souza
@since  02/04/2018
@version 1.0
@return Retorna os alias das TTs

/*/ 
//-------------------------------------------------------------------

Static Function RegPrinc( cAlias , aSintetic, cPeriod, cCmpQry, aQtdEUF,aMovs, cKey, cFiliais)

	Local aAreaSM0 		As Array
	Local aCampCabc		As Array
	Local aCmpAtiv		As Array
	Local aCmpCmpt		As Array
	Local aCampProc		As Array
	Local aCmpAjst		As Array
	Local oTTCabc		As Object
	Local oTTAtiv		As Object
	Local oTTCmpt		As Object
	Local oTTProc		As Object
	Local oTTAjst		As Object
	Local cAlsTTCabc	As Character
	Local cAlsTTAtiv	As Character
	Local cAlsTTCmpt	As Character
	Local cAlsTTProc	As Character
	Local cAlsTTAjst	As Character
	Local cChvReg		As Character
	Local cTpInsc		As Character
	Local cNrInsc		As Character
	Local cCompart		As Character
	Local clGrpEmp		As Character
	Local cIdPai		As Character
	Local nContLaco		As Numeric
	Local nPos			As Numeric
	Local nVlrSusp		As Numeric
	Local nVlrAdc 		As Numeric
	Local nVlrExc 		As Numeric
	Local nVlrCmpt		As Numeric
	Local nX			As Numeric
	Local lAvanc		As Logical
	Local lV48			As Logical 
	Local lCNO			As Logical
	Local lProcId		As Logical

	Default cKey := ""
	Default cFiliais := ""
	
	aAreaSM0 	:= SM0->(GetArea())
	aCampCabc	:= {}
	aCmpAtiv	:= {}
	aCmpCmpt	:= {}
	aCampProc	:= {}
	aCmpAjst	:= {}
	oTTCabc		:= Nil
	oTTAtiv		:= Nil
	oTTCmpt		:= Nil
	oTTProc		:= Nil
	oTTAjst		:= Nil
	cAlsTTCabc	:= ""
	cAlsTTAtiv	:= ""
	cAlsTTCmpt	:= ""
	cAlsTTProc	:= ""
	cAlsTTAjst	:= ""	
	cChvReg		:= ""
	cTpInsc		:= ""
	cNrInsc		:= ""
	cCompart	:= ""	
	clGrpEmp	:= cEmpAnt
	cIdPai		:= ""
	nContLaco	:= 1
	nPos 		:= 0
	nVlrSusp	:= 0
	nVlrAdc 	:= 0
	nVlrExc 	:= 0
	nVlrCmpt	:= 0
	nX			:= 0
	lAvanc		:= .T.
	lCNO		:= .F.
	lV48		:= AliasIndic('V48')
	lProcId		:= TAFColumnPos("V48_PROCID")

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())

	If (cAlias)->(!EOF())
		
		cCompart := Upper(AllTrim(FWModeAccess("C1G",1)+FWModeAccess("C1G",2)+FWModeAccess("C1G",3))) // 1=Empresa, 2=Unidade de Negócio e 3=Filial

		cAlsTTCabc	:= GetNextAlias() //CAB		
		cAlsTTAtiv	:= GetNextAlias() //ATIV
		cAlsTTCmpt	:= GetNextAlias() //COMPLEMENTO
		cAlsTTProc	:= GetNextAlias() //PROCESSO
		cAlsTTAjst 	:= GetNextAlias() //AJUSTE

		// Cria a estrutura (array) das temporary table
		PopArray(@aCampCabc, @aCmpAtiv,@aCmpCmpt,@aCampProc,@aCmpAjst,cPeriod)

		// Instancia o objeto Temporary Table
		oTTCabc	:= FWTemporaryTable():New(cAlsTTCabc, aCampCabc)
		oTTAtiv	:= FWTemporaryTable():New(cAlsTTAtiv, aCmpAtiv)
		oTTCmpt	:= FWTemporaryTable():New(cAlsTTCmpt, aCmpCmpt)
		oTTProc	:= FWTemporaryTable():New(cAlsTTProc, aCampProc)			
		oTTAjst	:= FWTemporaryTable():New(cAlsTTAjst, aCmpAjst)

		// Seta os devidos indices 
		PopIdxObj(@oTTCabc,@oTTAtiv,@oTTProc,@oTTAjst,@oTTCmpt,cPeriod)

		//oTTCabc:GetRealName()
		//oTTAtiv:GetRealName()
		//oTTCmpt:GetRealName()
		//oTTProc:GetRealName()
		//oTTAjst:GetRealName()

		DbSelectArea(cAlsTTCabc)
		(cAlsTTCabc)->(DbSetOrder(2)) //"CPERIODO","CTPINSC","CNRINSC"

		DbSelectArea(cAlsTTAtiv)
		(cAlsTTAtiv)->(DbSetOrder(2)) //"CPERIODO","CTPINSC","CNRINSC","IDATIV"

		DbSelectArea(cAlsTTCmpt)
		(cAlsTTCmpt)->(DbSetOrder(2)) //"CHAVE","C5NID"

		DbSelectArea(cAlsTTProc)
		(cAlsTTProc)->(DbSetOrder(2)) //"CHAVE","C1GTPPROC","C1GNUMPRO","CODSUS"

		DbSelectArea(cAlsTTAjst)
		(cAlsTTAjst)->(DbSetOrder(2)) //"CHAVE","DTAJUS","CTPAJST","CCODAJST"
				
		(cAlias)->(DbGoTop())
		While (cAlias)->(!EOF())

			If (lV48 .AND. (cAlias)->(VLRATIV) == 0) .OR. lCNO
				cTpInsc	:= '4'
				cNrInsc	:= (cAlias)->(T9CNRINSC)
				lCNO	:= .F.
			Else 
				cNrInsc	:=	Posicione("SM0", 1, clGrpEmp + (cAlias)->FL, "M0_CGC")
				cTpInsc := Posicione("SM0", 1, clGrpEmp + (cAlias)->FL, "M0_TPINSC")
				If cValToChar(cTpInsc) == "2" .Or. cValToChar(cTpInsc) == "0"
					cTpInsc	:=	'1'		
				Endif
			EndIf

			If (Empty(cKey) .or. cPeriod + cTpInsc + AllTrim(cNrInsc) $ cKey) .AND. lProcId
				If cTpInsc == '4'
					aRet := RetFilId(cNrInsc, cFiliais)
					For nX:=1 to Len(aRet)
						if aScan(aMovs, { |x| x[2] == aRet[nX] .and. x[3] == "V48"}) == 0
							AADD(aMovs,{"CPRB", aRet[nX], "V48" })
						EndIf
					Next
				Else
					AADD(aMovs,{"CPRB", (cAlias)->C5MRECNO, "C5M" })
				EndIf
			ElseIf Empty(cKey)
				AADD(aMovs,{"CPRB", (cAlias)->C5MRECNO, "C5M" })
			EndIf

			If cIDPai != (cAlias)->(C5MID) .AND. (cAlias)->(VLRATIV) == 0 .AND. lV48
				AADD(aMovs,{"CPRB", (cAlias)->C5MRECNO, "C5M" })
			EndIf

			cNrInsc:= SubStr(cNrInsc, 1, 14)

			If nContLaco++ == 1 .Or. cChvReg <> cPeriod + cTpInsc + cNrInsc + Substr( (cAlias)->IDATIV,1,6 )				
				cChvReg := cPeriod + cTpInsc + cNrInsc + Substr( (cAlias)->IDATIV,1,6 )
				nVlrSusp := nVlrExc := nVlrAdc := 0 
			EndIf

			//PROCESSO
			RetProc(cAlsTTProc, cAlias, aCampProc,	cChvReg, (cAlias)->C5MID, (cAlias)->IDATIV, cCompart, aQtdEUF, @nVlrSusp)

			//AJUSTE
			RetAjst(cAlsTTAjst, cAlias, aCmpAjst,	cChvReg, (cAlias)->C5MID, (cAlias)->IDATIV, @nVlrExc, @nVlrAdc)

			If cIDPai != (cAlias)->(C5MID)
				lCNO	:= .F.
				cIDPai	:= (cAlias)->(FL) + (cAlias)->(C5MID)
			EndIf

			If !(cAlsTTAtiv)->(DbSeek( cPeriod + cTpInsc + cNrInsc + Substr( (cAlias)->IDATIV,1,6 )))

				If (cAlias)->(VLRATIV) > 0 .AND. cTpInsc == '1'  //Se estiver zerado, entende que apenas os valores dos filhos (V48) deve ser levado

					RecLock(cAlsTTAtiv,.T.)
						(cAlsTTAtiv)->CHAVE		:= cPeriod + cTpInsc + cNrInsc
						(cAlsTTAtiv)->CPERIODO	:= cPeriod
						(cAlsTTAtiv)->CTPINSC	:= cTpInsc 
						(cAlsTTAtiv)->CNRINSC	:= cNrInsc
						(cAlsTTAtiv)->RECNO 	:= (cAlias)->C5MRECNO					
						(cAlsTTAtiv)->IDATIV	:= (cAlias)->IDATIV
						(cAlsTTAtiv)->CODATIV	:= (cAlias)->CODATIV
						(cAlsTTAtiv)->CDSATIV	:= (cAlias)->C5VDESCRI
						(cAlsTTAtiv)->ALQATIV	:= (cAlias)->ALQCON
						(cAlsTTAtiv)->T9TVEXC	:= nVlrExc
						(cAlsTTAtiv)->T9TVAJU	:= nVlrAdc
						(cAlsTTAtiv)->C5MVATIV	:= (cAlias)->VLRATIV
						(cAlsTTAtiv)->VLRCPRBAP := (cAlias)->VCON					
						(cAlsTTAtiv)->C5MVEXC	:= (cAlias)->VEXC
						(cAlsTTAtiv)->ID		:= (cAlias)->C5MID
						(cAlsTTAtiv)->FILIAL	:= (cAlias)->FL
						if nVlrExc > 0
							(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->VLRATIV + nVlrAdc) - nVlrExc
						else
							(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->VLRATIV + nVlrAdc) - (cAlias)->VEXC 
						endif
					(cAlsTTAtiv)->(MsUnlock())

					If lV48
						lCNO:= Iif( !Empty((cAlias)->(T9CNRINSC)),.T. ,.F. )
					EndIf

				ElseIf cIDPai != (cAlias)->(C5MID) .AND. (cAlias)->(VLRATIV) == 0
					If lV48

						RecLock(cAlsTTAtiv,.T.)
							(cAlsTTAtiv)->CHAVE		:= cPeriod + cTpInsc + cNrInsc
							(cAlsTTAtiv)->CPERIODO	:= cPeriod
							(cAlsTTAtiv)->CTPINSC	:= cTpInsc
							(cAlsTTAtiv)->CNRINSC	:= cNrInsc
							(cAlsTTAtiv)->RECNO 	:= (cAlias)->C5MRECNO					
							(cAlsTTAtiv)->IDATIV	:= (cAlias)->IDATIV
							(cAlsTTAtiv)->CODATIV	:= (cAlias)->CODATIV
							(cAlsTTAtiv)->CDSATIV	:= (cAlias)->C5VDESCRI
							(cAlsTTAtiv)->ALQATIV	:= (cAlias)->V48ALQ
							(cAlsTTAtiv)->T9TVEXC	:= nVlrExc
							(cAlsTTAtiv)->T9TVAJU	:= nVlrAdc
							(cAlsTTAtiv)->C5MVATIV	:= (cAlias)->V48VATIV
							(cAlsTTAtiv)->VLRCPRBAP := (cAlias)->V48VCON					
							(cAlsTTAtiv)->C5MVEXC	:= (cAlias)->V48VEXC
							(cAlsTTAtiv)->ID		:= (cAlias)->C5MID
							(cAlsTTAtiv)->FILIAL	:= (cAlias)->FL
							if nVlrExc > 0
								(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->V48VATIV + nVlrAdc) - nVlrExc
							else
								(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->V48VATIV + nVlrAdc) - (cAlias)->VEXC 
							endif
						(cAlsTTAtiv)->(MsUnlock())
					EndIf
				
				ElseIf cTpInsc == '4' 
					If lV48
						RecLock(cAlsTTAtiv,.T.)
							(cAlsTTAtiv)->CHAVE		:= cPeriod + cTpInsc + cNrInsc
							(cAlsTTAtiv)->CPERIODO	:= cPeriod
							(cAlsTTAtiv)->CTPINSC	:= cTpInsc
							(cAlsTTAtiv)->CNRINSC	:= cNrInsc
							(cAlsTTAtiv)->RECNO 	:= (cAlias)->C5MRECNO					
							(cAlsTTAtiv)->IDATIV	:= (cAlias)->IDATIV
							(cAlsTTAtiv)->CODATIV	:= (cAlias)->CODATIV
							(cAlsTTAtiv)->CDSATIV	:= (cAlias)->C5VDESCRI
							(cAlsTTAtiv)->ALQATIV	:= (cAlias)->ALQCON
							(cAlsTTAtiv)->T9TVEXC	:= nVlrExc
							(cAlsTTAtiv)->T9TVAJU	:= nVlrAdc
							(cAlsTTAtiv)->C5MVATIV	:= (cAlias)->V48VATIV
							(cAlsTTAtiv)->VLRCPRBAP := (cAlias)->V48VCON					
							(cAlsTTAtiv)->C5MVEXC	:= (cAlias)->VEXC
							(cAlsTTAtiv)->ID		:= (cAlias)->C5MID
							(cAlsTTAtiv)->FILIAL	:= (cAlias)->FL
							if nVlrExc > 0
								(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->V48VATIV + nVlrAdc) - nVlrExc
							else
								(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->V48VATIV + nVlrAdc) - (cAlias)->VEXC 
							endif
						(cAlsTTAtiv)->(MsUnlock())
					EndIf
				EndIf

			Else

				If cTpInsc == "1" 
					RecLock(cAlsTTAtiv,.F.)
						(cAlsTTAtiv)->T9TVEXC	+= nVlrExc
						(cAlsTTAtiv)->T9TVAJU	+= nVlrAdc
						(cAlsTTAtiv)->C5MVATIV	+= (cAlias)->VLRATIV
						(cAlsTTAtiv)->VLRCPRBAP += (cAlias)->VCON
						(cAlsTTAtiv)->C5MVEXC	+= (cAlias)->VEXC
						if nVlrExc > 0
							(cAlsTTAtiv)->VBCCPRB 	+= ((cAlias)->VLRATIV + nVlrAdc) - nVlrExc
						else
							(cAlsTTAtiv)->VBCCPRB 	+= ((cAlias)->VLRATIV + nVlrAdc) - (cAlias)->VEXC
						endif
					(cAlsTTAtiv)->(MsUnlock())

					If lV48
						lCNO:= Iif( !Empty((cAlias)->(T9CNRINSC)),.T. ,.F. )
					EndIf
				Else

					RecLock(cAlsTTAtiv,.F.)
						(cAlsTTAtiv)->T9TVEXC	+= nVlrExc
						(cAlsTTAtiv)->T9TVAJU	+= nVlrAdc
						(cAlsTTAtiv)->C5MVATIV	+= (cAlias)->V48VATIV
						(cAlsTTAtiv)->VLRCPRBAP += (cAlias)->V48VCON
						(cAlsTTAtiv)->C5MVEXC	+= (cAlias)->V48VEXC

						if nVlrExc > 0
							(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->V48VATIV + nVlrAdc) - nVlrExc
						else
							(cAlsTTAtiv)->VBCCPRB 	:= ((cAlias)->V48VATIV + nVlrAdc) - (cAlias)->VEXC 
						endif
					(cAlsTTAtiv)->(MsUnlock())
				EndIf
			EndIf

			//CABEÇALHO
			If !(cAlsTTCabc)->(DbSeek(cPeriod + cTpInsc + cNrInsc))
				If cTpInsc == '1' .AND. (cAlias)->(VLRATIV) > 0
					RecLock(cAlsTTCabc,.T.)
						(cAlsTTCabc)->CHAVE		:= cPeriod + cTpInsc + cNrInsc
						(cAlsTTCabc)->CPERIODO	:= cPeriod
						(cAlsTTCabc)->CTPINSC 	:= cTpInsc
						(cAlsTTCabc)->CNRINSC	:= cNrInsc
						(cAlsTTCabc)->VLRECBTT	:= (cAlias)->VLRATIV
						(cAlsTTCabc)->VLCPAPUT	:= (cAlias)->VCON
						(cAlsTTCabc)->VLCSUSPT	:= nVlrSusp
						(cAlsTTCabc)->ID		:= (cAlias)->C5MID
						(cAlsTTCabc)->FILIAL	:= (cAlias)->FL
					(cAlsTTCabc)->(MsUnlock())
				Else
					If lV48
						RecLock(cAlsTTCabc,.T.)
							(cAlsTTCabc)->CHAVE		:= cPeriod + cTpInsc + cNrInsc
							(cAlsTTCabc)->CPERIODO	:= cPeriod
							(cAlsTTCabc)->CTPINSC 	:= cTpInsc
							(cAlsTTCabc)->CNRINSC	:= cNrInsc
							(cAlsTTCabc)->VLRECBTT	:= (cAlias)->V48VATIV
							(cAlsTTCabc)->VLCPAPUT	:= (cAlias)->V48VCON
							(cAlsTTCabc)->VLCSUSPT	:= nVlrSusp
							(cAlsTTCabc)->ID		:= (cAlias)->C5MID
							(cAlsTTCabc)->FILIAL	:= (cAlias)->FL
						(cAlsTTCabc)->(MsUnlock())
						lCNO	:= .F.
					EndIf
				EndIf
			Else
				RecLock(cAlsTTCabc,.F.)
				If cTpInsc == '1'
					(cAlsTTCabc)->VLRECBTT	+= (cAlias)->VLRATIV
					(cAlsTTCabc)->VLCPAPUT	+= (cAlias)->VCON
					(cAlsTTCabc)->VLCSUSPT	+= nVlrSusp
				Else
					If lV48
						(cAlsTTCabc)->VLRECBTT	+= (cAlias)->V48VATIV
						(cAlsTTCabc)->VLCPAPUT	+= (cAlias)->V48VCON
						(cAlsTTCabc)->VLCSUSPT	+= nVlrSusp
						lCNO	:= .F.
					EndIf
				EndIf
				(cAlsTTCabc)->(MsUnlock())
			EndIf

			Iif(lCNO, , (cAlias)->(DbSkip()))//Identificou que aquela linha do pai possui um filho então não deve dar DbSkip()
		EndDo
	Else
		lAvanc := .F.
	EndIf
	(cAlias)->(DbCloseArea())
	
	RestArea(aAreaSM0)

Return	{	{cAlsTTCabc	,oTTCabc},;
 			{cAlsTTAtiv	,oTTAtiv},;
 			{cAlsTTCmpt	,oTTCmpt},; 			
 			{cAlsTTProc	,oTTProc},;
 			{cAlsTTAjst	,oTTAjst},; 			
 			lAvanc }

//-------------------------------------------------------------------
/*/{Protheus.doc} RetAjst

@author Denis Souza
@since  02/04/2018
@version 1.0
@return Nil

/*/ 
//-------------------------------------------------------------------

Static Function RetAjst(cAlsTTAjst, Alias, aCampProc, cChavAjst, cC5MId, cIdAtiv, nVlrExc, nVlrAdc)

	Local cSelect	AS Character
	Local cFrom		AS Character
	Local cWhere	AS Character
	Local cAliasT9T	AS Character
	Local cChavSeek	AS Character
	Local nTmAtiv   AS Numeric

	cSelect		:= ''
	cFrom		:= ''
	cWhere		:= ''
	cChavSeek	:= ''
	cAliasT9T	:= GetNextAlias()
	nTmAtiv		:= TamSX3("C5M_CODATI")[1]

	cSelect 	:= "'" + cChavAjst + "' AS CHAVE, T9T.T9T_TPAJUS AS TPAJUS, T9T.T9T_CODAJU AS CODAJU, T9T.T9T_VLRAJU AS VLRAJU, T9T.T9T_DESCAJ AS DESCAJ, T9T.T9T_DTAJUS AS DTAJUS, T9T.T9T_CODSEQ AS CODSEQ "
	cFrom		:= RetSqlName("T9T") + " T9T "
	cWhere 		:= " T9T.T9T_FILIAL = '" + (Alias)->FL + "' AND T9T.D_E_L_E_T_ = ' ' AND T9T.T9T_ID = '" + (Alias)->C5MID +  "' "

	//cSelect := 'SELECT ' + cSelect + ' FROM ' + cFrom + ' Where ' + cWhere
	
	cSelect 	:= "%" +	cSelect 	+ 	"%"
	cFrom		:= "%" +	cFrom	 	+ 	"%"	
	cWhere 		:= "%" +	cWhere 		+ 	"%"
	
	BeginSql Alias cAliasT9T
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		Where
			%Exp:cWhere%
	EndSql
	(cAliasT9T)->(DbGoTop())	

	If !(cAliasT9T)->(EOF())
		While !(cAliasT9T)->(EOF())
			cChavSeek := PADR((cAliasT9T)->CHAVE, 21 + nTmAtiv) + (cAliasT9T)->DTAJUS + (cAliasT9T)->TPAJUS + (cAliasT9T)->CODAJU
			If !(cAlsTTAjst)->(MsSeek(cChavSeek))
				RecLock(cAlsTTAjst, .T.)
					(cAlsTTAjst)->CHAVE		:= (cAliasT9T)->CHAVE
					(cAlsTTAjst)->DTAJUS	:= (cAliasT9T)->DTAJUS
					(cAlsTTAjst)->IDATIV	:= cIdAtiv
					(cAlsTTAjst)->CTPAJST	:= (cAliasT9T)->TPAJUS
					(cAlsTTAjst)->CCODAJST	:= (cAliasT9T)->CODAJU
					(cAlsTTAjst)->VLRAJST	:= (cAliasT9T)->VLRAJU
					(cAlsTTAjst)->DSCAJST	:= (cAliasT9T)->DESCAJ
				(cAlsTTAjst)->(MsUnlock())
			Else
				RecLock(cAlsTTAjst, .F.)
					(cAlsTTAjst)->VLRAJST += (cAliasT9T)->VLRAJU
				(cAlsTTAjst)->(MsUnlock())
			EndIf

			If (cAliasT9T)->TPAJUS == "0"
				nVlrExc += (cAliasT9T)->VLRAJU
			ElseIf (cAliasT9T)->TPAJUS == "1"
				nVlrAdc += (cAliasT9T)->VLRAJU	
			Endif

			(cAliasT9T)->(DbSkip())
		EndDo
	EndIf
	(cAliasT9T)->(DbCloseArea())

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RetProc

@author Denis Souza
@since  02/04/2018
@version 1.0
@return Nil

/*/
//-------------------------------------------------------------------

Static Function RetProc(cAlsTTProc, Alias, aCampProc, cChavProc, cIdCPRB, cIdAtiv, cCompC1G, aSM0EUF, nVlrSusp)
	
	Local aRet			As Array
	Local cSelect		AS Character
	Local cFrom			AS Character	
	Local cJoinC1G		AS Character
	Local cJoinT5L		AS Character	
	Local cWhere		AS Character
	Local cOrder 		As Character
	Local cChave		AS Character
	Local cAliasC5O		AS Character
	Local cChavSeek		AS Character
	Local cFilC1G		AS Character
	Local cBd			As Character
	Local nTam			As Numeric
	Local nTamIDSUSP	As Numeric
	Local lFormat		As Logical
	Local lProcessa		As Logical
	
	
	aRet		:= {}
	cSelect		:= ''
	cFrom		:= ''	
	cJoinC1G	:= ''
	cJoinT5L	:= ''
	cWhere		:= ''
	cOrder		:= ''
	cChave		:= ''
	cAliasC5O	:= GetNextAlias()
	cChavSeek	:= ''
	cFilC1G		:= xFilial("C1G")	
	cBd			:= TcGetDb()
	nTam		:= 0
	nTamIDSUSP	:= 0
	lFormat		:= .F.
	lProcessa	:= .F.

	cSelect 	:= "'" + cChavProc + "' AS CHAVE, C5O.C5O_FILIAL AS C5OFILIAL, C5O.C5O_NUMPRO AS NUMPRO, C5O.C5O_IDSUSP AS IDSUSP, T5L.T5L_CODSUS AS CODSUS, C5O.C5O_VLEXSU AS VALSUS "
	cSelect 	+= " , C1G.C1G_TPPROC AS C1GTPPROC, C1G.C1G_NUMPRO AS C1GNUMPRO, C1G.C1G_ID AS C1GID, C1G.C1G_VERSAO AS C1GVERSAO, C1G.C1G_FILIAL AS C1GFILIAL "
	
	cFrom		:= RetSqlName("C5O") + " C5O "
	
	cJoinC1G	:=  RetSqlName("C1G") + " C1G ON "
	
	If cCompC1G == 'EEE'
		cJoinC1G += " C1G.C1G_FILIAL = C5O.C5O_FILIAL AND "	 
	Else
		If cCompC1G == 'EEC'
			nTam := aSM0EUF[DEFEMP] + aSM0EUF[DEFUND]
			nTam += iif(nTam == 0, aSM0EUF[DEFFIL], 0)
			lFormat := .T.
		ElseIf cCompC1G == 'ECC'
			nTam := aSM0EUF[DEFEMP]
			nTam += iif(nTam == 0, aSM0EUF[DEFFIL], 0)
			lFormat := .T.
		EndIf
		if lFormat
			If cBd $ "ORACLE|POSTGRES|DB2"
				cJoinC1G += " C1G.C1G_FILIAL = SUBSTR(C5O.C5O_FILIAL,1," + cValToChar(nTam) + " ) AND "
			ElseIf cBd $ "INFORMIX"
				cJoinC1G += " C1G.C1G_FILIAL = C5O.C5O_FILIAL[1," + cValToChar(nTam) + "] AND "
			Else //MSSQL,MYSQL,PROGRESS
				cJoinC1G += " C1G.C1G_FILIAL = SUBSTRING(C5O.C5O_FILIAL,1," + cValToChar(nTam) + " ) AND "
			EndIf
		EndIf		
	EndIf
	
	cJoinC1G += " C1G.D_E_L_E_T_ = ' ' AND C1G.C1G_ID = C5O.C5O_NUMPRO "
	
	If cBd $ "ORACLE|POSTGRES|DB2|INFORMIX"
		if  cBd $ "POSTGRES"
			nTamIDSUSP	:= TamSX3("C5O_IDSUSP")[1]
			cJoinT5L :=  RetSqlName("T5L") + " T5L ON SUBSTR(T5L_ID || T5L_VERSAO || T5L_CODSUS,1,"+cValToChar(nTamIDSUSP)+") = C5O.C5O_IDSUSP AND "
		Else
			cJoinT5L :=  RetSqlName("T5L") + " T5L ON T5L_ID || T5L_VERSAO || T5L_CODSUS = C5O.C5O_IDSUSP AND "
		Endif
	Else
		cJoinT5L :=  RetSqlName("T5L") + " T5L ON T5L_ID + T5L_VERSAO + T5L_CODSUS = C5O.C5O_IDSUSP AND "
	EndIf
	cJoinT5L += " T5L.D_E_L_E_T_ = ' ' AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "

	cWhere := " C5O.C5O_FILIAL = '" + (Alias)->FL + "' AND C5O.D_E_L_E_T_ = ' ' AND C5O.C5O_ID = '" + (Alias)->C5MID +  "' "

	cOrder := " C5O.C5O_FILIAL, C5O.C5O_NUMPRO, C5O.C5O_IDSUSP "
	
	//cSelect := 'SELECT ' + cSelect + ' FROM ' + cFrom + ' INNER JOIN ' + cJoinC1G + ' INNER JOIN ' + cJoinT5L + ' Where ' + cWhere
	
	cSelect 	:= "%" +	cSelect 	+ 	"%"
	cFrom		:= "%" +	cFrom	 	+ 	"%"
	cJoinC1G	:= "%" +	cJoinC1G	+ 	"%"
	cJoinT5L 	:= "%" +	cJoinT5L 	+ 	"%"
	cWhere 		:= "%" +	cWhere 		+ 	"%"
	cOrder		:= "%" +	cOrder 		+ 	"%"

	BeginSql Alias cAliasC5O
		SELECT
			%Exp:cSelect%
		FROM
			%Exp:cFrom%
		INNER JOIN
			%Exp:cJoinC1G%
		INNER JOIN
			%Exp:cJoinT5L%
		WHERE
			%Exp:cWhere%
		ORDER BY
			%Exp:cOrder%
	EndSql
	
	nVlrSusp := 0
	If !(cAliasC5O)->(EOF())
		While !(cAliasC5O)->(EOF())
			cChavSeek := (cAliasC5O)->CHAVE + Iif( (cAliasC5O)->C1GTPPROC == "1", "2", "1") + (cAliasC5O)->C1GNUMPRO + (cAliasC5O)->CODSUS
			If !(cAlsTTProc)->(MsSeek(cChavSeek))
				RecLock(cAlsTTProc, .T.)
				(cAlsTTProc)->CHAVE		:= (cAliasC5O)->CHAVE
				(cAlsTTProc)->IDATIV	:= cIdAtiv
				(cAlsTTProc)->C1GTPPROC	:= Iif( (cAliasC5O)->C1GTPPROC == "1", "2", "1") 
				(cAlsTTProc)->C1GNUMPRO	:= (cAliasC5O)->C1GNUMPRO
				(cAlsTTProc)->IDSUSP	:= (cAliasC5O)->IDSUSP
				(cAlsTTProc)->CODSUS	:= (cAliasC5O)->CODSUS
				(cAlsTTProc)->NUMPRO	:= (cAliasC5O)->NUMPRO				
				(cAlsTTProc)->VALSUS	:= (cAliasC5O)->VALSUS				
				(cAlsTTProc)->C1GID		:= (cAliasC5O)->C1GID
				(cAlsTTProc)->C1GVERSAO	:= (cAliasC5O)->C1GVERSAO
				(cAlsTTProc)->C1GFILIAL	:= (cAliasC5O)->C1GFILIAL
				(cAlsTTProc)->(MsUnlock())
			Else
				RecLock(cAlsTTProc, .F.)
				(cAlsTTProc)->VALSUS 	+= (cAliasC5O)->VALSUS
				(cAlsTTProc)->(MsUnlock())
			EndIf
			nVlrSusp += (cAliasC5O)->VALSUS
			(cAliasC5O)->(DbSkip())
		EndDo
	EndIf
	(cAliasC5O)->(DbCloseArea())

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava2060
Efetua gravação no modelo da tabela espelho do evento R-2060 (CPRB)

@author Denis Souza
@since  02/04/2018
@version 1.0
@return Retorna se a transação é válida

/*/ 
//-------------------------------------------------------------------

Static Function Grava2060(nOpc, cPerApu, aApuracao, aInfoC1E,  cVerAnt, cProTpn, cIdApReinf, aErro, cIdV0S, lValid, cStatus )

	Local cId 			As Character
	Local cAtiv			As Character
	Local cEvento		As Character
	Local cChaveReg		As Character
	Local cTipo 		As Character
	Local cFilT9V	    As Character
	Local lVldData		As Logical
	Local lVldProc		As Logical
	Local lRollBack		As Logical
	Local nContLaco		As Numeric
	Local nContV0U 	 	As Numeric
	Local nContV0V  	As Numeric
	Local nContV0T		As Numeric
	Local nErro			As Numeric
	Local nAdic			As Numeric
	Local nExcl			As Numeric
	Local nBase			As Numeric	
	Local nSomaCPRB		As Numeric
	Local oModel		As Object
	Local oModelV0S		As Object
	Local oModelV0T		As Object
	Local oModelV0U		As Object
	Local oModelV0V		As Object	
	Local aListErro		As Array
	Local aProcErro		As Array

	Default	cVerAnt	:= ''
	Default cProTpn	:= ''
	Default cId		:= ''

	cId			:= ""
	cAtiv		:= ""
	cEvento		:= "I"
	cChaveReg	:= ""
	cTipo		:= ""
	cFilT9V	    := ""
	lVldData	:= .T.
	lVldProc	:= .T.
	lRollBack	:= .T.
	nContLaco	:= 1 
	nContV0U	:= 1
	nContV0V	:= 1
	nContV0T	:= 1
	nErro		:= 0
	nAdic		:= 0
	nExcl		:= 0
	nBase		:= 0
	nSomaCPRB 	:= 0 		
	oModel		:= Nil
	oModelV0S	:= Nil
	oModelV0T	:= Nil
	oModelV0U	:= Nil
	oModelV0V	:= Nil
	aListErro	:= {}
	aProcErro 	:= {}

	T9V->(DbSetOrder(1))

	(aApuracao[ATIVIDADE])->(DbSetOrder(1)) //CHAVE
	(aApuracao[ATIVIDADE])->(DbGoTop())

	(aApuracao[PROCESSOS])->(DbSetOrder(1)) //CHAVE
	(aApuracao[PROCESSOS])->(DbGoTop())

	(aApuracao[AJUSTE])->(DbSetOrder(1)) 	//CHAVE
	(aApuracao[AJUSTE])->(DbGoTop())

	oModel 		:= FWLoadModel("TAFA499")
	oModelV0S 	:= oModel:GetModel("MODEL_V0S")
	oModelV0T 	:= oModel:GetModel("MODEL_V0T")
	oModelV0U 	:= oModel:GetModel("MODEL_V0U")
	oModelV0V 	:= oModel:GetModel("MODEL_V0V")
		
	oModel:SetOperation(nOpc)
	oModel:Activate()

	If !Empty(cVerAnt)
		oModel:LoadValue('MODEL_V0S', 'V0S_VERANT'	, cVerAnt)
		oModel:LoadValue('MODEL_V0S', 'V0S_PROTPN'	, cProTpn)
		oModel:LoadValue('MODEL_V0S', 'V0S_ID'		, cIdV0S)
		// Excluido deve gerar uma inclusão
		If cStatus == "7"
			cEvento := 'I'		
		Else
			cEvento := 'A'
		EndIf
	EndIf

	oModel:LoadValue('MODEL_V0S', 'V0S_PERAPU'	, cPerApu) //MMAAAA 042018 
	oModel:LoadValue('MODEL_V0S', 'V0S_EVENTO'	, cEvento)
	oModel:LoadValue('MODEL_V0S', 'V0S_VERSAO'  , xFunGetVer())
	oModel:LoadValue('MODEL_V0S', 'V0S_TPINSC'	, (aApuracao[SINTETICO])->CTPINSC)
	oModel:LoadValue('MODEL_V0S', 'V0S_NRINSC'	, (aApuracao[SINTETICO])->CNRINSC)
	oModel:LoadValue('MODEL_V0S', 'V0S_VLRBRT'	, (aApuracao[SINTETICO])->VLRECBTT)
	oModel:LoadValue('MODEL_V0S', 'V0S_VLCPAP'	, (aApuracao[SINTETICO])->VLCPAPUT)
	oModel:LoadValue('MODEL_V0S', 'V0S_VLSCPR'	, (aApuracao[SINTETICO])->VLCSUSPT)

	If !oModelV0S:VldData()
		lVldData := .F.
	EndIf

	//ATIVIDADE
	If (aApuracao[ATIVIDADE])->(DbSeek((aApuracao[SINTETICO])->CHAVE))

		cFilT9V := xFilial("T9V") 

		While !(aApuracao[ATIVIDADE])->(Eof()) .And. (aApuracao[SINTETICO])->CHAVE == (aApuracao[ATIVIDADE])->CHAVE

			nContV0U := nContV0V := 1
			nAdic := nExcl := nBase := 0

			If nContLaco++ > 1 .And. (!oModelV0T:VldData())
				lVldData := .F.
			EndIf

			If nContV0T++ == 1 .Or. cId + cAtiv <> (aApuracao[ATIVIDADE])->CHAVE + (aApuracao[ATIVIDADE])->IDATIV
				cId 	:= (aApuracao[ATIVIDADE])->CHAVE
				cAtiv 	:= (aApuracao[ATIVIDADE])->IDATIV
				
				if nOpc == MODEL_OPERATION_INSERT 
					oModelV0T:AddLine()
				endif

				oModel:LoadValue('MODEL_V0T','V0T_IDATIV', SubStr(AllTrim((aApuracao[ATIVIDADE])->IDATIV),1,6))
				oModel:LoadValue('MODEL_V0T','V0T_CDATIV', (aApuracao[ATIVIDADE])->CODATIV)					
				oModel:LoadValue('MODEL_V0T','V0T_DESATV', (aApuracao[ATIVIDADE])->CDSATIV)
				oModel:LoadValue('MODEL_V0T','V0T_ALQCON', (aApuracao[ATIVIDADE])->ALQATIV)
				oModel:LoadValue('MODEL_V0T','V0T_VLBTAT', (aApuracao[ATIVIDADE])->C5MVATIV)

					//AJUSTE
					If lVldData
						If (aApuracao[AJUSTE])->(DbSeek((aApuracao[ATIVIDADE])->CHAVE+(aApuracao[ATIVIDADE])->IDATIV))
							While !(aApuracao[AJUSTE])->(Eof()) .And. ((aApuracao[AJUSTE])->CHAVE == (aApuracao[ATIVIDADE])->CHAVE + (aApuracao[ATIVIDADE])->IDATIV)
								if ++nContV0U > 2 .And. nOpc == MODEL_OPERATION_INSERT
									oModelV0U:AddLine()
								endif
								If nContV0U > 1 .And. (!oModelV0U:VldData())
									lVldData := .F.
								EndIf
								
								if (aApuracao[AJUSTE])->CTPAJST == "0"
									nExcl += (aApuracao[AJUSTE])->VLRAJST
								else
									nAdic += (aApuracao[AJUSTE])->VLRAJST
								endif
								oModel:LoadValue('MODEL_V0U','V0U_IDATIV', SubStr(AllTrim((aApuracao[AJUSTE])->IDATIV),1,6))
								oModel:LoadValue('MODEL_V0U','V0U_DTAJUS',  (aApuracao[AJUSTE])->DTAJUS)
								oModel:LoadValue('MODEL_V0U','V0U_TPAJUS', (aApuracao[AJUSTE])->CTPAJST)
								oModel:LoadValue('MODEL_V0U','V0U_CODAJU', (aApuracao[AJUSTE])->CCODAJST)
								oModel:LoadValue('MODEL_V0U','V0U_VLRAJU', (aApuracao[AJUSTE])->VLRAJST)
								oModel:LoadValue('MODEL_V0U','V0U_DESAJU', (aApuracao[AJUSTE])->DSCAJST)
								(aApuracao[AJUSTE])->(DbSkip())
							EndDo
						EndIf
					EndIf

				oModel:LoadValue('MODEL_V0T','V0T_VLARBT', nAdic )

				if nExcl > 0
					oModel:LoadValue('MODEL_V0T','V0T_VLERBT', nExcl )				
					nBase += ((aApuracao[ATIVIDADE])->C5MVATIV + nAdic) - nExcl
				else
					oModel:LoadValue('MODEL_V0T','V0T_VLERBT', (aApuracao[ATIVIDADE])->C5MVEXC )
					nBase += ((aApuracao[ATIVIDADE])->C5MVATIV + nAdic) - (aApuracao[ATIVIDADE])->C5MVEXC
				endif
				oModel:LoadValue('MODEL_V0T','V0T_VLBCPR', nBase )
				oModel:LoadValue('MODEL_V0T','V0T_CPRBAP', Round(((aApuracao[ATIVIDADE])->ALQATIV / 100) * nBase, 2))

				nSomaCPRB += Round(((aApuracao[ATIVIDADE])->ALQATIV / 100) * nBase, 2)

				//PROCESSO
				If lVldData .And. lVldProc
					if (aApuracao[PROCESSOS])->(DbSeek((aApuracao[ATIVIDADE])->CHAVE+(aApuracao[ATIVIDADE])->IDATIV))
						While !(aApuracao[PROCESSOS])->(Eof()) .And. (aApuracao[PROCESSOS])->CHAVE == (aApuracao[ATIVIDADE])->CHAVE + (aApuracao[ATIVIDADE])->IDATIV
							if ++nContV0V > 2 .And. nOpc == MODEL_OPERATION_INSERT
								oModelV0V:AddLine()
							endif
							If nContV0V > 1 .And. (!oModelV0V:VldData())
								lVldData := .F.
							EndIf
							oModel:LoadValue('MODEL_V0V','V0V_IDPROC', (aApuracao[PROCESSOS])->NUMPRO)
							oModel:LoadValue('MODEL_V0V','V0V_TPPROC', (aApuracao[PROCESSOS])->C1GTPPROC)
							oModel:LoadValue('MODEL_V0V','V0V_NRPROC', (aApuracao[PROCESSOS])->C1GNUMPRO)
							oModel:LoadValue('MODEL_V0V','V0V_CODSUS', (aApuracao[PROCESSOS])->CODSUS)
							oModel:LoadValue('MODEL_V0V','V0V_IDSUSP', (aApuracao[PROCESSOS])->IDSUSP)
							oModel:LoadValue('MODEL_V0V','V0V_VALSUS', (aApuracao[PROCESSOS])->VALSUS)

							//Verifica Processo
							T9V->(DbSetOrder(5)) //cFIlAnt, T9V_ID, T9V_ATIVO
							If !T9V->(DbSeek( cFilT9V + (aApuracao[PROCESSOS])->C1GID + "1" ))
								lVldProc := .F.
								Aadd(aProcErro,{Nil ,Alltrim((aApuracao[PROCESSOS])->C1GNUMPRO), NIl, oModel:GetErrorMessage() } )
							EndIf
							(aApuracao[PROCESSOS])->(DbSkip())
						EndDo
					EndIf
				EndIf
			EndIf
			(aApuracao[ATIVIDADE])->(DbSkip())
		EndDo
	EndIf

	//Atualiza valor total da CPRB conforme valores calculados
	oModel:LoadValue('MODEL_V0S', 'V0S_VLCPAP', nSomaCPRB)

	If lVldData .And. oModel:VldData() .And. lVldProc
		FwFormCommit(oModel)
		TafEndGRV( "V0S","V0S_PROCID", cIdApReinf, V0S->(Recno()), "R2060")
		TafXLog( cIdApReinf, "R-2060", "MSG", "Registro Gravado com sucesso." + CRLF + (aApuracao[SINTETICO])->CTPINSC + '|' + (aApuracao[SINTETICO])->CNRINSC )
	    lRollBack := .T.
	Else
		cErro := "Inconsistência na gravação do registro contendo a chave: " + CRLF
		cErro += "tpInsc: " + (aApuracao[SINTETICO])->CTPINSC + CRLF
		cErro += "nrInsc: " + (aApuracao[SINTETICO])->CNRINSC + CRLF

		If !lVldProc
			For nErro := 1 to Len(aProcErro)
				cErro	+= '----------------------------------------------' + CRLF
				cErro	+= "Existe o seguinte impedimento: " + CRLF
				cErro	+= "Processo número " + Alltrim(aProcErro[nErro][2]) + " não localizado na tabela de apurações do evento R-1070. Regra de predecessão não atendida."  + CRLF				
			Next nErro	
		EndIf
		cErro  	+= "Detalhes do Erro: " + CRLF + CRLF //"Detalhes do Erro: "
		cErro 	+= TafRetEMsg(oModel)		
		Aadd(aErro, {"R-2060", "ERRO", cErro})
		lRollBack := .F.
	EndIf

Return lRollBack

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaId()


@author Denis Souza
@since  02/04/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function GravaId(aMovs, cIdApur)

	Local nX As numeric

	Default aMovs 	:= {}
	Default cIdApur	:= ''

	For nX := 1 to Len(aMovs)
		TafEndGRV( aMovs[nX][3], aMovs[nX][3]+"_PROCID", cIdApur, aMovs[nX][2], "R2060"  )
	Next nX

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopArray()
Popula as estrutas das 3 temporary tables utilisadas na apuração 

@author Denis Souza
@since  02/04/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static function PopArray(aCampCabc,aCmpAtiv,aCmpCmpt,aCampProc,aCampAjst,cPeriodo)

	Local nTmAtiv	As Numeric
	Local nTmC1GFl 	As Numeric
	Local nTmIdSus	As Numeric

	nTmAtiv		:= TamSX3("C5M_CODATI")[1]
	nTmC1GFl	:= TamSx3("C1G_FILIAL")[1]
	nTmIdSus	:= TamSx3("C5O_IDSUSP")[1]

	//T082 - CPRB - LEGADO C5M - ESPELHO V0S
	aCampCabc := {	{'CHAVE'	,'C', 21 				,0} ,;	//CPERIODO+CTPINSC+CNRINSC
					{'CPERIODO'	,'C', 06 				,0} ,;
					{'CTPINSC'	,'C', 01 				,0} ,;	//CTPINSC
					{'CNRINSC'	,'C', 14 				,0} ,;	//CNRINSC
					{'VLRECBTT'	,'N', 14 				,2} ,;	//vlrRecBrutaTotal
					{'VLCPAPUT'	,'N', 14 				,2} ,;	//vlrCPApurTotal
					{'VLCSUSPT'	,'N', 14 				,2} ,;	//vlrCPRBSuspTotal
					{'ID'		,'C', 06				,0} ,; 	//ID				
					{'FILIAL'	,'C',nTmC1GFl			,0}	}	//FILIAL

	aCmpAtiv  := {	{'CHAVE'	,'C', 21 				,0}	,; 	//CPERIODO+CTPINSC+CNRINSC
					{'CPERIODO'	,'C', 06 				,0}	,;
					{'CTPINSC'	,'C', 01 				,0}	,; 	//CTPINSC
					{'CNRINSC'	,'C', 14 				,0}	,; 	//CNRINSC
					{'IDATIV'	,'C', nTmAtiv			,0}	,;	//IdAtiv
					{'CODATIV'	,'C', 08 				,0}	,;	//CodAtiv
					{'CDSATIV'	,'C', 220 				,0}	,;	//DscAtiv
					{'ALQATIV'	,'N', 08 				,4}	,;	//AliqCodAtiv					
					{'C5MVATIV'	,'N', 14 				,2}	,;	//vlrRecBrutaAtiv
					{'C5MVEXC'	,'N', 14 				,2}	,; 	//vlrExcRecBruta
					{'T9TVEXC'	,'N', 14 				,2}	,; 	//vlrExcRecBruta
					{'T9TVAJU'	,'N', 14 				,2}	,; 	//vlrAdicRecBruta					
					{'VBCCPRB'	,'N', 14 				,2}	,; 	//vlrBcCPRB (vlrRecBrutaAtiv + vlrAdicRecBruta ) - vlrExcRecBruta 
					{'VLRCPRBAP','N', 14 				,2}	,; 	//
					{'ID'		,'C', 06				,0} ,; 	//ID				
					{'FILIAL'	,'C',nTmC1GFl			,0}	,;	//FILIAL
				 	{'RECNO'	,'N', 10 				,0} }	//RECNO

    //T082AA - COMPLEMENTO - LEGADO C5N - ESPELHO V0T 
	aCmpCmpt := {	{'CHAVE'	,'C', (21 + nTmAtiv)	,0}	,; //Period(6) + tpInsc(1) + nrInsc(14) + IdAtiv(10)
					{'C5NID'	,'C', 06 				,0}	,;
					{'IDATIV'	,'C', nTmAtiv			,0}	,;
					{'DETVAL'	,'N', 14 				,2}	}
    
    //T082AB - PROCESSO - LEGADO C5O - ESPELHO V0V  
	aCampProc := {	{'CHAVE'	,'C', (21 + nTmAtiv)	,0}	,;	//Period(6) + tpInsc(1) + nrInsc(14) + IdAtiv(10)
					{'IDATIV'	,'C', nTmAtiv 			,0}	,;	//IdAtiv
					{'C1GTPPROC','C', 01 				,0}	,; 	//TPPROCRETPRINC OU TPPROCRETADIC
					{'C1GNUMPRO','C', TamSx3("C1G_NUMPRO")[1],0},;	//NRPROCRETPRINC OU NRPROCRETADIC ?
					{'IDSUSP'	,'C', nTmIdSus			,0}	,; 	//ID+VERSAO+CODSUSP
					{'CODSUS'	,'C', 14 				,0}	,; 	//CODSUSPPRINC OU CODSUSPADIC
					{'NUMPRO'	,'C', 06 				,2}	,; 	//NRPROCRETPRINC OU NRPROCRETADIC
					{'VALSUS'	,'N', 14 				,2}	,; 	//VALORPRINC OU VALORADIC
					{'C1GID'	,'C', 06 				,0}	,;
					{'C1GVERSAO','C', 14 				,0}	,;
					{'C1GFILIAL','C', nTmC1GFl			,0}}

    //T082AC - AJUSTE - LEGADO T9T - ESPELHO VOU				
	aCampAjst := {	{'CHAVE'	,'C', (21 + nTmAtiv)	,0}	,;
					{'IDATIV'	,'C', nTmAtiv 			,0}	,;
					{'DTAJUS'	,'C', 06 				,0}	,;
					{'CTPAJST'	,'C', 01 				,0}	,;	//TIPO AJUST
					{'CCODAJST'	,'C', 02 				,0}	,; 	//COD AJUST
					{'VLRAJST'	,'N', 14 				,2}	,;
					{'DSCAJST'	,'C', 20 				,0}	}

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopIdxObj()
Seta o indice das temporary table

@author Denis Souza
@since  02/04/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static function PopIdxObj(oTTCabc,oTTAtiv,oTTProc,oTTAjst,oTTCmpt,cPeriodo)
	
	//T082 - CPRB - LEGADO C5M - ESPELHO V0S
	oTTCabc:AddIndex("1",{"CHAVE"})
	oTTCabc:AddIndex("2",{"CPERIODO","CTPINSC","CNRINSC"})

	oTTAtiv:AddIndex("1",{"CHAVE"})
	oTTAtiv:AddIndex("2",{"CPERIODO","CTPINSC","CNRINSC","IDATIV"})
	
	//T082AA - COMPLEMENTO - LEGADO C5N - ESPELHO V0T
	oTTCmpt:AddIndex("1",{"CHAVE"})
	oTTCmpt:AddIndex("2",{"CHAVE","C5NID"})

	//T082AB - PROCESSO - LEGADO C5O - ESPELHO V0V  		
	oTTProc:AddIndex("1",{"CHAVE"})
	oTTProc:AddIndex("2",{"CHAVE","C1GTPPROC","C1GNUMPRO","CODSUS"})

	//T082AC - AJUSTE - LEGADO T9T - ESPELHO VOU
	oTTAjst:AddIndex("1",{"CHAVE"})
	oTTAjst:AddIndex("2",{"CHAVE","DTAJUS","CTPAJST","CCODAJST"})

	oTTCabc:Create()
	oTTAtiv:Create()
	oTTCmpt:Create()
	oTTProc:Create()
	oTTAjst:Create()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiReg()

Efetua a exclusão do modelo conforme parâmetro

@author Denis Souza
@since  02/04/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function ExcluiReg(cIdApReinf, cReg, aErro)

	Local cErro		As Character	
	Local cTpInsc	As Character
	Local cNrInsc	As Character
	Local lExcluiu	As Logical 
	Local oModel 	As Object
	
	cErro 		:= "" 
	cTpInsc 	:= ""
	cNrInsc 	:= ""
	lExcluiu 	:= .F.

	oModel 	:= FWLoadModel("TAFA499")
	cNrInsc	:= V0S->V0S_NRINSC
	cTpInsc	:= V0S->V0S_TPINSC

	oModel:SetOperation(5)
	oModel:Activate()
	
	If FwFormCommit(oModel)
	    lExcluiu := .T.
	Else
		cErro	:= STR0006 + CRLF //"Inconsistência na gravação do registro contendo a chave: "

		cErro 	+= "tpInsc: " + cTpInsc + CRLF
		cErro 	+= "nrInsc: " + cNrInsc + CRLF

		//cErro  	+= STR0006 + CRLF
		cErro 	+= TafRetEMsg(oModel)
		Aadd(aErro, {"R-2060", "ERRO", cErro})
		lExcluiu := .F.
	EndIf

Return lExcluiu


//-------------------------------------------------------------------
/*/{Protheus.doc} TamEUF()

Tamanho da Estrutura SM0 para a empresa, unidade negócio e filial

@author Denis Souza
@since
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function TamEUF(cLayout)

	Local aTam 	As Array
	Local nAte 	As Numeric
	Local nlA 	As Numeric
	Default cLayout := Upper(AllTrim(SM0->M0_LEIAUTE))

	aTam := {0,0,0}
	nAte := Len(cLayout)
	nlA	 := 0

	For nlA := 1 to nAte
		if Upper(substring(cLayout,nlA,1)) == "E"
			++aTam[1]
		elseif Upper(substring(cLayout,nlA,1)) == "U"
			++aTam[2]
		elseif Upper(substring(cLayout,nlA ,1)) == "F"
			++aTam[3]
		endif
	Next nlA

Return aTam

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFilId()

Retorna a query necessária para conseguir os recnos dos campos de acordo com
o tipo e o numero de inscrição

@author Matheus Prada
@since	20/01/2020
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function RetFilId(cNrInsc, cFiliais)

	Local cAlQry		as character
	Local aFils			as array
	Local aRECNOS		as array
	Local nX			as numeric

	aRECNOS		:= {}
	aFils		:= wsLoadFil()
	cAlQry 		:= GetNextAlias()
	cFiliais	:= SUBSTR(cFiliais, 2, Len(cFiliais))
	cFiliais	:= SUBSTR(cFiliais, 1, (Len(cFiliais) - 1))

	cQuery := "SELECT V48.V48_FILIAL AS FILIAL, "
	cQuery += "V48.R_E_C_N_O_ AS RECNO "
	cQuery += "FROM "+RetSqlName( "V48" )+" V48 "
	cQuery += "INNER JOIN "+RetSqlName( "T9C" )+" T9C "
	cQuery += "ON T9C_FILIAL = V48_FILIAL "
	cQuery += "AND T9C_ID = V48_IDCNO "
	cQuery += "AND T9C_NRINSC = '"+cNrInsc+"' "
	cQuery += "AND T9C.D_E_L_E_T_ = ' '  "
	cQuery += "WHERE "
	cQuery += "V48.V48_FILIAL IN ("+cFiliais+") "
	cQuery += "AND V48.D_E_L_E_T_ = ' ' "

	cQuery	:=	ChangeQuery( cQuery )
	dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAlQry )
	
	DbSelectArea(cAlQry)
	(cAlQry)->(DbGoTop())

	While (cAlQry)->(!EOF())

		If aScan(aFils, {|x| AllTrim(x[3]) == Alltrim((cAlQry)->FILIAL) }) > 0
			AADD(aRECNOS, (cAlQry)->RECNO)
		EndIf
		
		(cAlQry)->(DbSkip())
	EndDo
		
	(cAlQry)->(DbCloseArea())

Return aRECNOS
