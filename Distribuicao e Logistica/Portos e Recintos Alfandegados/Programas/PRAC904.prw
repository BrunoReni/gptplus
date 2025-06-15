#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC904.CH"

/*/{Protheus.doc} PRAC904
@author   Felipe Machado de Oliveira
@version  P12
@since    10/07/2012
@obs      2.1 - Execução de SQL dinâmico
/*/

Function PRAC904()
	Local oDlg
	Local oPanelFiltro    := nil
	Local oPanelResultado := nil
	Local oPanelAllClient := nil
	Local oPanelBottom    := nil
	Local oTButton        := nil
	Local oTButtonZoom    := nil
	Local oTButtonSair    := nil
	Local oLayer          := nil
	local aCoors          := FWGetDialogSize(oMainWnd)
	Local oBrowse
	Local nColSize        := 0
	Private cTexto        := ""
	Private oTMultiget    := nil
	Private cAliasBrowse  := ''

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		oLayer := FWLayer():new()
		oLayer:init(oDlg,.F.)
		oLayer:addCollumn('Col01',100,.F.)
		oLayer:addWindow('Col01','C1_Win01',STR0001,40,.T.,.F.,,,)
		oLayer:addWindow('Col01','C1_Win02',STR0002,60,.T.,.T.,,,)

		oPanelFiltro  := oLayer:getWinPanel('Col01','C1_Win01')
		oPanelResultado := oLayer:getWinPanel('Col01','C1_Win02')

		oPanelBottom  := TPanel():Create(oPanelFiltro,01,01,"",,,,,,10,15)
		oPanelBottom:Align := CONTROL_ALIGN_BOTTOM //4

		oPanelAllClient  := TPanel():Create(oPanelFiltro,01,102,"",,,,,,100,100)
		oPanelAllClient:Align := CONTROL_ALIGN_ALLCLIENT //5

		oTMultiget := TMultiget():Create(oPanelAllClient,{|u|if(Pcount()>0,cTexto:=u,cTexto)},01,01,;
	                           500,25,,,,,,.T.)
		oTMultiget:EnableVScroll(.T.)
		oTMultiget:Align := CONTROL_ALIGN_ALLCLIENT //5

		oTButton := TButton():Create( oPanelBottom,01,01,STR0003,{||C904NCON(oBrowse, cTexto, @nColSize)},;
	                  40,10,,,,.T.,,,,,,)
		oTButtonZoom := TButton():Create( oPanelBottom,01,45,STR0004,{||C904ZOOM()},65,10,,,,.T.,,,,,,)

		oTButtonSair := TButton():Create( oPanelBottom,01,115,STR0013,{||oDlg:End()},40,10,,,,.T.,,,,,,)

		cAliasBrowse := SCriaTbTmp({{{'CP1', 'C', 1, 0}}, {'CP1'}})
		oBrowse := FWBrowse():new(oPanelResultado)
		oBrowse:SetDataTable()
		oBrowse:SetAlias(cAliasBrowse)
		oBrowse:Activate()

	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTbTmp(cAliasBrowse)
Return

Static Function C904NCON(oBrowse, cTexto, nColSize)
	Local cSql   := C904VSQL(cTexto)
	Local lRet   := PRAC904POS(cSql)

	if lRet
		if (!SEmpty(STrim(cSql)))
			C904EXEC(@oBrowse, cSql, @nColSize)
		endif
	endif
return

Function PRAC904POS(cSql)
	Local nRetorno   := 0

	cSql := upper(cSql)

	nRetorno += At('UPDATE',cSql)
	nRetorno += At('DELETE',cSql)
	nRetorno += At('INSERT',cSql)
	nRetorno += At('DROP',cSql)
	nRetorno += At('CREATE',cSql)
	nRetorno += At('ALTER',cSql)

	if nRetorno > 0
		alert(STR0005)
		return .F.
	endif

return .T.

Static Function C904EXEC(oBrowse, cSql, nColSize)
	Local nStart      := 0
	Local nMax        := 0
	Local oColumn
	Local cTBTabelas  := GetNextAlias()
	Local cTBTemp     := GetNextAlias()
	Local aCampos := {}
	Local aCamposTb := {}
	LOcal cCampo := ""
	Local lError := .F.
	Local bError := errorBlock({|e| SMSGERRO( e, @lError ) })

	BEGIN SEQUENCE
		
		if UPPER(SUBSTR(LTRIM(cSql),1,4)) = 'EXEC'
		   SPrintCon(cSql+","+"'"+SGetDBOwner()+cTBTabelas+"'", 'PRAC904 - Exec. Din')
		   TCSqlExec(cSql+","+"'"+SGetDBOwner()+cTBTabelas+"'")
		else		
		   SPrintCon('SELECT * INTO '+cTBTabelas+ ' FROM ('+cSql+') AS T', 'PRAC904 - Exec. Din')
		   TCSqlExec('SELECT * INTO '+cTBTabelas+ ' FROM ('+cSql+') AS T')
		end if	

		SPrintCon("exec proc_altera_col_sql_din_w '"+cTBTabelas+"'", 'PRAC904 - Exec. Din')
		TCSqlExec("exec proc_altera_col_sql_din_w '"+cTBTabelas+"'")

		SPrintCon("select * from "+cTBTabelas, 'PRAC904 - Exec. Din')

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,"select * from "+cTBTabelas),cTBTemp, .F., .F.)

	END SEQUENCE

	if !lError

		aCampos := (cTBTemp)->(DBSTRUCT())
		nMax := Len(aCampos)
		for nStart := 1 to nMax
			Aadd(aCamposTb, {'CP'+STrim(Str(nStart)) , aCampos[nStart][2], aCampos[nStart][3], aCampos[nStart][4]})
		next

		(cAliasBrowse)->(dbclosearea())
		SDelTbTmp(cAliasBrowse)
		SCriaTbTmp({aCamposTb, {'CP1'}}, cAliasBrowse)

		nMax := len(aCampos)

		(cTBTemp)->(DBGoTop())
		While (cTBTemp)->(!Eof())
			(cAliasBrowse)->(dbappend())

			for nStart := 1 to nMax
				//(cAliasBrowse)->(FieldPut(nStart,(cTBTemp)->(Fieldget(nStart))))

				If aCampos[nStart][2] == "N"
					(cAliasBrowse)->(FieldPut(nStart,val(Str((cTBTemp)->(FieldGet(nStart)),aCampos[nStart][3],aCampos[nStart][4]))))
				Else
					(cAliasBrowse)->(FieldPut(nStart,(cTBTemp)->(Fieldget(nStart))))
				EndIf

			next

			(cTBTemp)->(dbskip())
		enddo
		(cTBTemp)->(dbCloseArea())

		(cAliasBrowse)->(dbcommit())
		(cAliasBrowse)->(dbgotop())

		nColSize := Len(oBrowse:aColumns)
		for nStart := 1 to nColSize
			oBrowse:DelColumn(nStart)
		next

		nMax := Len(aCampos)
		for nStart := 1 to nMax
			oColumn := nil

			oColumn := FWBrwColumn():New()
			cCampo := 'CP'+STrim(Str(nStart))
			cCampo := "{|| "+cCampo+"}"
			oColumn:SetData(  &(cCampo) )

			oColumn:SetTitle(aCampos[nStart][1])
			oColumn:SetSize(aCampos[nStart][3])

			oBrowse:SetColumns({oColumn})
		next

		nColSize := nMax

		oBrowse:updateBrowse()

		if Select(cTBTemp) > 0
			(cTBTemp)->(dbCloseArea())
		endif
	else
		if Select(cTBTemp) > 0
			(cTBTemp)->(dbCloseArea())
		endif
	endif
	TCSqlExec('drop table '+cTBTabelas)	 
return

Static Function C904VSQL(cTexto)
	Local cTmpSQL     := cTexto
	Local i           := 0
	local n           := 0
	Local nPalavra    := 0
	Local nMax        := Len(cTmpSQL)
	Local nStart      := 0
	Local nStop       := 0
	Local aParametros := {}
	Local aValores    := {}
	Local aDescAux    := {}
	Local cExist      := "N"
	Local nRet        := 0
	Local cValor      := ""

	for i := 1 to nMax
		if ( (SUBSTR(cTmpSQL, i,1)== ':') .and. (SUBSTR(cTmpSQL, i+1,1)== '@') )
			nStart := i+1
		elseif ( (nStart > 0) .AND. ( (SUBSTR(cTmpSQL, i,1)== ' ') .OR. (SUBSTR(cTmpSQL, i,1)== '"') .OR. (SUBSTR(cTmpSQL, i,1)== "'") .OR. (SUBSTR(cTmpSQL, i,1)== '') .OR. (SUBSTR(cTmpSQL, i,1)== ',') .OR. (SUBSTR(cTmpSQL, i,1)== '%') .OR. (Asc(substr(cTmpSQL, i, 2)) == 13) ))
			nPalavra := (i - nStart) - 1
			if STrim(SUBSTR(cTmpSQL, nStart + 1, nPalavra)) != '' .AND. STrim(SUBSTR(cTmpSQL, nStart + 1, nPalavra)) != "'" .AND. STrim(SUBSTR(cTmpSQL, nStart + 1, nPalavra)) != '"'
				if ascan(aParametros, SUBSTR(cTmpSQL, nStart + 1, nPalavra)) == 0
					Aadd(aParametros, SUBSTR(cTmpSQL, nStart + 1, nPalavra))
				endif
			endif
			nStart := 0
		elseif ((i == nMax) .AND. (nStart > 0))
			if ascan(aParametros, SUBSTR(cTmpSQL, nStart + 1)) == 0
				Aadd(aParametros, SUBSTR(cTmpSQL, nStart + 1))
			endif
			nStart := 0
		endif
	next

	if 	len(aParametros) != 0
		aValores := PRAA939(aParametros)
		nMax     := len(aValores)

		for i := 1 to nMax
			cValor := aValores[i]

            if cValor <> 'null'
			   if SUBSTR(aParametros[i],1,2) = "D2"
                  cValor := SDBDate(cValor,'23:59:59')
			   elseif SUBSTR(aParametros[i],1,1) = "D"
   			      cValor := SDBDate(cValor)
			   elseif SUBSTR(aParametros[i],1,1) = "S"
                  cValor := cValor
			   else
  			      cValor := SCrtSpec(cValor)
			   endif
            end IF
			cTmpSQL := StrTran(cTmpSQL,":@" + aParametros[i], STrim(cValor))
		next
	endif
    cTmpSQL := STRTRAN(cTmpSQL, "'null'",'null')
return cTmpSQL

Static Function C904ZOOM()
	local cRet     := ''
	local aZoom    := {}
	local aRetZoom := {}
	local cDescr   := ""
	local cSQL		 := ""
	Local lRet     := .F.

	if Select('DBQ') > 0
		DBQ->(dbCloseArea())
	endif

	lRet := ConPad1(,,,'DBQ_01', cDescr, ,.F., '')

	if lRet
		cSQL := nil
		cSQL := DBQ->DBQ_SQL
		cTexto := nil
		cTexto := cSQL
	endif

return cSQL
