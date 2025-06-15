#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC928.CH"

/*/{Protheus.doc} PRAC928 
@author   Aline Briesemeister Xavier
@version  P12
@since    14/08/2012
@obs      2.2.15 Tabelas do sistema
/*/
Function PRAC928()
	Local oDlg            := nil
	Local aCoors          := FWGetDialogSize(oMainWnd)
	local aTFolder        := nil
	Local oLayer          := nil
	Local oLayerP2        := nil
	Local cQuery          := ""
	Local oBrowseT        := nil
	Local oBrowseC1       := nil
	Local oBrowseC2       := nil
	Local oBrowseB1       := nil
	Local oBrowseB2       := nil
	Local oBrowseL        := nil
	Local oP2Grid         := nil
	Local oLeftGrid       := nil
	Local oTopGrid        := nil
	Local oRightGrid      := nil
	Local oBottomGrid     := nil
	Local oPanelBottom	 := nil
	Local oPanelRC		 := nil
	Local oPanelLC		 := nil
	Local oPanelRB		 := nil
	Local oPanelLB		 := nil
	Local oPainelLP		 := nil
	Local oPainelLL		 := nil
	Local oLbxL			 := nil
	Local oLbxT			 := nil
	local nList			 := nil
	Local oPesquisa		 := nil
	Local cPesquisa       := "                                                   "
	Local oTButtonSearch  := nil
	Private oTFolder        := nil
	Private oBrowseP2       := nil
	Private cAliasT        := SGetNAlias()
	Private cAliasG       := SGetNAlias()
	Private oBrowseR      := nil
	Private cTabela       := ""
	Private aArrayLGrid   := {}
	Private aArLGDesc     := {}
	Private aArrayTGrid   := {}
	Private aArrayC1Grid  := {}
	Private aArrayC2Grid  := {}
	Private aArrayB1Grid  := {}
	Private aArrayB2Grid  := {}
	Private nIdxList      := 0
	Private cFiltroAdv := ""
	Private aStructCon := {}

	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		aTFolder := { STR0017, STR0018 }
		if aCoors[3] <= 768
		  oTFolder := TFolder():New( 0,0,aTFolder,,oDlg,,,,.T.,,490,270 )
		else
		  oTFolder := TFolder():New( 0,0,aTFolder,,oDlg,,,,.T.,,600,420 )
		end if

		oLayer := FWLayer():new()
      	oLayer:init(oTFolder:aDialogs[1],.T.)
      	if aCoors[3] <= 768
      	  oLayer:addColumn('Col01',23,.F.)
      	  oLayer:addColumn('Col02',77,.F.)
      	else
      	  oLayer:addColumn('Col01',20,.F.)
      	  oLayer:addColumn('Col02',80,.F.)
      	end if
      	oLayer:addWindow('Col01','C1_Win01',STR0001,100,.F.,.F.,,,)
      	oLayer:addWindow('Col02','C1_Win02',STR0002,40,.F.,.F.,,,)
      	oLayer:addWindow('Col02','C1_Win03',STR0003,30,.F.,.F.,,,)
      	oLayer:addWindow('Col02','C1_Win04',STR0004,30,.F.,.F.,,,)

      	oLeftGrid  := oLayer:getWinPanel('Col01','C1_Win01')
      	oTopGrid   := oLayer:getWinPanel('Col02','C1_Win02')
      	oRightGrid := oLayer:getWinPanel('Col02','C1_Win03')
      	oBottomGrid := oLayer:getWinPanel('Col02','C1_Win04')

      	oPainelLP := TPanel():Create(oLeftGrid,01,01,"",,,,,,10,15)
		oPainelLP:Align := CONTROL_ALIGN_TOP

		oPainelLL := TPanel():Create(oLeftGrid,01,01,"",,,,,,10,15)
		oPainelLL:Align := CONTROL_ALIGN_ALLCLIENT

      	oPanelBottom  := TPanel():Create(oTopGrid,01,01,"",,,,,,10,15)
		oPanelBottom:Align := 4

      	oPanelLC  := TPanel():Create(oRightGrid,01,01,"",,,,,,200,15)
		oPanelLC:Align := CONTROL_ALIGN_LEFT

		oPanelRC  := TPanel():Create(oRightGrid,01,01,"",,,,,,50,15)
		oPanelRC:Align := CONTROL_ALIGN_ALLCLIENT

      	oPanelLB  := TPanel():Create(oBottomGrid,01,01,"",,,,,,200,15)
		oPanelLB:Align := CONTROL_ALIGN_LEFT

		oPanelRB  := TPanel():Create(oBottomGrid,01,01,"",,,,,,50,15)
		oPanelRB:Align := CONTROL_ALIGN_ALLCLIENT

		cQuery := "exec proc_rfb_s_parametro_tabela_w "

		DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasG,.T.,.F.)
		(cAliasG)->(DbGotop())
		while (cAliasG)->(!EOF())
			Aadd(aArrayLGrid,(cAliasG)->(Fieldget(1)))
	        if !SEmpty((cAliasG)->(Fieldget(2)))
				Aadd(aArLGDesc,StrTran((cAliasG)->(Fieldget(2)), CHR(10), ''))
				Aadd(aArLGDesc,StrTran((cAliasG)->(Fieldget(2)), CHR(13), ' '))
			else
				Aadd(aArLGDesc,'')
        	end
			(cAliasG)->(DbSkip())
		EndDo
		(cAliasG)->(dbCloseArea())

		//Campos Tabela
      	oBrowseT := FWBrowse():New(oTopGrid)
		oBrowseT:DisableConfig()
		oBrowseT:DisableReport()
		oBrowseT:SetDataArray()
		oBrowseT:SetArray(aArrayTGrid)

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayTGrid[oBrowseT:At(),1]}") )
		oColumns:SetTitle(STR0008)
		oColumns:SetSize(20)
		oBrowseT:SetColumns({oColumns})

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayTGrid[oBrowseT:At(),4]}") )
		oColumns:SetTitle(STR0011)
		oColumns:SetSize(50)
		oBrowseT:SetColumns({oColumns})

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayTGrid[oBrowseT:At(),2]}") )
		oColumns:SetTitle(STR0009)
		oColumns:SetSize(10)
		oBrowseT:SetColumns({oColumns})

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayTGrid[oBrowseT:At(),3]}") )
		oColumns:SetTitle(STR0010)
		oColumns:SetSize(5)
		oBrowseT:SetColumns({oColumns})		
		
		oBrowseT:Activate()

		//Tabelas de referencia
		oBrowseC1:= FWBrowse():New(oPanelLC)
		oBrowseC1:DisableConfig()
		oBrowseC1:DisableReport()
		oBrowseC1:SetDataArray()
		oBrowseC1:SetArray(aArrayC1Grid)
		oBrowseC1:SetDoubleClick({|| C928DCCO1(aArrayLGrid,aArrayC1Grid,oBrowseC1,oLbxL)})

		oBrowseC2:= FWBrowse():New(oPanelRC)
		oBrowseC2:DisableConfig()
		oBrowseC2:DisableReport()
		oBrowseC2:SetDataArray()
		oBrowseC2:SetArray(aArrayC2Grid)

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayC1Grid[oBrowseC1:At(),1]}") )
		oColumns:SetTitle(STR0012)
		oColumns:SetSize(20)
		oBrowseC1:SetColumns({oColumns})

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayC1Grid[oBrowseC1:At(),2]}") )
		oColumns:SetTitle(STR0013)
		oColumns:SetSize(20)
		oBrowseC1:SetColumns({oColumns})

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayC1Grid[oBrowseC1:At(),3]}") )
		oColumns:SetTitle(STR0014)
		oColumns:SetSize(10)
		oBrowseC1:SetColumns({oColumns})

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayC2Grid[oBrowseC2:At(),1]}") )
		oColumns:SetTitle(STR0015)
		oColumns:SetSize(20)
		oBrowseC2:SetColumns({oColumns})

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayC2Grid[oBrowseC2:At(),2]}") )
		oColumns:SetTitle(STR0016)
		oColumns:SetSize(20)
		oBrowseC2:SetColumns({oColumns})
		
		oBrowseC1:Activate()
		oBrowseC2:Activate()

		//Tabelas que referencia
      	oBrowseB1 := FWBrowse():New(oPanelLB)
		oBrowseB1:DisableConfig()
		oBrowseB1:DisableReport()
		oBrowseB1:SetDataArray()
		oBrowseB1:SetArray(aArrayB1Grid)
		oBrowseB1:SetDoubleClick({|| C928DCBR1(aArrayLGrid,aArrayB1Grid,oBrowseB1,oLbxL)})

		oBrowseB2 := FWBrowse():New(oPanelRB)
		oBrowseB2:DisableConfig()
		oBrowseB2:DisableReport()
		oBrowseB2:SetDataArray()
		oBrowseB2:SetArray(aArrayB2Grid)

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayB1Grid[oBrowseB1:At(),1]}") )
		oColumns:SetTitle(STR0012)
		oColumns:SetSize(20)
		oBrowseB1:SetColumns({oColumns})

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayB1Grid[oBrowseB1:At(),2]}") )
		oColumns:SetTitle(STR0013)
		oColumns:SetSize(20)
		oBrowseB1:SetColumns({oColumns})

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayB1Grid[oBrowseB1:At(),3]}") )
		oColumns:SetTitle(STR0014)
		oColumns:SetSize(10)
		oBrowseB1:SetColumns({oColumns})

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayB2Grid[oBrowseB2:At(),1]}") )
		oColumns:SetTitle(STR0015)
		oColumns:SetSize(20)
		oBrowseB2:SetColumns({oColumns})

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayB2Grid[oBrowseB2:At(),2]}") )
		oColumns:SetTitle(STR0016)
		oColumns:SetSize(10)
		oBrowseB2:SetColumns({oColumns})

		oBrowseB1:Activate()
		oBrowseB2:Activate()

		oLbxL := TListBox():Create(oLeftGrid, 01, 01, {|u| if( Pcount()>0, nIdxList := u, ) }, aArrayLGrid, ;
			210, 095, ;
			{|| C928BTG(oBrowseT,oBrowseC1,oBrowseC2,oBrowseB1,oBrowseB2,oLbxL,aArrayTGrid,"{|| cTabela := aArrayLGrid[oLbxL:nAt]}",oLayer)},;
			nil, nil, nil, .T., nil, nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil )
		oLbxL:Align := 5
		oLbxL:Select(1)

		oPesquisa := TGet():New( 01,01,{|u| if(PCount()>0,cPesquisa := u,cPesquisa)},;
			   oPainelLP,70,10,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPesquisa,,,,)

		oTButtonSearch := TButton():Create( oPainelLP,02,72,STR0018,{|| C928FINDP(cPesquisa,oLbxL, aArrayLGrid)},30,10,,,,.T.,,,,,,)

		oLayerP2 := FWLayer():new()
      	oLayerP2:init(oTFolder:aDialogs[2],.T.)
      	oLayerP2:addColumn('Col01',100,.F.)
      	oLayerP2:addWindow('Col01','C1_Win01',STR0001,100,.F.,.F.,,,)
      	oP2Grid  := oLayerP2:getWinPanel('Col01','C1_Win01')

      	SCriaTbTmp({ {{'CP1' ,'C',1 ,0} }, {'CP1'}}, cAliasT)

		oBrowseP2:= FWMBrowse():New()
		oBrowseP2:SetAlias(cAliasT)
		oBrowseP2:SetDescription("Dados")
		oBrowseP2:SetOwner(oP2Grid)
//		oBrowseP2:SetDataTable()
		oBrowseP2:SetMenuDef("")
		oBrowseP2:AddButton("Filtro", {||PRAC928FTR()},, 3, 0)
		
		oBrowseP2:DisableDetails()
		oBrowseP2:Activate()
		If oBrowseP2:lnobrowse 
			oBrowseP2:UpdateBrowse()
			oBrowseP2:Activate()
		EndIf

		oTButton      := TButton():Create( oPanelBottom,01,01,STR0005,{|| C928SELT(oBrowseP2,oTFolder)},40,10,,,,.T.,,,,,,)
		oTButtonClose := TButton():Create( oPanelBottom,01,45,STR0006,{|| oDlg:End()},40,10,,,,.T.,,,,,,)


	ACTIVATE MSDIALOG oDlg CENTERED

	SDelTbTmp(cAliasT)
return

Function C928BTG(oBrowseT,oBrowseC1,oBrowseC2,oBrowseB1,oBrowseB2,oLbxL,aArrayTGrid,cConteud,oLayer)
	Local cQuery      := ""
	Local cQueryfk    := ""
	Local i           := 1
	local nColSize    := 1
	Local oColumns

	aArrayTGrid  := {}
	aArrayC1Grid := {}
	aArrayC2Grid := {}
	aArrayB1Grid := {}
	aArrayB2Grid := {}

	Eval(&(cConteud))

    oLayer:setWinTitle('Col02','C1_Win02','Campos da Tabela: '+STrim(STransType(cTabela)))
  
	cQuery := "exec proc_s_campos_tab_db_w '"+STransType(cTabela)+"'"

	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasG,.T.,.F.)
	(cAliasG)->(DbGotop())
	while (cAliasG)->(!EOF())
		Aadd(aArrayTGrid, {(cAliasG)->(Fieldget(1)),(cAliasG)->(Fieldget(2)),(cAliasG)->(Fieldget(3)),(cAliasG)->(Fieldget(4))})
		(cAliasG)->(DbSkip())
	EndDo
	(cAliasG)->(dbCloseArea())

	cQuery := "exec proc_s_tab_de_ref_db '"+STransType(cTabela)+"'"

	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasG,.T.,.F.)
	(cAliasG)->(DbGotop())
	while (cAliasG)->(!EOF())
		Aadd(aArrayC1Grid, {(cAliasG)->(Fieldget(1)),(cAliasG)->(Fieldget(2)),STR0019})
	   (cAliasG)->(DbSkip())
	EndDo
	(cAliasG)->(dbCloseArea())

	if len(aArrayC1Grid) == 0
		aArrayC1Grid := {{'', '', ''}}
		aArrayC2Grid := {{'', ''}}
	endif

	oBrowseC1:SetChange({|| C928CRTABE(aArrayC1Grid[oBrowseC1:At(),1], aArrayC2Grid, oBrowseC2, oBrowseC1)})

	cQuery := "exec proc_s_tab_que_ref_db '"+STransType(cTabela)+"'"

	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasG,.T.,.F.)
	(cAliasG)->(DbGotop())
	while (cAliasG)->(!EOF())
		Aadd(aArrayB1Grid, {(cAliasG)->(Fieldget(1)),(cAliasG)->(Fieldget(2)),STR0019})
		(cAliasG)->(DbSkip())
	EndDo
	(cAliasG)->(dbCloseArea())

	if len(aArrayB1Grid) == 0
		aArrayB1Grid := {{'', '', ''}}
		aArrayB2Grid := {{'', ''}}
	endif

	oBrowseB1:SetChange({|| C928BRTABE(aArrayB1Grid[oBrowseB1:At(),1], aArrayB2Grid, oBrowseB2, oBrowseB1)})

	oBrowseT:SetArray(aArrayTGrid)
	oBrowseT:UpdateBrowse()
	oBrowseC1:SetArray(aArrayC1Grid)
	oBrowseC1:UpdateBrowse()
	oBrowseC2:SetArray(aArrayC2Grid)
	oBrowseC2:UpdateBrowse()
	oBrowseB1:SetArray(aArrayB1Grid)
	oBrowseB1:UpdateBrowse()
	oBrowseB2:SetArray(aArrayB2Grid)
	oBrowseB2:UpdateBrowse()

	if (Len(aArrayC1Grid) > 0)
		C928CRTABE(aArrayC1Grid[oBrowseC1:At(),1], aArrayC2Grid, oBrowseC2, oBrowseC1)
	endif

	if (Len(aArrayB1Grid) > 0)
		C928BRTABE(aArrayB1Grid[oBrowseB1:At(),1], aArrayB2Grid, oBrowseB2, oBrowseB1)
	endif
return

Function C928SELT(oBrowseP2,oTFolder,cFiltroSql)
	Local oColumn
	Local nColSize := 0
	Local nMax     := 0
	Local nStart   := 0
	Local aCampos  := {}
	Local aStruct
	Local cSQL     := ""
	Local cTBTabelas  := GetNextAlias()
	local cTabDrop    := ""	
	Default cFiltroSql := ""

	SPrintCon('iniciou')
	cSQL := "select * from "+STransType(cTabela)

	SPrintCon('SQL 1: SELECT * INTO '+cTBTabelas+ ' FROM ('+cSql+') AS T')
	TCSqlExec('SELECT * INTO '+cTBTabelas+ ' FROM ('+cSql+') AS T')

	SPrintCon('SQL 2: exec proc_altera_col_sql_din_w "'+cTBTabelas+'"')
	TCSqlExec("exec proc_altera_col_sql_din_w '"+cTBTabelas+"'")
	
	cTabDrop := cTBTabelas
	
	If !Empty(cFiltroSql)
	    cFiltroSql := StrTran( cFiltroSql, "'", "''" )
		If At("WHERE",UPPER(cTBTabelas)) == 0
			cTBTabelas += " WHERE"
		EndIf
		cTBTabelas += " " + cFiltroSql
	EndIf
	SPrintCon('SQL 3: select * from '+cTBTabelas)
		
	If !Empty(cFiltroSql) 
	  if At("WHERE",UPPER(cTBTabelas)) != 0
	    DbUseArea(.T.,'TOPCONN',TCGenQry(,,"exec proc_exec_filtro_2_15_tab_sistema_w ' select * from "+SGetDBOwner()+cTBTabelas+" ' "),cAliasG,.F.,.T.)
	  else
	    DbUseArea(.T.,'TOPCONN',TCGenQry(,,"select * from "+cTBTabelas),cAliasG,.F.,.T.)
	  endif
	else
	  DbUseArea(.T.,'TOPCONN',TCGenQry(,,"select * from "+cTBTabelas),cAliasG,.F.,.T.)
	endif

	aStruct := (cAliasG)->(DBStruct())
	aStructCon := aClone(aStruct)
	nMax := Len(aStruct)

	for nStart := 1 to nMax
		Aadd(aCampos, {"CP" + cValToChar(nStart), aStruct[nStart][2], aStruct[nStart][3], aStruct[nStart][4]})
	Next

	SDelTbTmp(cAliasT)
	SCriaTbTmp({aCampos, {"CP1"}}, cAliasT)
	SPrintCon('comeca o while')
	(cAliasG)->(DBGoTop())
	While (cAliasG)->(!Eof())
		(cAliasT)->(DBAppend())
		for nStart := 1 to nMax
			If aStruct[nStart][2] == "N"
				(cAliasT)->(FieldPut(nStart,val(Str((cAliasG)->(FieldGet(nStart)),aStruct[nStart][3],aStruct[nStart][4]))))
			Else
				(cAliasT)->(FieldPut(nStart,(cAliasG)->(Fieldget(nStart))))
			EndIf
		next
		(cAliasG)->(dbSkip())
	EndDo
	(cAliasG)->(dbCloseArea())
	SPrintCon('termina o while')

	(cAliasT)->(dbCommit())
	(cAliasT)->(DBGoTop())

	nColSize := Len(oBrowseP2:aColumns)
	for nStart := 1 to nColSize
		oBrowseP2:DelColumn(nStart)
	next

	nMax := Len(aStruct)
	for nStart := 1 to nMax
		oColumn := nil

		oColumn := FWBrwColumn():New()
		cCampo := "{|| CP" + cValToChar(nStart)+"}" 
		oColumn:SetData( &(cCampo) )

		oColumn:SetTitle(aStruct[nStart][1])
		oColumn:SetSize(aStruct[nStart][3])
		oBrowseP2:SetColumns({oColumn})
	next

	nColSize := nMax
	oTFolder:ShowPage(2)
	oBrowseP2:UpdateBrowse()
	oBrowseP2:refresh(.T.)

	SPrintCon('SQL 4: drop table - Pendente')
	//TCSqlExec('drop table '+cTabDrop)
	SPrintCon('SQL 4: drop table - Concluido')	
return


function C928CRTABE(cFK, aArrayC2Grid, oBrowseC2, oBrowseC1)
	Local cQueryfk    := ""

	aArrayC2Grid := {}

	cQueryfk := "exec proc_s_tab_ref_col_db '"+cFK+"'"
	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQueryfk),cAliasG,.T.,.F.)
	(cAliasG)->(DbGotop())
	while (cAliasG)->(!EOF())
		Aadd(aArrayC2Grid, {(cAliasG)->(Fieldget(1)),(cAliasG)->(Fieldget(2))})
		(cAliasG)->(DbSkip())
	EndDo
	(cAliasG)->(dbCloseArea())

	oBrowseC2:SetArray(aArrayC2Grid)
	oBrowseC2:UpdateBrowse()
	oBrowseC1:SetFocus()
return

function C928BRTABE(cFK, aArrayB2Grid, oBrowseB2, oBrowseB1)
	Local cQueryfk    := ""

	aArrayB2Grid := {}
	cQueryfk := "exec proc_s_tab_ref_col_db '"+cFK+"'"
	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQueryfk),cAliasG,.T.,.F.)
	(cAliasG)->(DbGotop())
	while (cAliasG)->(!EOF())
		Aadd(aArrayB2Grid, {(cAliasG)->(Fieldget(1)),(cAliasG)->(Fieldget(2))})
		(cAliasG)->(DbSkip())
	EndDo
	(cAliasG)->(dbCloseArea())

	oBrowseB2:SetArray(aArrayB2Grid)
	oBrowseB2:UpdateBrowse()
	oBrowseB1:SetFocus()
return

function C928DCCO1(aArrayLGrid,aArrayC1Grid,oBrowseC1,oLbxL)
	Local cTabela := ''
	Local nPos := 0

	if (oBrowseC1:ColPos() == 3)
		cTabela := AllTrim(aArrayC1Grid[oBrowseC1:At(), 2])
		nPos := AScan(aArrayLGrid, cTabela)
		if nPos > 0
			oLbxL:Select(nPos)
		endif
	endif
return

function C928DCBR1(aArrayLGrid,aArrayB1Grid,oBrowseB1,oLbxL)
	Local cTabela := ''
	Local nPos := 0

	if (oBrowseB1:ColPos() == 3)
		cTabela := AllTrim(aArrayB1Grid[oBrowseB1:At(), 2])
		nPos := AScan(aArrayLGrid, cTabela)
		if nPos > 0
			oLbxL:Select(nPos)
		endif
	endif
return

function C928FINDP(cPesquisa,oLbxL, aArrayLGrid)
	Local nPos := 0

	nPos := Ascan(aArrayLGrid, { |x, y| (AllTrim(cPesquisa) $ AllTrim(x)) })
	if nPos > 0
		oLbxL:Select(nPos)
	endif
return

Function PRAC928FTR()
	Local oFilter  := FWFilter():New(oBrowseP2:GetOwner())
	Local aFields  := {}
	Local nX
	If Empty(aStructCon)
		MsgAlert('Realize a consulta antes de filtrar')
	Else
		For nX := 1 To Len(aStructCon)
			If aStructCon[nX][2] == "N"
				AAdd(aFields, {aStructCon[nX][1], aStructCon[nX][1], aStructCon[nX][2], aStructCon[nX][3], aStructCon[nX][4],"@E 999999999.99999"})
			Else
				AAdd(aFields, {aStructCon[nX][1], aStructCon[nX][1], aStructCon[nX][2], aStructCon[nX][3], aStructCon[nX][4],"@!"})
			EndIf
		Next nX
		oFilter:SetAlias(cAliasT)
		oFilter:SetProfileID("1")
		oFilter:SetField(aFields)
		oFilter:SetExecute({|| C928ACTFIL(oFilter)})
		oFilter:DisableValid(.F.)
		oFilter:CleanFilter(.F.)	
		
		oFilter:LoadFilter()		
		
		oFilter:Activate()
		
	EndIf
Return

Function C928ACTFIL(oFilter)
   local cWhere :=  ''
   local cWheredt := ''
   local cFtrAdvAux := ""
   local bBloco 
   local nInicio  := 0
   local nFim := 0 
   local nStrDt := 0 
   local nOperIgual   := 0
  
   	cFiltroAdv := oFilter:GetExprSQL()
    cFtrAdvAux := cFiltroAdv
   	while (At("FWMntFilDt",cFtrAdvAux) != 0)
   	   //Criado para tratar a informação quando o componente do filtro retorna 
   	   //"FWMntFilDt('VEIACE_ENTRADA','Igual a','10/11/2016','D','==','SQL')"
   	   nOperIgual := At("Igual a",cFtrAdvAux)   	   
   	   nInicio := At("#",cFtrAdvAux)
   	   cFtrAdvAux := Stuff(cFtrAdvAux, nInicio,1," ")
   	   nFim := At("#",cFtrAdvAux)
   	   cFtrAdvAux := Stuff(cFtrAdvAux, nFim,1," ")
   	   cWhere  := SubStr( cFtrAdvAux,nInicio,(nFim-nInicio) )
   	   cWhere := StrTran(cWhere,'"',"")
   	   cWhere := StrTran(cWhere,"''","'")   
   	   bBloco := &("{|x|"+cWhere+"}")
   	   cWhere := Eval(bBloco)
   	   if nOperIgual > 0
         nStrDt := At("=",cWhere)   
   	     cWheredt := Substr(cWhere,(nStrDt+3),8)
   	     cWheredt := Substr(cWheredt,5,2)+'/'+Substr(cWheredt,7,2)+'/'+substr(cWheredt,1,4)
   	     cWheredt := ">= '"+cWheredt+" 00:00:00'"+" AND "+Substr(cWhere,1,(nStrDt-1))+" <= '"+cWheredt+" 23:59:59'"
   	     cWhere := Stuff(cWhere,(nStrDt),len(cWheredt), cWheredt)   	   
   	   else
   	     nStrDt := At("'",cWhere)   
   	     cWheredt := Substr(cWhere,(nStrDt+1),8)
   	     cWheredt := Substr(cWheredt,5,2)+'/'+Substr(cWheredt,7,2)+'/'+substr(cWheredt,1,4)+"'"
   	     cWhere := Stuff(cWhere,(nStrDt+1),len(cWheredt), cWheredt)
   	   endif   	    	   
      cFtrAdvAux :=  Stuff( cFtrAdvAux,nInicio, (nFim-nInicio),cWhere)
   	EndDo
	cFiltroAdv := cFtrAdvAux
	C928SELT(oBrowseP2,oTFolder,cFiltroAdv)
Return
