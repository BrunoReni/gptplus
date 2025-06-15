#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAC929.CH" 	

/*/{Protheus.doc} PRAC929
@author   Felipe Machado de Oliveira
@version  P12
@since    26/07/2012
@obs      2.2.18 a) Log de alterações no sistema
/*/
Function PRAC929()
	Local oDlg            := nil
	Local aCoors          := FWGetDialogSize(oMainWnd)
	Local oLayer          := nil
	Local cQuery          := ""	
	Local oBrowseT        := nil
	Local oBrowseL        := nil		
	Local oLeftGrid       := nil
	Local oTopGrid        := nil
	Local oRightGrid      := nil
	Local oPanelBottom	
	Local cAliasQy        := SGetNAlias()	
	Local oLbxL
	Local oLbxT	
	Local oSay
	Local oSay2
	local nList
	Local oPesquisa		 := nil
	Local oPainelLP       := nil
	Local oPainelLL       := nil
	Local cPesquisa       := "                                                   "
	Local oTButtonSearch  := nil	
	Private cConsultaEsp  := SuperGetMv('CONSULTA_RF_ESPECIFICO', .T., "")
	Private cVarDataIni   := nil
	Private cVarDataFim   := nil
	Private cAlias        := SCTBTMPG()
	Private oBrowseR      := nil		
	Private cTabela       := ""
	Private aArrayLGrid   := {}
	Private aArLGDesc     := {}	
	Private aArrayTGrid   := {} 
	Private aChaveTAB     := {}
		   
	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]
		
		oLayer := FWLayer():new()
      	oLayer:init(oDlg,.F.)
      	oLayer:addColumn('Col01',20,.F.)
      	oLayer:addColumn('Col02',80,.F.)
      	oLayer:addWindow('Col01','C1_Win01',STR0001,100,.F.,.F.,,,)
      	oLayer:addWindow('Col02','C1_Win02',STR0002,45,.F.,.F.,,,)      	
      	oLayer:addWindow('Col02','C1_Win03',STR0003,55,.F.,.F.,,,)      	
      	
      	oLeftGrid  := oLayer:getWinPanel('Col01','C1_Win01')
      	oTopGrid   := oLayer:getWinPanel('Col02','C1_Win02')
      	oRightGrid := oLayer:getWinPanel('Col02','C1_Win03')
      	
      	oPanelBottom  := TPanel():Create(oTopGrid,01,01,"",,,,,,10,15)
		oPanelBottom:Align := 4
		
      	oPainelLP := TPanel():Create(oLeftGrid,01,01,"",,,,,,10,15)
		oPainelLP:Align := CONTROL_ALIGN_TOP
		
		oPainelLL := TPanel():Create(oLeftGrid,01,01,"",,,,,,10,15)
		oPainelLL:Align := CONTROL_ALIGN_ALLCLIENT
	
		oTButton      := TButton():Create( oPanelBottom,01,01,STR0004,{|| C929SELECTAB()},40,10,,,,.T.,,,,,,)	
		oTButtonClose := TButton():Create( oPanelBottom,01,45,STR0005,{|| oDlg:End()},40,10,,,,.T.,,,,,,)		
		
		oSay := tSay():New(01,90,{|| ''},oPanelBottom,,,,,,.T.,CLR_RED,CLR_WHITE,40,10)
		oSay:SetText( STR0006 )
		
		cVarDataIni := DToC(Date() - 30)
		
		oVarDataIni := TGet():New( 01,120,{|u| if(PCount()>0,cVarDataIni := u,cVarDataIni)},;
		oPanelBottom,35,10,'99/99/9999',,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cVarDataIni,,,,)
				
		oSay2 := tSay():New(01,165,{|| ''},oPanelBottom,,,,,,.T.,CLR_RED,CLR_WHITE,40,10)
		oSay2:SetText( STR0007 )
		
		cVarDataFim := DToC(Date())
		
		oVarDataFim := TGet():New( 01,195,{|u| if(PCount()>0,cVarDataFim := u,cVarDataFim)},;
		oPanelBottom,35,10,'99/99/9999',,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cVarDataFim,,,,) 
      	
      	cQuery := "exec proc_rfb_s_parametro_tab_log_w"
				
		DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasQy,.T.,.F.)
		(cAliasQy)->(DbGotop())
		while (cAliasQy)->(!EOF())
			Aadd(aArrayLGrid,(cAliasQy)->(Fieldget(1)))
	        if !SEmpty((cAliasQy)->(Fieldget(2))) 
				Aadd(aArLGDesc,StrTran((cAliasQy)->(Fieldget(2)), CHR(10), ''))  
			else
				Aadd(aArLGDesc,'')
        	end			
			(cAliasQy)->(DbSkip())		
		EndDo	
		(cAliasQy)->(dbCloseArea())
		
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
		oColumns:SetData( &(" { || aArrayTGrid[oBrowseT:At(),2]}") )
		oColumns:SetTitle(STR0009)
		oColumns:SetSize(20)
		oBrowseT:SetColumns({oColumns})
		
		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayTGrid[oBrowseT:At(),3]}") )
		oColumns:SetTitle(STR0010)
		oColumns:SetSize(10)
		oBrowseT:SetColumns({oColumns})
		
		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayTGrid[oBrowseT:At(),4]}") )
		oColumns:SetTitle("Descrição")
		oColumns:SetSize(20)		
		oBrowseT:SetColumns({oColumns})	
		
		oBrowseT:Activate()				
	
		//@ 10,10 LISTBOX oLbxL FIELDS HEADER STR0001 SIZE 230,095 OF oPainelLL PIXEL ON CHANGE ;
		//{|| C929TGrid(oBrowseT,oLbxL,aArrayTGrid,"{|| cTabela := aArrayLGrid[oLbxL:nAt]}",oLayer)} CHANGE
		//oLbxL:bLine := {|| {aArrayLGrid[oLbxL:nAt,1]} }		
		//oLbxL:SetArray( aArrayLGrid )		
		//oLbxL:Align := 5		
		
		
		oLbxL := TListBox():Create(oPainelLL, 01, 01, {|u| if( Pcount()>0, nIdxList := u, ) }, aArrayLGrid, ;
			210, 095, ;
			{|| C929TGrid(oBrowseT,oLbxL,aArrayTGrid,"{|| cTabela := aArrayLGrid[oLbxL:nAt]}",oLayer)},;
			nil, nil, nil, .T., nil, nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil )
		oLbxL:Align := 5	
		oLbxL:Select(1)		
		
		oPesquisa := TGet():New( 01,01,{|u| if(PCount()>0,cPesquisa := u,cPesquisa)},;
			   oPainelLP,70,10,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPesquisa,,,,)
					   
		oTButtonSearch := TButton():Create( oPainelLP,02,72,STR0004,{|| C929FIND1(cPesquisa,oLbxL, aArrayLGrid)},30,10,,,,.T.,,,,,,)		
		
		oBrowseR := FWBrowse():New(oRightGrid)
		oBrowseR:SetDataTable()
		oBrowseR:SetAlias(cAlias)		
		oBrowseR:Activate()

	ACTIVATE MSDIALOG oDlg CENTERED
	
	SDelTb(cAlias)	
return

Function C929TGrid(oBrowseT,oLbxL,aArrayTGrid,cConteud,oLayer)	
	Local cQuery      := ""	
	Local i           := 1
	local nColSize    := 1
	Local oColumns    
	Local cAliasQy    := SGetNAlias()
	
	aArrayTGrid := {}    
	
	Eval(&(cConteud))
	
	oLayer:setWinTitle('Col02','C1_Win02','Campos da Tabela: '+STrim(STransType(cTabela))+" - "+STrim(STransType(aArLGDesc[oLbxL:nAt])))

	cQuery := "exec proc_s_campos_tab_log_w '"+STransType(cTabela)+"'"
				
	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasQy,.T.,.F.)
	(cAliasQy)->(DbGotop())
	while (cAliasQy)->(!EOF())
		Aadd(aArrayTGrid, {(cAliasQy)->(Fieldget(1)),(cAliasQy)->(Fieldget(2)),(cAliasQy)->(Fieldget(3)),(cAliasQy)->(Fieldget(4))})
		(cAliasQy)->(DbSkip())		
	EndDo
	
	aChaveTAB := aArrayTGrid
	
	(cAliasQy)->(dbCloseArea())
	
	oBrowseT:SetArray(aArrayTGrid)
	oBrowseT:UpdateBrowse()
		
return

Function C929SELECTAB()
	Local cAliasQy := SGetNAlias()	
	Local nCnt     := 0	
	Local oColumn
	Local nColSize := 0
	Local nMax     := 0
	Local nStart   := 0
	Local nReg     := 0
	Local aCampos  := {}
	Local aFields  := {}
	Local aSeek    := {}
	Local aStruct
	Local cSQL     := ""
	Local cCampoChave := ""
	Local cCpoRegOri := ""
	Local cJoinRegOr := "" 
	Local cTBTabelas  := GetNextAlias()	
	
	cCampoChave := C929RCFAD(cTabela)
	
	//cCampoChave      := AllTrim(aChaveTAB[1][1])	
	
	cJoinRegOr := C929JOIOR(cTabela)
	
	if cJoinRegOr <> ''
	  cCpoRegOri := " Isnull((SELECT Min(lga.log_datahora) FROM sara_log.."+STransType(cTabela)+" lga WHERE lga."+cCampoChave+" = a."+cCampoChave+" AND lga.log_operacao = 'I'), '') AS 'DATA_HORA_REG_ORIGINAL', "
	  cCpoRegOri += " Upper ((SELECT Min(lga.log_usuario) FROM sara_log.."+STransType(cTabela)+" lga WHERE lga."+cCampoChave+" = a."+cCampoChave+" AND lga.log_operacao = 'I'))  AS 'USUARIO_REG_ORIGINAL', "
	end if
		
	if cVarDataIni == nil .OR. cVarDataIni == '          '
		cVarDataIni := '01/01/1900'
	endif
	
	if cVarDataFim == nil .OR. cVarDataFim == '          '
		cVarDataFim := '01/01/2100'
	endif
	
	
	cSQL := "select CONVERT(VARCHAR(4), Datepart(year, (SELECT Min(lga.log_datahora) FROM  sara_log.."+STransType(cTabela)+" lga WHERE lga."+cCampoChave+" = a."+cCampoChave+" AND lga.log_operacao = 'I') )) + RIGHT('0000000000000'+CONVERT(VARCHAR(15), a."+cCampoChave+"), 13) + '.' + RIGHT('00'+CONVERT(VARCHAR(15), a.log_registro), 2)  AS Chave, "+;
	        cCpoRegOri+;
	        " Isnull(( CONVERT(VARCHAR(10), a.log_datahora, 103) + ' ' + CONVERT(VARCHAR(8), a.log_datahora, 108) ), '') AS 'DATA_HORA_REG_ATUAL',"+;
	        " upper (Isnull(b.usu_nome, a.log_usuario)) as 'USUARIO_REG_ATUAL', "+;									
	        " a.*, "+;
				"(case a.log_operacao "+;
					"when 'I' then "+;
						"'Inclusao' "+;
					"when 'U' then "+;
						"'Alteracao' "+;
					"when 'D' then "+;
						"'Exclusao' "+;
					"else null "+;
				"end) as 'Operacao', "+;				
              "case when len(a.log_usuario) = 12 then "+;
              "  substring(a.log_usuario,2,3)+'.'+substring(a.log_usuario,5,3)+'.'+substring(a.log_usuario,8,3)+'-'+substring(a.log_usuario,11,2) "+;
              "else "+;
              "  a.log_usuario " +;
              "end as 'cpf_formatado', "+;
              "upper(b.usu_perfil) as Perfil, "+;
              "' ' AS D_E_L_E_T, "+;
	          " ROW_NUMBER() OVER(ORDER BY a.log_datahora ASC) AS R_E_C_N_O_ "+;              								
			"from sara_log.."+STransType(cTabela)+" a "+;
				"left outer join tab_usuarios b "+;
				"on (a.log_usuario = b.usu_id) "+;
			" where a.log_operacao <> 'I' and a.log_datahora between '"+SDBDField(CToD(cVarDataIni))+" 00:00:00' and "+;
				"'"+SDBDField(CToD(cVarDataFim))+" 23:59:59' "
				
	//conout(cSQL)

	SPrintCon('SELECT * INTO '+cTBTabelas+ ' FROM ('+cSql+') AS T')
	TCSqlExec('SELECT * INTO '+cTBTabelas+ ' FROM ('+cSql+') AS T')
	
	SPrintCon("exec proc_altera_col_sql_din_w '"+cTBTabelas+"'")
	TCSqlExec("exec proc_altera_col_sql_din_w '"+cTBTabelas+"'")

	SPrintCon("Abriu a tabela " + cTBTabelas + " no alias " + cAliasQy)
	DbUseArea(.T.,'TOPCONN',TCGenQry(,,"select * from "+cTBTabelas),cAliasQy,.F.,.F.)
	
	aStruct := (cAliasQy)->(DBStruct())
	nMax := Len(aStruct)
	
	for nStart := 1 to nMax
		Aadd(aCampos, {'CP'+STrim(Str(nStart)), aStruct[nStart][2], aStruct[nStart][3], aStruct[nStart][4]})
	Next		
	
	SDelTbTmp(cAlias)
	SCriaTbTmp({aCampos, {'CP1'}}, cAlias)

	(cAliasQy)->(DBGoTop())
	nReg := 1
	While (cAliasQy)->(!Eof())
		(cAlias)->(DBAppend())
		for nStart := 1 to nMax
			If aStruct[nStart][2] == "N"
				(cAlias)->(FieldPut(nStart,val(Str((cAliasQy)->(FieldGet(nStart)),aStruct[nStart][3],aStruct[nStart][4]))))
			Else
				(cAlias)->(FieldPut(nStart,(cAliasQy)->(Fieldget(nStart))))
			EndIf			
		next
		(cAliasQy)->(dbSkip())
	EndDo
	
	SPrintCon("Montou a tabela temporaria")
		
	(cAliasQy)->(dbCloseArea())
	(cAlias)->(dbCommit())
	(cAlias)->(DBGoTop())

	for nStart := 1 to nMax
		Aadd(aFields, {'CP'+STrim(Str(nStart)), 'CP'+STrim(Str(nStart)), aStruct[nStart][2], aStruct[nStart][3], aStruct[nStart][4], ""})
		Aadd( aSeek, { 'CP'+STrim(Str(nStart)) , {{"",aStruct[nStart][2], aStruct[nStart][3],aStruct[nStart][4],'CP'+STrim(Str(nStart))}} } )
	next
		
	nColSize := Len(oBrowseR:aColumns)
	for nStart := 1 to nColSize
		oBrowseR:DelColumn(nStart)
	next

	nMax := Len(aStruct)
	for nStart := 1 to nMax
		oColumn := nil
	
		oColumn := FWBrwColumn():New()
		cCampo := 'CP'+STrim(Str(nStart))
		cCampo := "{|| "+cCampo+"}"
		oColumn:SetData(  &(cCampo) )

		oColumn:SetTitle(aStruct[nStart][1])
		oColumn:SetSize(aStruct[nStart][3])
	
		oBrowseR:SetColumns({oColumn})
	next
	
	cCampoChave := " "

	nColSize := nMax

	oBrowseR:updateBrowse()
	
	SPrintCon("Realizou a consulta e ira apagar a tabela: " + cTBTabelas)
	TCSqlExec('drop table '+cTBTabelas)
	SPrintCon("Apagou a tabela : " + cTBTabelas)
	
return

function C929FIND1(cPesquisa,oLbxL, aArrayLGrid)
	Local nPos := 0
	
	nPos := Ascan(aArrayLGrid, { |x, y| (AllTrim(cPesquisa) $ AllTrim(x)) })
	if nPos > 0
		oLbxL:Select(nPos)
	endif
return

/*/{Protheus.doc} C929RCFAD
@author   Luan Eli Oliveira Oliveira
@version  P12
@since    28/06/2013
@obs      Retorno do campo conforme Ato Declaratório com registro +
          alteração incremental referente ao log de operações para as mesmas tabelas
          do item 2.2.14 - CHAMADO TEWW81
/*/

static function C929RCFAD(cTab)
return AllTrim(aChaveTAB[1][1])

/*/{Protheus.doc} C929JOIOR
@author   Marcelo Nunes
@version  P12
@since    19/09/2014
@obs      Retorno com comando left join para buscar os dados do registro original(inserção) do registro - CHAMADO TQN317
/*/

static function C929JOIOR(cTab)
  Local cRetorno := ""
  Local cWhere := ""
  Local cWhereX2 := ""
  Local cQuery := ""
  Local cAliasKey := GetNextAlias()
  Local cOwnerSara := SuperGetMV('MV_WMSSOWN', .F., 'sara_db.')
  	  
  cOwnerSara := SUBSTR(cOwnerSara,1,Len(Alltrim(cOwnerSara))-1)	  
  	  
  cQuery += " select distinct column_name" 
  cQuery += "   from "+cOwnerSara+"information_schema.key_column_usage"
  cQuery += "  where table_name = '"+Alltrim(cTab)+"'"
  cQuery += "    and Upper(column_name) <> 'LOG_REGISTRO'"
  cQuery += "    and constraint_name like 'pk%'"
         
  cQuery := ChangeQuery(cQuery)
  DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasKey,.F.,.T.)

  dbSelectArea(cAliasKey)
  (cAliasKey)->(DbGoTop())
  while (cAliasKey)->(!EOF())
    if Alltrim((cAliasKey)->(Fieldget(1))) == "cnt_id" .AND. Alltrim(cTab) == "rel_dent_cnt"
      (cAliasKey)->(DbSkip()) 
    endif
   
    if Alltrim(cWhere) == ""
      cWhere   += " x."+Alltrim((cAliasKey)->(Fieldget(1)))+" = a."+Alltrim((cAliasKey)->(Fieldget(1)))
      cWhereX2 += " x2."+Alltrim((cAliasKey)->(Fieldget(1)))+" = a."+Alltrim((cAliasKey)->(Fieldget(1)))
      //cRetorno := "left join sara_log.."+Alltrim(cTab)+" x on x."+Alltrim((cAliasKey)->(Fieldget(1)))+" = a."+Alltrim((cAliasKey)->(Fieldget(1)))
    else
      cWhere   += " and x."+Alltrim((cAliasKey)->(Fieldget(1)))+" = a."+Alltrim((cAliasKey)->(Fieldget(1)))
      cWhereX2 += " and x2."+Alltrim((cAliasKey)->(Fieldget(1)))+" = a."+Alltrim((cAliasKey)->(Fieldget(1)))
      //cRetorno += " and x."+Alltrim((cAliasKey)->(Fieldget(1)))+" = a."+Alltrim((cAliasKey)->(Fieldget(1))) 
    end if           
    (cAliasKey)->(DbSkip())       
  EndDo 
  (cAliasKey)->(dbCloseArea()) 
  if Alltrim(cWhere) <> "" 
     cRetorno += " left join sara_log.."+Alltrim(cTab)+" x on "+cWhere
     cRetorno += " and x.log_operacao = 'I'"
     cRetorno += " and x.log_registro = IsNull((select min(x2.log_registro) from sara_log.."+Alltrim(cTab)+" x2 where "+cWhereX2
     cRetorno += " and x2.log_operacao = 'I'),0)" 
     cRetorno += " left join tab_usuarios y on y.usu_id = x.log_usuario "
  end if
  
return cRetorno


