#INCLUDE "TOTVS.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "DBINFO.CH"
#INCLUDE "PRAA805.CH"


/*/{Protheus.doc} PRAA805
@author   Aline Briesemeister Xavier
@version  P12
@since    28/11/2013
@obs      Agendamento/Permissão de acesso
/*/
Function PRAA805()
	Local oDlg           := nil
	Local aCoors         := FWGetDialogSize(oMainWnd)
	local aTFolder       := nil
	local oTFolder       := nil
	Local oLayerP        := nil //Layer Principal	
	Local oLayerP1       := nil //Layer Page1
	Local oLayerP2       := nil //Layer Page2
	Local oLayerP3       := nil //Layer Page3	
	Local oGrid           := nil //Grid Principal
	Local oGridP1T        := nil //Grid P1 - Top
	Local oGridP1C        := nil //Grid P1 - Center
	Local oGridP1B        := nil //Grid P1 - Bottom
	Local oGridP2T        := nil //Grid P2 - Top
	Local oGridP2C        := nil //Grid P2 - Center
	Local oGridP2B        := nil //Grid P2 - Bottom
	Local oGridP3T        := nil //Grid P3 - Top
	Local oGridP3C        := nil //Grid P3 - Center
	Local oGridP3B        := nil //Grid P3 - Bottom
	Local oPanel          := nil //Panel Principal
	Local oPanel1         := nil
	Local oPanelP1T       := nil //Panel P1 - Top
	Local oPanelP1C       := nil //Panel P1 - Center
	Local oPanelP1B       := nil //Panel P1 - Bottom
	Local oPanelP2T       := nil //Panel P2 - Top
	Local oPanelP2C       := nil //Panel P2 - Center
	Local oPanelP2B       := nil //Panel P2 - Bottom
	Local oPanelP3T       := nil //Panel P3 - Top
	Local oPanelP3C       := nil //Panel P3 - Center
	Local oPanelP3B       := nil //Panel P3 - Bottom
	Local oPanelBottom    := nil //Panel P3 - Bottom
	Local oTButtonRP      := nil
	Local oTButtonExit    := nil
	Local cQuery           := ""
	Local oSayEmp          := nil
	Local oSayAdm          := nil
	Local nIndex
	Static cVarEmp
	Static cVarAdm 
	Static cDescEmp
	Static cDescAdm
	Static cEmpPai
	Static cPCId
	Static cUsuario                                                
	Static lAbreTela		:= .F.
	Static cAlias        := SGetNAlias()
	Static cAliasG       := SGetNAlias()	
	Static cTabela       := ""
	Local oBrowse       := nil //Browse Principal
	Local oBrowseP1T    := nil //Browse Page1 - Top	
	Local oBrowseP1C    := nil //Browse Page1 - Center
	Local oBrowseP1B    := nil //Browse Page1 - Bottom
	Local oBrowseP2T    := nil //Browse Page2 - Top
	Local oBrowseP2C    := nil //Browse Page2 - Center
	Local oBrowseP2B    := nil //Browse Page2 - Bottom
	Local oBrowseP3T    := nil //Browse Page3 - Top
	Local oBrowseP3C    := nil //Browse Page3 - Center
	Local oBrowseP3B    := nil //Browse Page3 - Bottom
	Private aArray       := {} //Array Principal
	Private aArrayP1T    := {} //Array P1 - Top
	Private aArrayP1C    := {} //Array P1 - Center
	Private aArrayP1B    := {} //Array P1 - Bottom
	Private aArrayP2T    := {} //Array P2 - Top
	Private aArrayP2C    := {} //Array P2 - Center
	Private aArrayP2B    := {} //Array P2 - Bottom
	Private aArrayP3T    := {} //Array P3 - Top
	Private aArrayP3C    := {} //Array P3 - Center
	Private aArrayP3B    := {} //Array P3 - Bottom
	
	RET_USER()

	PRAA805_SelecionaEmpresa()

	if lAbreTela 
	
		DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

		oLayerP := FWLayer():new()
		oLayerP:init(oDlg,.T.)
      	oLayerP:addColumn('Col',100,.F.)      	
      	oLayerP:addWindow('Col','Col_Win1',"",100,.F.,.F.,,,)
      	//oLayerP:addWindow('Col','Col_Win1',"",12,.F.,.F.,,,)
      	//oLayerP:addWindow('Col','Col_Win2',"",87,.F.,.F.,,,)

      	oPanel := TPanel():Create(oLayerP:getWinPanel('Col','Col_Win1'),01,01,"",,,,,,10,20)
		oPanel :Align := CONTROL_ALIGN_TOP

		oSayEmp := tSay():New(03,01,{|| ''},oPanel,,,,,,.T.,CLR_BLACK,CLR_WHITE,40,10)
		oSayEmp:SetText(STR0001)		

		oVarEmp := TGet():New(01,40,{|u| if(PCount()>0,cDescEmp := u,cDescEmp)},;
		oPanel,120,10,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cDescEmp,,,,)

		oSayAdm := tSay():New(03,170,{|| ''},oPanel,,,,,,.T.,CLR_BLACK,CLR_WHITE,40,10)
		oSayAdm:SetText(STR0002)

		oVarAdm := TGet():New(01,220,{|u| if(PCount()>0,cUsuario := u,cUsuario)},;
		oPanel,120,10,,,,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cUsuario,,,,)
		
		oTButtonRP   := TButton():Create( oPanel,01,360,STR0009,{||PRAA805_ReplicaPermissao(oTFolder, aArrayP1T[oBrowseP1T:At(), 4], cPCId)},60,10,,,,.T.,,,,,,)		
		oTButtonExit := TButton():Create( oPanel,01,430,STR0010,{||oDlg:End()},40,10,,,,.T.,,,,,,)
		
      	oPanel1 := TPanel():Create(oLayerP:getWinPanel('Col','Col_Win1'),30,30,"",,,,,,10,20)
		oPanel1:Align := CONTROL_ALIGN_ALLCLIENT
		
		
		aTFolder := { STR0003, STR0004,STR0005 }
		//oTFolder := TFolder():New( 0,0,aTFolder,,oLayerP:getWinPanel('Col','Col_Win2'),,,,.T.,,600,320 )
		oTFolder := TFolder():New( 0,0,aTFolder,,oPanel1,,,,.T.,,600,320 )
		oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
				
		oLayerP1 := FWLayer():new()
      	oLayerP1:init(oTFolder:aDialogs[1],.T.)
      	oLayerP1:addColumn('Col01',35,.F.)
      	oLayerP1:addColumn('Col02',33,.F.)
      	oLayerP1:addColumn('Col03',32,.F.)

      	oLayerP1:addWindow('Col01','C1_Win01',STR0006,100,.F.,.F.,,,)
      	oLayerP1:addWindow('Col02','C1_Win02',STR0007,100,.F.,.F.,,,)
      	oLayerP1:addWindow('Col03','C1_Win03',STR0008,100,.F.,.F.,,,)
      	
      	oGridP1T := oLayerP1:getWinPanel('Col01','C1_Win01')
      	oGridP1C := oLayerP1:getWinPanel('Col02','C1_Win02')
      	oGridP1B := oLayerP1:getWinPanel('Col03','C1_Win03')
      	
      	oPanelP1T := TPanel():Create(oGridP1T,01,01,"",,,,,,10,10)
		oPanelP1T:Align := CONTROL_ALIGN_ALLCLIENT

		oPanelP1C := TPanel():Create(oGridP1C,01,01,"",,,,,,10,10)
		oPanelP1C:Align := CONTROL_ALIGN_ALLCLIENT

      	oPanelP1B  := TPanel():Create(oGridP1B,01,01,"",,,,,,10,10)
		oPanelP1B:Align := CONTROL_ALIGN_ALLCLIENT

      	oLayerP2 := FWLayer():new()
      	oLayerP2:init(oTFolder:aDialogs[2],.T.)
      	oLayerP2:addColumn('Col04',35,.F.)
      	oLayerP2:addColumn('Col05',33,.F.)
      	oLayerP2:addColumn('Col06',32,.F.)

      	oLayerP2:addWindow('Col04','C2_Win01',STR0007,100,.F.,.F.,,,)
      	oLayerP2:addWindow('Col05','C2_Win02',STR0008,100,.F.,.F.,,,)
      	oLayerP2:addWindow('Col06','C2_Win03',STR0006,100,.F.,.F.,,,)
      	
      	oGridP2T := oLayerP2:getWinPanel('Col04','C2_Win01')
      	oGridP2C := oLayerP2:getWinPanel('Col05','C2_Win02')
      	oGridP2B := oLayerP2:getWinPanel('Col06','C2_Win03')
      	
      	oPanelP2T := TPanel():Create(oGridP2T,01,01,"",,,,,,10,10)
		oPanelP2T:Align := CONTROL_ALIGN_ALLCLIENT

		oPanelP2C := TPanel():Create(oGridP2C,01,01,"",,,,,,10,10)
		oPanelP2C:Align := CONTROL_ALIGN_ALLCLIENT

      	oPanelP2B  := TPanel():Create(oGridP2B,01,01,"",,,,,,10,10)
		oPanelP2B:Align := CONTROL_ALIGN_ALLCLIENT
		
		oLayerP3 := FWLayer():new()
		oLayerP3:init(oTFolder:aDialogs[3],.T.)
      	oLayerP3:addColumn('Col07',35,.F.)
      	oLayerP3:addColumn('Col08',33,.F.)
      	oLayerP3:addColumn('Col09',32,.F.)
      	
      	oLayerP3:addWindow('Col07','C3_Win01',STR0008,100,.F.,.F.,,,)
      	oLayerP3:addWindow('Col08','C3_Win02',STR0007,100,.F.,.F.,,,)
      	oLayerP3:addWindow('Col09','C3_Win03',STR0006,100,.F.,.F.,,,)
      	
      	oGridP3T := oLayerP3:getWinPanel('Col07','C3_Win01')
      	oGridP3C := oLayerP3:getWinPanel('Col08','C3_Win02')
      	oGridP3B := oLayerP3:getWinPanel('Col09','C3_Win03')
      	
      	oPanelP3T := TPanel():Create(oGridP3T,01,01,"",,,,,,10,10)
		oPanelP3T:Align := CONTROL_ALIGN_ALLCLIENT

		oPanelP3C := TPanel():Create(oGridP3C,01,01,"",,,,,,10,10)
		oPanelP3C:Align := CONTROL_ALIGN_ALLCLIENT

      	oPanelP3B  := TPanel():Create(oGridP3B,01,01,"",,,,,,10,10)
		oPanelP3B:Align := CONTROL_ALIGN_ALLCLIENT		

      	
      	/////////////////////////////Page 1/////////////////////////////////////
      	//Query carga usuários Page 1
      	cQuery := ''
		cQuery += ' select a.usu_id, '
		cQuery += '        b.usu_nome, '
		cQuery += ' 		 case a.puc_bloqueado '
		cQuery += " 		    when 1 then 'Sim'     "
		cQuery += " 		    when 0 then 'Não'     "
		cQuery += ' 		 end as Bloqueado,   '
		cQuery += ' 		 case a.puc_administrador '
		cQuery += " 		    when 1 then 'Sim'     "
		cQuery += " 		    when 0 then 'Não'     "
		cQuery += ' 		 end as Administrador,   '		 
		cQuery += ' 	 	 a.puc_id '		
		cQuery += '   from tab_portal_usuario_cliente a '
		cQuery += '		 left join tab_usuarios b on a.usu_id = b.usu_id '
		cQuery += '  where a.pc_id = '+STransType(cPCId)
      	
		aArrayP1T:=nil
		aArrayP1T:={}		
		
		DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasG,.T.,.F.)
		(cAliasG)->(DbGotop())
		while (cAliasG)->(!EOF())		    
			Aadd(aArrayP1T,{(cAliasG)->(Fieldget(2)),(cAliasG)->(Fieldget(3)),(cAliasG)->(Fieldget(4)),(cAliasG)->(Fieldget(1)),(cAliasG)->(Fieldget(5))})
	        (cAliasG)->(DbSkip())
		EndDo
		(cAliasG)->(dbCloseArea())
		
		//Campos Tabela Top
      	oBrowseP1T := FWBrowse():New(oGridP1T)
		oBrowseP1T:DisableConfig()
		oBrowseP1T:DisableReport()
		oBrowseP1T:SetDataArray()
		oBrowseP1T:SetArray(aArrayP1T)
								
		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP1T[oBrowseP1T:At(),1]}") )
		oColumns:SetTitle(STR0006)
		oColumns:SetSize(30)
		oBrowseP1T:SetColumns({oColumns})

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP1T[oBrowseP1T:At(),2]}") )
		oColumns:SetTitle(STR0011)
		oColumns:SetSize(1)
		oBrowseP1T:SetColumns({oColumns})
		
		oColumns :=FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP1T[oBrowseP1T:At(),3]}") )
		oColumns:SetTitle(STR0012)
		oColumns:SetSize(1)
		oBrowseP1T:SetColumns({oColumns})

		oBrowseP1T:Activate()
		
		//Campos Tabela Center
      	oBrowseP1C := FWBrowse():New(oGridP1C)
		oBrowseP1C:DisableConfig()
		oBrowseP1C:DisableReport()
		oBrowseP1C:SetDataArray()
		oBrowseP1C:SetArray(aArrayP1C)		

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP1C[oBrowseP1C:At(),3]}") )
		oColumns:SetTitle(STR0007)
		oColumns:SetSize(15)
		oBrowseP1C:SetColumns({oColumns})
		
		
		//Campos Tabela Bottom
      	oBrowseP1B := FWBrowse():New(oGridP1B)
		oBrowseP1B:DisableConfig()
		oBrowseP1B:DisableReport()
		oBrowseP1B:SetDataArray()
		oBrowseP1B:SetArray(aArrayP1B)

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP1B[oBrowseP1B:At(),1]}") )
		oColumns:SetTitle(STR0013)
		oColumns:SetSize(1)
		oBrowseP1B:SetColumns({oColumns})

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP1B[oBrowseP1B:At(),2]}") )
		oColumns:SetTitle(STR0008)
		oColumns:SetSize(50)
		oBrowseP1B:SetColumns({oColumns})

		oBrowseP1T:SetDoubleClick({||A805P1T(aArrayP1T,oBrowseP1T:At(),oBrowseP1T:ColPos(.T.))} ) 
		oBrowseP1T:SetArray(aArrayP1T)
		oBrowseP1T:UpdateBrowse()
		
		if len(aArrayP1T)>0 
			A805AGC1(aArrayP1T[1,4],oBrowseP1C,oBrowseP1B)
		endif
		
		if len(aArrayP1C)>0 
			A805AGB1(aArrayP1T[1,4],aArrayP1C[1,1],oBrowseP1B)
		endif

		oBrowseP1C:SetArray(aArrayP1C)
		oBrowseP1C:UpdateBrowse()
		
		oBrowseP1B:SetDoubleClick({||A805P1B(aArrayP1B,oBrowseP1B:At(),oBrowseP1B:ColPos(.T.))} )	
		oBrowseP1B:SetArray(aArrayP1B)
		oBrowseP1B:UpdateBrowse()
		
		oBrowseP1T:SetChange({||A805AGC1(aArrayP1T[oBrowseP1T:At(),4],oBrowseP1C,oBrowseP1B)})
		
		oBrowseP1C:Activate()
		oBrowseP1B:Activate()

			
		/////////////////////////////Page 2/////////////////////////////////////
		//Query carga Funcionalidade Page 2
      	cQuery := ''
		cQuery += " select distinct rtrim(c.mnu_id)+'/'+rtrim(c.mod_id) as codigo_menu, "
		cQuery += '        g.mnu_descricao, '
		cQuery += '        c.pcm_id '
		cQuery += '   from tab_portal_cliente a '
		cQuery += ' 	 	 inner join tab_portal_usuario_cliente b on a.pc_id = b.pc_id '
		cQuery += '   		 left outer join tab_usuarios f on b.usu_id = f.usu_id '
		cQuery += '		 left outer join rel_portal_cliente_menu c on (a.pc_id = c.pc_id and c.pcm_bloqueado = 0) '
		cQuery += '        inner join tab_menu g on (c.mnu_id = g.mnu_id and c.mod_id = g.mod_id) '
        cQuery += '        left outer join tab_portal_acesso_info d on (c.pcm_id = d.pcm_id and d.pai_bloqueado = 0) '
        cQuery += '        left outer join tab_clientes h on d.cli_id = h.cli_id '
        cQuery += '        left outer join tab_grupos i on d.gru_id = i.gru_id '
        cQuery += '        left outer join rel_portal_usu_menu_info e on (d.pai_id = e.pai_id and b.puc_id = e.puc_id) '
		cQuery += '  where a.pc_id = '+STransType(cPCId)
		
		aArrayP2T:=nil
		aArrayP2T:={}		
		DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasG,.T.,.F.)
		(cAliasG)->(DbGotop())
		while (cAliasG)->(!EOF())		    
			Aadd(aArrayP2T,{(cAliasG)->(Fieldget(2)),(cAliasG)->(Fieldget(1)),(cAliasG)->(Fieldget(3))})
	        (cAliasG)->(DbSkip())
		EndDo
		(cAliasG)->(dbCloseArea())
		
		//Campos Page 2
		//Campos Tabela Top 
      	oBrowseP2T := FWBrowse():New(oGridP2T)
		oBrowseP2T:DisableConfig()
		oBrowseP2T:DisableReport()
		oBrowseP2T:SetDataArray()
		oBrowseP2T:SetArray(aArrayP2T)

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP2T[oBrowseP2T:At(),1]}") )
		oColumns:SetTitle(STR0007)
		oColumns:SetSize(15)
		oBrowseP2T:SetColumns({oColumns})		
		
		oBrowseP2T:Activate()
		
		//Campos Tabela Center
      	oBrowseP2C := FWBrowse():New(oGridP2C)
		oBrowseP2C:DisableConfig()
		oBrowseP2C:DisableReport()
		oBrowseP2C:SetDataArray()
		oBrowseP2C:SetArray(aArrayP2C)

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP2C[oBrowseP2C:At(),2]}") )
		oColumns:SetTitle(STR0008)
		oColumns:SetSize(50)
		oBrowseP2C:SetColumns({oColumns})

		//Campos Tabela Bottom 
      	oBrowseP2B := FWBrowse():New(oGridP2B)
		oBrowseP2B:DisableConfig()
		oBrowseP2B:DisableReport()
		oBrowseP2B:SetDataArray()
		oBrowseP2B:SetArray(aArrayP2B)
		
		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP2B[oBrowseP2B:At(),1]}") )
		oColumns:SetTitle(STR0013)
		oColumns:SetSize(1)
		oBrowseP2B:SetColumns({oColumns})
		
		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP2B[oBrowseP2B:At(),5]}") )
		oColumns:SetTitle(STR0006)
		oColumns:SetSize(30)
		oBrowseP2B:SetColumns({oColumns})		
		
		oBrowseP2T:SetArray(aArrayP2T)
		oBrowseP2T:UpdateBrowse()
		
		if len(aArrayP2T)>0		
			A805AGC2(aArrayP2T[1,3],oBrowseP2C,oBrowseP2B)
		endif
		
		if len(aArrayP2C)>0
			A805AGB2(aArrayP2T[1,3],aArrayP2C[1,3],aArrayP2C[1,4],oBrowseP2B)
		endif	
			
		oBrowseP2C:SetArray(aArrayP2C)
		oBrowseP2C:UpdateBrowse()
		oBrowseP2B:SetDoubleClick({||A805P2B(aArrayP2B,oBrowseP2B:At(),oBrowseP2B:ColPos(.T.))} )	
		oBrowseP2B:SetArray(aArrayP2B)
		oBrowseP2B:UpdateBrowse()
		
		oBrowseP2T:SetChange({||A805AGC2(aArrayP2T[oBrowseP2T:At(),3],oBrowseP2C,oBrowseP2B)})
		
		oBrowseP2C:Activate()
		oBrowseP2B:Activate()

		/////////////////////////////Page 3/////////////////////////////////////		
		//Query carga Clientes Page 3
      	cQuery := ''
		cQuery += ' select distinct d.cli_id, '
		cQuery += '        d.gru_id, '
		cQuery += '		 case       '
        cQuery += '           when d.cli_id is null then i.gru_nome '
        cQuery += '           when d.gru_id is null then h.cli_nome '
        cQuery += '        end as cliente_info '
		cQuery += '   from tab_portal_cliente a '
		cQuery += ' 	 	 inner join tab_portal_usuario_cliente b on a.pc_id = b.pc_id '
		cQuery += '   		 left outer join tab_usuarios f on b.usu_id = f.usu_id '
		cQuery += '		 left outer join rel_portal_cliente_menu c on (a.pc_id = c.pc_id and c.pcm_bloqueado = 0) '
		cQuery += '        inner join tab_menu g on (c.mnu_id = g.mnu_id and c.mod_id = g.mod_id) '
        cQuery += '        left outer join tab_portal_acesso_info d on (c.pcm_id = d.pcm_id and d.pai_bloqueado = 0) '
        cQuery += '        left outer join tab_clientes h on d.cli_id = h.cli_id '
        cQuery += '        left outer join tab_grupos i on d.gru_id = i.gru_id '
        cQuery += '        left outer join rel_portal_usu_menu_info e on (d.pai_id = e.pai_id and b.puc_id = e.puc_id) '
		cQuery += '  where a.pc_id = '+STransType(cPCId)

		aArrayP3T:=nil
		aArrayP3T:={}		
		DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasG,.T.,.F.)
		(cAliasG)->(DbGotop())
		while (cAliasG)->(!EOF())		    
			Aadd(aArrayP3T,{(cAliasG)->(Fieldget(3)),(cAliasG)->(Fieldget(1)),(cAliasG)->(Fieldget(2))})
			(cAliasG)->(DbSkip())
		EndDo
		
		//Campos Page 3
		//Campos Tabela Top 
      	oBrowseP3T := FWBrowse():New(oGridP3T)
		oBrowseP3T:DisableConfig()
		oBrowseP3T:DisableReport()
		oBrowseP3T:SetDataArray()
		oBrowseP3T:SetArray(aArrayP3T)

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP3T[oBrowseP3T:At(),1]}") )
		oColumns:SetTitle(STR0008)
		oColumns:SetSize(50)
		oBrowseP3T:SetColumns({oColumns})	
		
		oBrowseP3T:Activate()
		
		//Campos Tabela Center
      	oBrowseP3C := FWBrowse():New(oGridP3C)
		oBrowseP3C:DisableConfig()
		oBrowseP3C:DisableReport()
		oBrowseP3C:SetDataArray()
		oBrowseP3C:SetArray(aArrayP3C)

		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP3C[oBrowseP3C:At(),2]}") )
		oColumns:SetTitle(STR0007)
		oColumns:SetSize(15)
		oBrowseP3C:SetColumns({oColumns})			

		//Campos Tabela Bottom 
      	oBrowseP3B := FWBrowse():New(oGridP3B)
		oBrowseP3B:DisableConfig()
		oBrowseP3B:DisableReport()
		oBrowseP3B:SetDataArray()
		oBrowseP3B:SetArray(aArrayP3B)
		
		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP3B[oBrowseP3B:At(),1]}") )
		oColumns:SetTitle(STR0013)
		oColumns:SetSize(1)
		oBrowseP3B:SetColumns({oColumns})
		
		oColumns := FWBrwColumn():New()
		oColumns:SetData( &(" { || aArrayP3B[oBrowseP3B:At(),5]}") )
		oColumns:SetTitle(STR0006)
		oColumns:SetSize(30)
		oBrowseP3B:SetColumns({oColumns})
		
		oBrowseP3T:SetArray(aArrayP3T)
		oBrowseP3T:UpdateBrowse()

		oBrowseP3C:SetArray(aArrayP3C)
		oBrowseP3C:UpdateBrowse()
		
		oBrowseP3B:SetDoubleClick({||A805P3B(aArrayP3B,oBrowseP3B:At(),oBrowseP3B:ColPos(.T.))} )	
		oBrowseP3B:SetArray(aArrayP3B)
		oBrowseP3B:UpdateBrowse()
		
		oBrowseP3T:SetChange({||A805AGC3(aArrayP3T[oBrowseP3T:At(),2],aArrayP3T[oBrowseP3T:At(),3],oBrowseP3C,oBrowseP3B)})
		
		if len(aArrayP3T)> 0 
			A805AGC3(aArrayP3T[1,2],aArrayP3T[1,3],oBrowseP3C,oBrowseP3B)
		endif
		
		if len(aArrayP3C) > 0
			A805AGB3(aArrayP3C[1,3],aArrayP3T[1,2],aArrayP3T[1,3],oBrowseP3B)
		endif
		
		oBrowseP3C:Activate()
		oBrowseP3B:Activate()
			
       
	ACTIVATE MSDIALOG oDlg CENTERED
	
	SDelTbTmp(cAlias)
	SDelTbTmp(cAliasG)
endif 

Function A805P1T(aArrayP1T,nLinha,nCol)
	local cSQL := ''
		
	IF alltrim(aArrayP1T[nLinha,nCol]) == 'Sim'
		aArrayP1T[nLinha,nCol]:= 'Não'
			
		if nCol == 3 //Adm
			//TCSQLExec("exec proc_portal_usuario_cliente "+Str(aArrayP1T[nLinha,5]) + ",0,null")
			cSQL := "proc_diu_portal_usu_cli 3, "+Str(aArrayP1T[nLinha,5])+", 0, null, 0, null, "+IIF(aArrayP1T[nLinha,2] == 'Sim','1','0')+", null"
			TCSQLExec(cSQL)
		elseif nCol == 2 //Bloq
			//TCSQLExec("exec proc_portal_usuario_cliente "+Str(aArrayP1T[nLinha,5]) + ",null,0")
			cSQL := "proc_diu_portal_usu_cli 3, "+Str(aArrayP1T[nLinha,5])+", 0, null, "+IIF(aArrayP1T[nLinha,3] == 'Sim','1','0')+", null, 0, null"
			TCSQLExec(cSQL)			
		endif
	else
		IF alltrim(aArrayP1T[nLinha,nCol]) == 'Não'
			aArrayP1T[nLinha,nCol]:= 'Sim'
			if nCol == 3
				//TCSQLExec("exec proc_portal_usuario_cliente "+Str(aArrayP1T[nLinha,5]) + ",1,null")
				cSQL := "proc_diu_portal_usu_cli 3, "+Str(aArrayP1T[nLinha,5])+", 0, null, 1, null, "+IIF(aArrayP1T[nLinha,2] == 'Sim','1','0')+", null"
				TCSQLExec(cSQL)
			elseif nCol == 2
				//TCSQLExec("exec proc_portal_usuario_cliente "+Str(aArrayP1T[nLinha,5]) + ",null,1")
				cSQL := "proc_diu_portal_usu_cli 3, "+Str(aArrayP1T[nLinha,5])+", 0, null, "+IIF(aArrayP1T[nLinha,3] == 'Sim','1','0')+", null, 1, '"+SDBDate(Date(), Time())+"'"
				TCSQLExec(cSQL)
			endif
		endif
	endif	
return 

Function A805P1B(aArrayP1B,nLinha,nCol)	
	IF alltrim(aArrayP1B[nLinha,nCol]) == 'Sim'
		aArrayP1B[nLinha,nCol]:= 'Não'
		if nCol == 1
			TCSQLExec("exec proc_rel_portal_usu_menu 0,"+AllTrim(Str(aArrayP1B[nLinha,5]))+","+AllTrim(Str(aArrayP1B[nLinha,6]))+","+AllTrim(Str(aArrayP1B[nLinha,7])))
		endif
	else
		IF alltrim(aArrayP1B[nLinha,nCol]) == 'Não'
			aArrayP1B[nLinha,nCol]:= 'Sim'
			if nCol == 1
				TCSQLExec("exec proc_rel_portal_usu_menu 1,null,"+AllTrim(Str(aArrayP1B[nLinha,6]))+","+AllTrim(Str(aArrayP1B[nLinha,7])))
			endif
		endif
	endif
return

Function A805P2B(aArrayP2B,nLinha,nCol)	
	IF alltrim(aArrayP2B[nLinha,nCol]) == 'Sim'
		aArrayP2B[nLinha,nCol]:= 'Não'
		if nCol == 1
			TCSQLExec("exec proc_rel_portal_usu_menu 0,"+AllTrim(Str(aArrayP2B[nLinha,7]))+","+AllTrim(Str(aArrayP2B[nLinha,8]))+","+AllTrim(Str(aArrayP2B[nLinha,9])))
		endif
	else
		IF alltrim(aArrayP2B[nLinha,nCol]) == 'Não'
			aArrayP2B[nLinha,nCol]:= 'Sim'
			if nCol == 1
				TCSQLExec("exec proc_rel_portal_usu_menu 1,null,"+AllTrim(Str(aArrayP2B[nLinha,8]))+","+AllTrim(Str(aArrayP2B[nLinha,9])))
			endif
		endif
	endif
return  

Function A805P3B(aArrayP3B,nLinha,nCol)	
	IF alltrim(aArrayP3B[nLinha,nCol]) == 'Sim'
		aArrayP3B[nLinha,nCol]:= 'Não'
		if nCol == 1
			TCSQLExec("exec proc_rel_portal_usu_menu 0,"+AllTrim(Str(aArrayP3B[nLinha,7]))+","+AllTrim(Str(aArrayP3B[nLinha,8]))+","+AllTrim(Str(aArrayP3B[nLinha,9])))
		endif
	else
		IF alltrim(aArrayP3B[nLinha,nCol]) == 'Não'
			aArrayP3B[nLinha,nCol]:= 'Sim'
			if nCol == 1
				TCSQLExec("exec proc_rel_portal_usu_menu 1,null,"+AllTrim(Str(aArrayP3B[nLinha,8]))+","+AllTrim(Str(aArrayP3B[nLinha,9])))
			endif
		endif
	endif
return  

/*/{Protheus.doc} PRAA805
@author   Aline Briesemeister Xavier
@version  P12
@since    11/12/2013
@obs      Funcao de retorno do ID do usuário logado.
/*/
static function RET_USER()	
   Local tTabUser := ''
   Local cProUsr := ""

	tTabUser := GetNextAlias()
   
   cProUsr := StrTran(SCodUsr(),'ECPF','',1,1)
   cQuery :=  "SELECT USU_NOME FROM TAB_USUARIOS WHERE USU_ID = 'c"+cProUsr+"'"
   
 	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),tTabUser,.F.,.T.)
   cUsuario := AllTrim((tTabUser)->USU_NOME)
   (tTabUser)->(DbCloseArea())
return

/*/{Protheus.doc} PRAA805
@author   Aline Briesemeister Xavier
@version  P12
@since    11/12/2013
@obs      Função de carga a lista de empresas que o usuário é administrador.
		   Abrindo a tela para seleção.
/*/
Static Function PRAA805_SelecionaEmpresa()
	Static aEmpresas:= {}
	Static aEmpresasDesc:={}
	Local cAliasEmp := GetNextAlias()
				
	Local nCount
	Local cQuery
	Local nlist:=0
	Static oListEmp
	Local oPanelB
	Local oPanelAllClient
	Local oTButtonAbrir
	Local oTButtonSair
	local cUser
	
	nCount := 0
	cQuery := ''
	cQuery += ' select b.gru_id, '
	cQuery += '        b.cli_id, '
	cQuery += ' 		 case '
	cQuery += ' 	 	 when b.cli_id is null then c.gru_nome '
	cQuery += ' 		 when b.gru_id is null then d.cli_nome '
	cQuery += ' 		 end as cliente_info, '
	cQuery += '        a.pc_id '
	cQuery += '   from tab_portal_usuario_cliente a '
	cQuery += '		 left join tab_portal_cliente b on a.pc_id = b.pc_id '
	cQuery += ' 		 left join tab_grupos c on b.gru_id = c.gru_id '
	cQuery += ' 		 left join tab_clientes d on b.cli_id = d.cli_id '
	cQuery += "  where a.puc_administrador = 1 "
	cQuery += "  and a.usu_id = 'c"+SCodUsr()+"'"
		
	//cQuery := ChangeQuery(cQuery)
	
	aEmpresas     :=nil
	aEmpresas     :={}	
    aEmpresasDesc :=nil
    aEmpresasDesc :={}
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasEmp,.F.,.T.)
 
	dbSelectArea(cAliasEmp)
	(cAliasEmp)->(DbGoTop())
	while (cAliasEmp)->(!EOF())
		Aadd(aEmpresasDesc,(cAliasEmp)->(Fieldget(3)))
        if !SEmpty((cAliasEmp)->(Fieldget(1))) 
			Aadd(aEmpresas,{(cAliasEmp)->(Fieldget(1)),(cAliasEmp)->(Fieldget(4))})  
		else
			Aadd(aEmpresas,{(cAliasEmp)->(Fieldget(2)),(cAliasEmp)->(Fieldget(4))})  
       	end	
       	nCount := nCount+1	
		(cAliasEmp)->(DbSkip())		
	EndDo	
	(cAliasEmp)->(dbCloseArea())
	
	If nCount == 0
	    MsgAlert(STR0014)    		
		lAbreTela := .F.
		Return
	Endif
    
    If nCount == 1
    	cEmpPai := aEmpresas[1,1]	
    	cVarEmp := aEmpresas[1,1]	
    	cDescEmp:=	aEmpresasDesc[1]
    	cPCId := STransType(aEmpresas[1,2])		
		lAbreTela := .T.
		Return
	Endif

	DEFINE MSDIALOG oDlgEmp TITLE STR0015 FROM 0,0 TO 200,200 PIXEL

	oPanelB:= TPanel():Create(oDlgEmp,01,01,"",,,,,,10,15)
	oPanelB:Align := 4 //CONTROL_ALIGN_BOTTOM

	oPanelAllClient  := TPanel():Create(oDlgEmp,01,102,"",,,,,,100,100)
	oPanelAllClient:Align := 5 //CONTROL_ALIGN_ALLCLIENT

	oListEmp:= TListBox():New(10,10,{|u|If(Pcount()>0,nList:=u,nList)} ,aEmpresasDesc,100,100,,oPanelAllClient,,,,.T.,,)
	oListEmp:Align := 5 //CONTROL_ALIGN_ALLCLIENT

	oTButtonAbrir := TButton():New( 01,01,STR0016,oPanelB,{||PRAA805SetEmpresa()},40,10,,,,.T.,,,,,,)
	oTButtonSair  := TButton():New( 01,42,STR0017,oPanelB,{||oDlgEmp:End()},40,10,,,,.T.,,,,,,)

	ACTIVATE MSDIALOG oDlgEmp CENTERED

Return

/*/{Protheus.doc} PRAA805
@author   Aline Briesemeister Xavier
@version  P12
@since    11/12/2013
@obs      Função para carga das variáveis de acordo com a empresa selecionada pelo usuário.
/*/
Static Function PRAA805SetEmpresa()
local nIndex

	nIndex := oListEmp:GetPos()
	cEmpPai := aEmpresas[nIndex,1]	
   	cVarEmp := aEmpresas[nIndex,1]
   	cPCId := STransType(aEmpresas[nIndex,2])	
    cDescEmp := aEmpresasDesc[nIndex]		
	lAbreTela := .T.
	oDlgEmp:End()
return

/*/{Protheus.doc} PRAA805
@author   Aline Briesemeister Xavier
@version  P12
@since    11/12/2013
@obs      Função para carga da grid Funcionalidade da aba "Por Usuário".
/*/
Function A805AGC1(cUsu_select,oBrowseP1C,oBrowseP1B)
	Local cAliasGC1   := SGetNAlias()
		
	aArrayP1C     := {}

	cQuery :=  ' '
	cQuery +=  " select distinct c.pcm_id, " 
    cQuery +=  "        rtrim(c.mnu_id)+'/'+rtrim(c.mod_id) as codigo_menu, "
    cQuery +=  "        g.mnu_descricao "
	cQuery +=  "   from tab_portal_cliente a "
	cQuery +=  "     	  inner join tab_portal_usuario_cliente b on a.pc_id = b.pc_id "
	cQuery +=  "        left outer join tab_usuarios f on b.usu_id = f.usu_id"
	cQuery += "         left outer join rel_portal_cliente_menu c on (a.pc_id = c.pc_id and c.pcm_bloqueado = 0)"
	cQuery += "         inner join tab_menu g on (c.mnu_id = g.mnu_id and c.mod_id = g.mod_id)"
	cQuery += "         left outer join tab_portal_acesso_info d on (c.pcm_id = d.pcm_id and d.pai_bloqueado = 0)"
	cQuery += "         left outer join tab_clientes h on d.cli_id = h.cli_id"
	cQuery += "         left outer join tab_grupos i on d.gru_id = i.gru_id"
	cQuery += "         left outer join rel_portal_usu_menu_info e on (d.pai_id = e.pai_id and b.puc_id = e.puc_id)"
	cQuery += "   where b.usu_id = '"+cUsu_select+"'"
	cQuery += "     and a.pc_id = "+STransType(cPCId)


	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasGC1,.T.,.F.)
	(cAliasGC1)->(DbGotop())
	while (cAliasGC1)->(!EOF())
		Aadd(aArrayP1C, {(cAliasGC1)->(Fieldget(1)),(cAliasGC1)->(Fieldget(2)),(cAliasGC1)->(Fieldget(3))})
		(cAliasGC1)->(DbSkip())
	EndDo
	(cAliasGC1)->(dbCloseArea())

	if len(aArrayP1C) == 0
		aArrayP1C := {{'', '', ''}}
		aArrayP1B := {{'', ''}}
	endif
	
	oBrowseP1C:SetArray(aArrayP1C)
	oBrowseP1C:UpdateBrowse()
	oBrowseP1C:SetChange({||A805AGB1(cUsu_select,aArrayP1C[oBrowseP1C:At(),1],oBrowseP1B)})
return

/*/{Protheus.doc} PRAA805
@author   Aline Briesemeister Xavier
@version  P12
@since    11/12/2013
@obs      Função para carga da grid Cliente da aba "Por Usuário".
/*/
Function A805AGB1(cUsu_select,nId_menu,oBrowseP1B)
	Local cAliasGB1  := SGetNAlias() 
	
	aArrayP1B     := {}
	
    cQuery :=  ' '
	cQuery +=  " select case " 
    cQuery +=  "          when e.pai_id is null then 'Não' "
    cQuery +=  "          else 'Sim' "
    cQuery +=  "        end as acesso, "
    cQuery +=  "        d.cli_id, "
    cQuery +=  "        d.gru_id, "
    cQuery +=  "        case      "
    cQuery +=  "          when d.cli_id is null then i.gru_nome "
    cQuery +=  "          when d.gru_id is null then h.cli_nome "
    cQuery +=  "        end as cliente_info, "          
    cQuery +=  "        CONVERT(varchar(10),d.pai_id)+ "
    cQuery +=  "        CONVERT(varchar(10),ISNULL(b.puc_id,''))+ "
    cQuery +=  "        CONVERT(varchar(10),ISNULL(e.pumi_id,''))+ "
    cQuery +=  "        CONVERT(varchar(10),ISNULL(e.pai_id,'')) as chave, "
    cQuery +=  "        e.pumi_id, "
    cQuery +=  "        b.puc_id, "
    cQuery +=  "        d.pai_id "    
	cQuery +=  "   from tab_portal_cliente a "
	cQuery +=  "   	  	 inner join tab_portal_usuario_cliente b on a.pc_id = b.pc_id "
 	cQuery +=  "          left outer join tab_usuarios f on b.usu_id = f.usu_id "
 	cQuery +=  "          left outer join rel_portal_cliente_menu c on (a.pc_id = c.pc_id and c.pcm_bloqueado = 0) "
 	cQuery +=  "          inner join tab_menu g on (c.mnu_id = g.mnu_id and c.mod_id = g.mod_id) "
 	cQuery +=  "          left outer join tab_portal_acesso_info d on (c.pcm_id = d.pcm_id and d.pai_bloqueado = 0) "
 	cQuery +=  "          left outer join tab_clientes h on d.cli_id = h.cli_id "
 	cQuery +=  "          left outer join tab_grupos i on d.gru_id = i.gru_id "
 	cQuery +=  "          left outer join rel_portal_usu_menu_info e on (d.pai_id = e.pai_id and b.puc_id = e.puc_id) "
	cQuery +=  "  where b.usu_id = '"+cUsu_select+"'"
	cQuery +=  "    and a.pc_id = "+STransType(cPCId)
	cQuery +=  "    and c.pcm_id ="+STransType(nId_menu)

	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasGB1,.T.,.F.)
	(cAliasGB1)->(DbGotop())
	while (cAliasGB1)->(!EOF())
	if !SEmpty((cAliasGB1)->(Fieldget(2))) 
		Aadd(aArrayP1B, {(cAliasGB1)->(Fieldget(1)),(cAliasGB1)->(Fieldget(4)),(cAliasGB1)->(Fieldget(2)),(cAliasGB1)->(Fieldget(5)),(cAliasGB1)->(Fieldget(6)),(cAliasGB1)->(Fieldget(7)),(cAliasGB1)->(Fieldget(8))})
	else
		Aadd(aArrayP1B, {(cAliasGB1)->(Fieldget(1)),(cAliasGB1)->(Fieldget(4)),(cAliasGB1)->(Fieldget(3)),(cAliasGB1)->(Fieldget(5)),(cAliasGB1)->(Fieldget(6)),(cAliasGB1)->(Fieldget(7)),(cAliasGB1)->(Fieldget(8))})
	end
	   (cAliasGB1)->(DbSkip())
	EndDo
	(cAliasGB1)->(dbCloseArea())
	
	oBrowseP1B:SetArray(aArrayP1B)
	oBrowseP1B:UpdateBrowse()
	//oBrowseP1B:SetFocus()
	
return

/*/{Protheus.doc} PRAA805
@author   Aline Briesemeister Xavier
@version  P12
@since    11/12/2013
@obs      Função para carga da grid Cliente da aba "Por Funcionalidade".
/*/
Function A805AGC2(nIdMenu,oBrowseP2C,oBrowseP2B)
 	Local cAliasGC2   := SGetNAlias()
	
	aArrayP2C     := {}

	cQuery :=  ' '
	cQuery +=  " select distinct d.cli_id, "
    cQuery +=  "        d.gru_id, "
    cQuery +=  "        0, "
    cQuery +=  "        case " 
	cQuery +=  "           when d.cli_id is null then i.gru_nome "
	cQuery +=  "           when d.gru_id is null then h.cli_nome "
	cQuery +=  "        end as cliente_info "
	cQuery +=  "   from tab_portal_cliente a "
	cQuery +=  "     	  inner join tab_portal_usuario_cliente b on a.pc_id = b.pc_id "
	cQuery +=  "        left outer join tab_usuarios f on b.usu_id = f.usu_id"
	cQuery += "         left outer join rel_portal_cliente_menu c on (a.pc_id = c.pc_id and c.pcm_bloqueado = 0)"
	cQuery += "         inner join tab_menu g on (c.mnu_id = g.mnu_id and c.mod_id = g.mod_id)"
	cQuery += "         left outer join tab_portal_acesso_info d on (c.pcm_id = d.pcm_id and d.pai_bloqueado = 0)"
	cQuery += "         left outer join tab_clientes h on d.cli_id = h.cli_id"
	cQuery += "         left outer join tab_grupos i on d.gru_id = i.gru_id"
	cQuery += "         left outer join rel_portal_usu_menu_info e on (d.pai_id = e.pai_id and b.puc_id = e.puc_id)"
	cQuery += "   where a.pc_id = "+STransType(cPCId)
	cQuery += "     and c.pcm_id = "+str(nIdMenu)


	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasGC2,.T.,.F.)
	(cAliasGC2)->(DbGotop())
	while (cAliasGC2)->(!EOF())
		Aadd(aArrayP2C, {(cAliasGC2)->(Fieldget(3)),(cAliasGC2)->(Fieldget(4)),(cAliasGC2)->(Fieldget(1)),(cAliasGC2)->(Fieldget(2))})
		
		(cAliasGC2)->(DbSkip())
	EndDo
	(cAliasGC2)->(dbCloseArea())

	if len(aArrayP2C) == 0
		aArrayP2C := {{'', '', '',''}}
		aArrayP2B := {{'', ''}}
	endif
	
	oBrowseP2C:SetArray(aArrayP2C)
	oBrowseP2C:UpdateBrowse()
	oBrowseP2C:SetChange({||A805AGB2(nIdMenu,aArrayP2C[oBrowseP2C:At(),3],aArrayP2C[oBrowseP2C:At(),4],oBrowseP2B)})

	if ((oBrowseP2C:At() != nil) .and. (oBrowseP2C:At() > 0))
		A805AGB2(nIdMenu,aArrayP2C[oBrowseP2C:At(),3],aArrayP2C[oBrowseP2C:At(),4],oBrowseP2B)
	endif
	
return

/*/{Protheus.doc} PRAA805
@author   Aline Briesemeister Xavier
@version  P12
@since    11/12/2013
@obs      Função para carga da grid Usuário da aba "Por Funcionalidade".
/*/
Function A805AGB2(nId_menu,cCliente,cGrupo,oBrowseP2B)
	Local cAliasGB2  := SGetNAlias() 
	
	aArrayP2B     := {}
	
    cQuery :=  ' '
	cQuery +=  " select c.pcm_id, "
	cQuery +=  "        f.usu_nome, " 
	cQuery +=  "        d.cli_id, "
    cQuery +=  "        d.gru_id, "
    cQuery +=  "        case      "
    cQuery +=  "          when d.cli_id is null then i.gru_nome "
    cQuery +=  "          when d.gru_id is null then h.cli_nome "
    cQuery +=  "        end as cliente_info, "
    cQuery +=  "        case " 
    cQuery +=  "          when e.pai_id is null then 'Não' "
    cQuery +=  "          else 'Sim' "
    cQuery +=  "        end as acesso, "
    cQuery +=  "        e.pumi_id, "
    cQuery +=  "        b.puc_id, "
    cQuery +=  "        d.pai_id " 
    cQuery +=  "   from tab_portal_cliente a "
	cQuery +=  "   	  	 inner join tab_portal_usuario_cliente b on a.pc_id = b.pc_id "
 	cQuery +=  "          left outer join tab_usuarios f on b.usu_id = f.usu_id "
 	cQuery +=  "          left outer join rel_portal_cliente_menu c on (a.pc_id = c.pc_id and c.pcm_bloqueado = 0) "
 	cQuery +=  "          inner join tab_menu g on (c.mnu_id = g.mnu_id and c.mod_id = g.mod_id) "
 	cQuery +=  "          left outer join tab_portal_acesso_info d on (c.pcm_id = d.pcm_id and d.pai_bloqueado = 0) "
 	cQuery +=  "          left outer join tab_clientes h on d.cli_id = h.cli_id "
 	cQuery +=  "          left outer join tab_grupos i on d.gru_id = i.gru_id "
 	cQuery +=  "          left outer join rel_portal_usu_menu_info e on (d.pai_id = e.pai_id and b.puc_id = e.puc_id) "
	cQuery +=  "  where a.pc_id = "+STransType(cPCId)
	cQuery +=  "    and c.pcm_id ="+str(nId_menu)
	cQuery +=  "    and (h.cli_id = '"+alltrim(cCliente)+"' or i.gru_id = '"+alltrim(cGrupo)+"')"
	
	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasGB2,.T.,.F.)
	(cAliasGB2)->(DbGotop())
	while (cAliasGB2)->(!EOF())
		Aadd(aArrayP2B, {(cAliasGB2)->(Fieldget(6)),(cAliasGB2)->(Fieldget(4)),(cAliasGB2)->(Fieldget(3)),(cAliasGB2)->(Fieldget(1)),(cAliasGB2)->(Fieldget(2)),(cAliasGB2)->(Fieldget(5)),(cAliasGB2)->(Fieldget(7)),(cAliasGB2)->(Fieldget(8)),(cAliasGB2)->(Fieldget(9))})
	   (cAliasGB2)->(DbSkip())
	EndDo
	(cAliasGB2)->(dbCloseArea())
	
	oBrowseP2B:SetArray(aArrayP2B)
	oBrowseP2B:UpdateBrowse()
	//oBrowseP2B:SetFocus()
	
return

/*/{Protheus.doc} PRAA805
@author   Aline Briesemeister Xavier
@version  P12
@since    11/12/2013
@obs      Função para carga da grid Funcionalidade da aba "Por Cliente".
/*/
Function A805AGC3(cCliente,cGrupo,oBrowseP3C,oBrowseP3B)
	Local cAliasGC3   := SGetNAlias() 
	
	aArrayP3C     := {}

	cQuery :=  ' '
	cQuery +=  " select distinct rtrim(c.mnu_id)+'/'+rtrim(c.mod_id) as codigo_menu, "
    cQuery +=  "        g.mnu_descricao, "
    cQuery +=  "        c.pcm_id "    
    cQuery +=  "   from tab_portal_cliente a "
	cQuery +=  "     	  inner join tab_portal_usuario_cliente b on a.pc_id = b.pc_id "
	cQuery +=  "        left outer join tab_usuarios f on b.usu_id = f.usu_id"
	cQuery += "         left outer join rel_portal_cliente_menu c on (a.pc_id = c.pc_id and c.pcm_bloqueado = 0)"
	cQuery += "         inner join tab_menu g on (c.mnu_id = g.mnu_id and c.mod_id = g.mod_id)"
	cQuery += "         left outer join tab_portal_acesso_info d on (c.pcm_id = d.pcm_id and d.pai_bloqueado = 0)"
	cQuery += "         left outer join tab_clientes h on d.cli_id = h.cli_id"
	cQuery += "         left outer join tab_grupos i on d.gru_id = i.gru_id"
	cQuery += "         left outer join rel_portal_usu_menu_info e on (d.pai_id = e.pai_id and b.puc_id = e.puc_id)"
	cQuery += "   where a.pc_id = "+STransType(cPCId)
	cQuery +=  "    and (h.cli_id = '"+cCliente+"' or i.gru_id = '"+cGrupo+"')"

	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasGC3,.T.,.F.)
	(cAliasGC3)->(DbGotop())
	while (cAliasGC3)->(!EOF())
		Aadd(aArrayP3C, {(cAliasGC3)->(Fieldget(1)),(cAliasGC3)->(Fieldget(2)),(cAliasGC3)->(Fieldget(3))})
		(cAliasGC3)->(DbSkip())
	EndDo
	(cAliasGC3)->(dbCloseArea())

	if len(aArrayP3C) == 0
		aArrayP3C := {'', '',''}
		aArrayP3B := {'', '','','','',''}
	endif
	
	oBrowseP3C:SetArray(aArrayP3C)
	oBrowseP3C:UpdateBrowse()
	oBrowseP3C:SetChange({||A805AGB3(aArrayP3C[oBrowseP3C:At(),3],cCliente,cGrupo,oBrowseP3B)})
	
	if ((oBrowseP3C:At() != nil) .and. (oBrowseP3C:At() > 0))
		A805AGB3(aArrayP3C[oBrowseP3C:At(),3],cCliente,cGrupo,oBrowseP3B)
	endif
	
return

/*/{Protheus.doc} PRAA805
@author   Aline Briesemeister Xavier
@version  P12
@since    11/12/2013
@obs      Função para carga da grid Usuário da aba "Por Cliente".
/*/
Function A805AGB3(nIdmenu,cCliente,cGrupo,oBrowseP3B)
	Local cAliasGB3  := SGetNAlias() 
	
	aArrayP3B     := {}
	
    cQuery :=  ' '
	cQuery +=  " select c.pcm_id, "
	cQuery +=  "        f.usu_nome, "
	cQuery +=  "        d.cli_id, "
    cQuery +=  "        d.gru_id, "
    cQuery +=  "        case      "
    cQuery +=  "          when d.cli_id is null then i.gru_nome "
    cQuery +=  "          when d.gru_id is null then h.cli_nome "
    cQuery +=  "        end as cliente_info, "
    cQuery +=  "        case " 
    cQuery +=  "          when e.pai_id is null then 'Não' "
    cQuery +=  "          else 'Sim' "
    cQuery +=  "        end as acesso, "
    cQuery +=  "        e.pumi_id, "
    cQuery +=  "        b.puc_id, "
    cQuery +=  "        d.pai_id "
    cQuery +=  "   from tab_portal_cliente a "
	cQuery +=  "   	  	 inner join tab_portal_usuario_cliente b on a.pc_id = b.pc_id "
 	cQuery +=  "          left outer join tab_usuarios f on b.usu_id = f.usu_id "
 	cQuery +=  "          left outer join rel_portal_cliente_menu c on (a.pc_id = c.pc_id and c.pcm_bloqueado = 0) "
 	cQuery +=  "          inner join tab_menu g on (c.mnu_id = g.mnu_id and c.mod_id = g.mod_id) "
 	cQuery +=  "          left outer join tab_portal_acesso_info d on (c.pcm_id = d.pcm_id and d.pai_bloqueado = 0) "
 	cQuery +=  "          left outer join tab_clientes h on d.cli_id = h.cli_id "
 	cQuery +=  "          left outer join tab_grupos i on d.gru_id = i.gru_id "
 	cQuery +=  "          left outer join rel_portal_usu_menu_info e on (d.pai_id = e.pai_id and b.puc_id = e.puc_id) "
	cQuery +=  "  where a.pc_id = "+STransType(cPCId)
	cQuery +=  "    and c.pcm_id ="+str(nIdmenu)
	cQuery +=  "    and (h.cli_id = '"+alltrim(cCliente)+"' or i.gru_id = '"+alltrim(cGrupo)+"')"

	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasGB3,.T.,.F.)
	(cAliasGB3)->(DbGotop())
	while (cAliasGB3)->(!EOF())
		Aadd(aArrayP3B, {(cAliasGB3)->(Fieldget(6)),(cAliasGB3)->(Fieldget(4)),(cAliasGB3)->(Fieldget(3)),(cAliasGB3)->(Fieldget(1)),(cAliasGB3)->(Fieldget(2)),(cAliasGB3)->(Fieldget(5)),(cAliasGB3)->(Fieldget(7)),(cAliasGB3)->(Fieldget(8)),(cAliasGB3)->(Fieldget(9))})
	   (cAliasGB3)->(DbSkip())
	EndDo
	(cAliasGB3)->(dbCloseArea())
	
	oBrowseP3B:SetArray(aArrayP3B)
	oBrowseP3B:UpdateBrowse()
	
return

Static Function PRAA805_ReplicaPermissao(oTFolder, cUsuarioPai, cPCId)
	Local cQuery	
	Local oDlg
	Local aStruct
	Private oBrowse
	Private cAliasTb    := SGetNAlias()
	Private cAliasQy    := SGetNAlias()
	Private cUsuPaiInt  := cUsuarioPai
	Private cPCIdInt	  := STransType(cPCId)

	if oTFolder:nOption == 1	
	
		aStruct := {;
		    {'CP1','C', 2,0}, ;
		    {'CP2','C',15,0}, ;
		    {'CP3','C',50,0}, ;
		    {'CP4','C',50,0}, ;
		    {'CP5','C',50,0}  ;
		}
	
		SDelTbTmp(cAliasTb)
		SCriaTbTmp({aStruct, {"CP4"}}, cAliasTb)		

		cQuery := ''
		cQuery += " select '  ' as status, "
		cQuery += '        a.usu_id, '
		cQuery += '        a.usu_nome, '
		cQuery += '        ROW_NUMBER() OVER(ORDER BY a.usu_id) as id, '
		cQuery += '        b.puc_id '
		cQuery += '   from tab_usuarios a '
		cQuery += '   inner join tab_portal_usuario_cliente b on a.usu_id = b.usu_id '
		cQuery += '   where b.pc_id = ' + cPCIdInt
		cQuery += "   and a.usu_id <> '" + cUsuPaiInt + "'"

		DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasQy,.F.,.F.)
		(cAliasQy)->(DbGotop())
		while (cAliasQy)->(!EOF())
			(cAliasTb)->(dbAppend())
	
			(cAliasTb)->(FieldPut(1,(cAliasQy)->(Fieldget(1))))
			(cAliasTb)->(FieldPut(2,(cAliasQy)->(Fieldget(2))))
			(cAliasTb)->(FieldPut(3,(cAliasQy)->(Fieldget(3))))
			(cAliasTb)->(FieldPut(4,cValToChar((cAliasQy)->(Fieldget(4)))))
			(cAliasTb)->(FieldPut(5,cValToChar((cAliasQy)->(Fieldget(5)))))
			(cAliasQy)->(DbSkip())
		EndDo

		(cAliasQy)->(DBCloseArea())
		(cAliasTb)->(DBCommit())
		(cAliasTb)->(DbGotop())							 

		oBrowse := FWMarkBrowse():new(oDlg)
		oBrowse:SetDataTable()
		oBrowse:SetDescription(STR0018)
		oBrowse:AddButton(STR0016,{|| A805REP()},,1,2)
		oBrowse:SetAlias(cAliasTb)
		oBrowse:SetFieldMark('CP1')
		oBrowse:SetMark('OK', cAliasTb, 'CP1')
		oBrowse:SetAllMark( { || oBrowse:AllMark() } )
	
		oColumn := FWBrwColumn():New()
		oColumn:SetData(  {|| CP2} )
		oColumn:SetTitle( STR0019  )
		oColumn:SetSize(  20  )
	
		oBrowse:SetColumns({oColumn})
		
		oColumn := FWBrwColumn():New()
		oColumn:SetData(  {|| CP3} )
		oColumn:SetTitle( STR0020  )
		oColumn:SetSize(  50  )
		oBrowse:SetColumns({oColumn})
	
		oBrowse:Activate()

		SDelTbTmp(cAliasTb)
	else
		MsgAlert(STR0021)
	endif

Return

function A805REP()
	Processa( {|| Resultado() },STR0022)

	ApMsgInfo(STR0023)
return

Static Function Resultado()
	Local aArea     := GetArea()
	Local cMarca    := oBrowse:Mark()
	Local nCt       := 0
	Local aUsu      := {}
	Local cQry      := ""
	Local i         := 0
	Local cAliasU  := SGetNAlias()
	Local cAliasUT := SGetNAlias()
	
	
	aStruct := { {'CP1','C', 20,0} }

	SDelTbTmp(cAliasUT)
	SCriaTbTmp({aStruct, {"CP1"}}, cAliasUT)		

	cQry := ''
	cQry += ' select pai_id '
	cQry += '   from rel_portal_usu_menu_info a '
	cQry += '   inner join tab_portal_usuario_cliente b on a.puc_id = b.puc_id '
	cQry += '   where b.pc_id = ' + STransType(cPCIdInt) 
	cQry += "   and b.usu_id = '" + STransType(cUsuPaiInt) + "'"

	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQry),cAliasU,.F.,.F.)
	
	(cAliasU)->(DbGotop())
	while (cAliasU)->(!EOF())
		(cAliasUT)->(dbAppend())
		(cAliasUT)->(FieldPut(1,cValToChar((cAliasU)->(Fieldget(1)))))
		(cAliasU)->(DbSkip())
	EndDo
	(cAliasU)->(DBCloseArea())
	(cAliasUT)->(DBCommit())

	(cAliasTb)->( dbGoTop() )
	While !(cAliasTb)->( EOF() )
		If oBrowse:IsMark(cMarca)
			nCt++
			Aadd(aUsu, {(cAliasTb)->(FieldGet(1)),(cAliasTb)->(FieldGet(5))})
		EndIf

		(cAliasTb)->( dbSkip() )
	End

	ProcRegua(nCt)

	for i := 1 to nCt
		IncProc(STR0024+Str(nCt))
		
		cQry := "delete from rel_portal_usu_menu_info where puc_id = "+STransType(aUsu[i,2])
		TcSqlExec(cQry)
		
		(cAliasUT)->(DbGotop())
		While !(cAliasUT)->( EOF() )		
			cQry := "exec proc_di_portal_usu_menu_info 2, null,"+STrim(STransType(aUsu[i,2]))+","+STrim(STransType((cAliasUT)->(FieldGet(1))))+",'"+SDBDate(date(), time())+"'" 
			TcSqlExec(cQry)
			(cAliasUT)->( dbSkip() )	
		end
	next

	RestArea( aArea )

return .T.