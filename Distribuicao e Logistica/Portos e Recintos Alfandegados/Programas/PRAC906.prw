#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC906.CH"

/*/{Protheus.doc} PRAC906 
Tabelas do Sistema
@author   Felipe Machado de Oliveira
@version  P12
@since    25/07/2012
@obs      Parametrização de tabelas
/*/
Function PRAC906()
	Local oDlg          := nil
	Local oColumn       := nil
	local cQuery        := ""
	Local cOwnerSara    := SuperGetMV('MV_WMSSOWN', .F., 'sara_db..')
	Private cAliasTb    := SGetNAlias()
	Private cAliasQy    := SGetNAlias()
	Private aStruct
	Private oBrowse     := nil

	C906CTB(@aStruct)

	cQuery := "select case when b.param_rfb_id is not null then 'OK' else 'NO' end Status, a.name as nome_tabela, ROW_NUMBER() OVER(ORDER BY a.name) as cod "+;
				" from  "+;
					cOwnerSara+"sysobjects a "+;
						" left join tab_parametro_rfb b on a.name = b.param_rfb_tabela  "+;
				" where a.type = 'U' "+;
				" order by	 a.name "
	SPrintCon(cQuery, 'PRAC906 - Consulta')

	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasQy,.F.,.F.)
	(cAliasQy)->(DbGotop())
	while (cAliasQy)->(!EOF())
		(cAliasTb)->(dbAppend())

		(cAliasTb)->(FieldPut(1,(cAliasQy)->(Fieldget(1))))
		(cAliasTb)->(FieldPut(2,(cAliasQy)->(Fieldget(2))))
		(cAliasTb)->(FieldPut(3,cValToChar((cAliasQy)->(Fieldget(3)))))
		(cAliasQy)->(DbSkip())
	EndDo
	(cAliasQy)->(DBCloseArea())
	(cAliasTb)->(DBCommit())
	(cAliasTb)->(DbGotop())

	oBrowse := FWMarkBrowse():new(oDlg)
	oBrowse:SetDataTable()
	oBrowse:SetDescription(STR0001)
	oBrowse:AddButton(STR0002,{||C906SAVEB()},,1,2)
	oBrowse:SetAlias(cAliasTb)
	oBrowse:SetFieldMark('CP1')
	oBrowse:SetMark('OK', cAliasTb, 'CP1')
	oBrowse:SetAllMark( { || oBrowse:AllMark() } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData(  {|| CP2} )
	oColumn:SetTitle( STR0003  )
	oColumn:SetSize(  20  )

	oBrowse:SetColumns({oColumn})

	oBrowse:Activate()

	SDelTbTmp(cAliasTb)
return

function C906SAVEB(lDados)

	Processa( {|| Resultado() },STR0004)

	ApMsgInfo(STR0005)
Return

Static Function Resultado()
	Local aArea    := GetArea()
	Local cMarca   := oBrowse:Mark()
	Local nCt      := 0
	Local aTabela  := {}
	Local cQry     := ""
	Local i        := 0

	(cAliasTb)->( dbGoTop() )
	While !(cAliasTb)->( EOF() )
		If oBrowse:IsMark(cMarca)
			nCt++
			Aadd(aTabela, (cAliasTb)->(FieldGet(2)))
		EndIf

		(cAliasTb)->( dbSkip() )
	End

	ProcRegua(nCt)

	cQry := "delete from tab_parametro_rfb"

	TcSqlExec(cQry)

	for i := 1 to nCt
		IncProc(STR0006+" "+Str(nCt))

		cQry := "insert into tab_parametro_rfb"+;
					"(param_rfb_id, param_rfb_tabela)"+;
				"values"+;
					"("+STransType(i)+",'"+STransType(aTabela[i])+"')"

		TcSqlExec(cQry)
	next

	RestArea( aArea )

return .T.

Static Function C906CTB(aStruct)
	aStruct := {;
	    {'CP1','C', 2,0}, ;
	    {'CP2','C',50,0}, ;
	    {'CP3','C',10,0}  ;
	}

	SDelTbTmp(cAliasTb)
	SCriaTbTmp({aStruct, {"CP3"}}, cAliasTb)
return