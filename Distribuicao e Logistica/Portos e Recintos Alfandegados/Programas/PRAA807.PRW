#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static lRetParam := .T. 
Static cParam     := ""
Static cParam02   := ""
Static lRetAtivar := .F.
Static a_Cnt_Tipo := {"10=pés","20=pés","30=pés","40=pés"}

/*/{Protheus.doc} PRAA807
	Registro de Contêineres 
@author siegklenes.beulke
@since 30/03/2015
@version 1.0
@example
PRAA807
@see Melhorias no processo de agendamento PCREQ-2696 - PCREQ-2002
/*/
Function PRAA807()
	Local aCoors := FWGetDialogSize( oMainWnd )
    Private oBrowse := FWMBrowse():New()	
	Private cAliasZZ7 := ""
	Private cAliasZZ8 := ""
	Private cFiltroSql := ""
	Private cRetLkSara := ""
	Private PnlFltr
	Private PnlFltr2
	Private oPnlBx
	Private afltr2 := {}
	Private aLst := {0,0}
	Private lMarcado := .F.
	Private oPnlTop
	Private oDialog807
	Private cAlTiso := ""
	Private cAlImo := ""
	Private cAlTrpId := ""
	Private cTipoModal
	Private cVarEmp
	Private cDescEmp
	Private cUsuario 		:= RET_USER()
	Private userInf := {}
	Private cCodPes := "Código do motorista" // olhar carpar - praa802
	Private cCdPes2 := "Código do motorista"
	Private cNomPes := "Nome do motorista"
	Private cNmPes2 := "Nome do motorista"
	Private cCadPes := "Cadastrar motorista"
	Private  a_PRT_ID := {''}
	Private  a_NAT_ID := {''}
	Private  a_OPE_ID := {''}
	Private  a_TPO_ES := {''}
	Private  a_BEN    := {''}
	Private  a_ANO_DC := {''}
	Private  a_PRC_DC := {''}
	Private cVigPar := "" // Armazena a viagem digitada no parâmetro de pesquisa
	Private cVigCli := "" // Armazena o operador da viagem digitada no parâmetro
	Private cVigOp := "" // Armazena a operação da viagem digitada no parâmetro
	Private cVigTr := "" // Armazena o transportador da viagem digitada no parâmetro
	Private lKill := .F.
	Private lAbreTela
	Private _cEmpPai
	Private cEmpPai
	Private lEdit := .F.
	Static cAtualizaCNT	
	
	if cUsuario == ""
      MsgStop("Este usuário não está cadastrado no sistema SARA"+Chr(13)+"Entre em contato com o administrador do sistema")
      Return .F.
    EndIF
 
	userInf := A802VACES()
	   
	if sempty(userInf)
		alert('Usuário sem permissão de acesso!')
	   	return .F.
	endif
	
	A802SELEMP()
	
	If Empty(_cEmpPai)
	   return .F.
	EndIf

	if (lAbreTela = .F.) .or. (alltrim(A802GetcEmpPai()) =  '')
		return .F.
	endif
	cEmpPai := A802GetcEmpPai()
	If Empty(cEmpPai)
	    return .F.
	EndIf
//	MontaSpCreate("select * from tab_reserva_container","tab_reserva_container")
//	MontaSpText("proc_diu_tab_reserva_container")
    cParam02 := ""
	If !A807PARAM()
		Return
	EndIf
	
	If !lRetParam
		Return .F.
	EndIf
	
	Define MsDialog oDialog807 Title "Registro de Contêineres" From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		/* -- Layers -------------------------------------------------- */
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDialog807, .F., .T.)
		
		// Tabela de Frete
		oFWLayer:AddLine('TOP', 90, .F.)
		oFWLayer:AddCollumn('BRW', 100, .T., 'TOP') // Tabela de Frete
		oPnlTop := oFWLayer:GetColPanel('BRW', 'TOP')
		
		// Negociação
		oFWLayer:AddLine('BOTTON', 5, .F.) 
		oFWLayer:AddCollumn('PNL', 100, .T., 'BOTTON') // Negociação
		oPnlBx := oFWLayer:GetColPanel('PNL', 'BOTTON')
		
		oFWLayer:AddLine('BOTTON2', 5, .F.) 
		oFWLayer:AddCollumn('PNL2', 100, .T., 'BOTTON2') // Negociação
		oPnlBx2 := oFWLayer:GetColPanel('PNL2', 'BOTTON2')
		
		PnlFltr := PRAPnlFiltr():New(oPnlBx, afltr2,"Filtros selecionados: ")
		If GetRemoteType() == 5
			PnlFltr:nAjustCol := 40
		EndIf
		PnlFltr:Build()
		
		PnlFltr2 := PRAPnlFiltr():New(oPnlBx2, aLst,"Totais: ")
		If GetRemoteType() == 5
			PnlFltr2:nAjustCol := 40
		EndIf
		PnlFltr2:Build()
		
			
	oBrowse:SetMenuDef("PRAA807") // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Registro de Contêineres")
	oBrowse:SetAlias(cAliasZZ7)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetOwner(oPnlTop)
    oBrowse:SetUseFilter(.F.)
	oBrowse:SetFields(GetBrwStru())
	oBrowse:DisableDetails()
	ADD MARKCOLUMN oColumn DATA {|| If((cAliasZZ7)->ZZ7_MARCAD == 1, 'LBOK', 'LBNO')};
		DOUBLECLICK {|| RecLock(cAliasZZ7,.F.),(cAliasZZ7)->ZZ7_MARCAD := If((cAliasZZ7)->ZZ7_MARCAD == 1,0,1),(cAliasZZ7)->(MsUnlock())};
		HEADERCLICK {|| A806MarkAll(cAliasZZ7,"ZZ7_MARCAD",oPnlTop,oBrowse) } OF oBrowse
	oBrowse:Activate()
	Activate MsDialog oDialog807 Center ON INIT  A807KILL()
	If !Empty(PnlFltr)
		PnlFltr:Destroy()
	EndIf
	delTabTmp(cAliasZZ7)
Return

Static Function GetStruct()
	Local aStru := {	{"ZZ7_MARCAD" ,"N",01,0},;
						{"ZZ7_RESERV" ,"C",30,0},;
						{"ZZ7_BENID"  ,"C",06,0},;
						{"ZZ7_RESID"  ,"N",10,0},;
						{"ZZ7_DSRESR" ,"C",50,0},;
						{"ZZ7_NAVIO"  ,"C",50,0},;
						{"ZZ7_VIAGEM" ,"C",15,0},;
						{"ZZ7_RCNTID" ,"N",10,0},;
						{"ZZ7_CNTID"  ,"C",11,0},;
						{"ZZ7_CNTISO" ,"C",04,0},;
						{"ZZ7_DSISO"  ,"C",50,0},;
						{"ZZ7_CNTTAM" ,"C",02,0},;
						{"ZZ7_TAR"    ,"N",13,2},;
						{"ZZ7_MGW"    ,"N",13,2},;
						{"ZZ7_STATUS" ,"C",01,0},;
						{"ZZ7_CPID"   ,"C",10,0},;
						{"ZZ7_CPDS"   ,"C",80,0},;
						{"ZZ7_CPRISC" ,"C",10,0},;
						{"ZZ7_LACRE1" ,"C",30,0},;
						{"ZZ7_LACRE2" ,"C",30,0},;
						{"ZZ7_TMP"    ,"N",13,2},;
						{"ZZ7_VAR"    ,"N",13,2},;
						{"ZZ7_CMP"    ,"N",13,2},;
						{"ZZ7_LRG"    ,"N",13,2},;
						{"ZZ7_ALT"    ,"N",13,2},;
						{"ZZ7_QTDOC"  ,"N",13,0},;
						{"ZZ7_PESDOC" ,"N",13,2},;
						{"ZZ7_VALDOC" ,"N",13,2},;
						{"ZZ7_PRGAG"  ,"N",13,0},;
						{"ZZ7_MODAL"  ,"C",01,0},;
						{"ZZ7_VEIC","C",15,0},;
						{"ZZ7_DTPREV" ,"D",08,0},;
						{"ZZ7_HRPVIN" ,"C",05,0},;
						{"ZZ7_HRPVFN" ,"C",05,0},;
						{"ZZ7_BENDS"  ,"C",100,0},;
						{"ZZ7_CGCBEN" ,"C",14,0},;
						{"ZZ8_TRPID"  ,"C",10,0},;
						{"ZZ8_CNTISO" ,"C",04,0},;
						{"ZZ8_CNTTAM" ,"C",02,0},;
						{"ZZ8_QTPRG"  ,"N",13,0},;
						{"ZZ8_QTREG"  ,"N",13,0},;
						{"ZZ8_STATUS" ,"C",01,0};
						}
						
Return aStru

Static Function GetBrwStru()
	Local aStru := {	{"Reserva"        ,"ZZ7_RESERV" ,"C",06,0},;
						{"Container"      ,"ZZ7_CNTID"  ,"C",06,0},;
						{"ISO"            ,"ZZ7_CNTISO" ,"C",04,0},;
						{"Tam."           ,"ZZ7_CNTTAM" ,"C",02,0},;
						{"Tara"           ,"ZZ7_TAR"    ,"N",04,2},;
						{"Situação"       ,"If (ZZ7_STATUS == '1', 'CHEIO', 'VAZIO')" ,"C",06,0},;
						{"Lacres"         ,"AllTrim(ZZ7_LACRE1)+' / '+AllTrim(ZZ7_LACRE2)" ,"C",08,0},;
						{"IMO"            ,"ZZ7_CPID"   ,"C",04,0},;
						{"Doc. Fiscais."  ,"ZZ7_QTDOC"  ,"N",06,0},;
						{"Peso Merc."     ,"ZZ7_PESDOC" ,"N",06,0},;
						{"Valor Merc."    ,"Transform(ZZ7_VALDOC,'@E 9,999,999,999.99')"  , "N",  06, 2},;
						{"Agendamento"    ,"Iif(Empty(ZZ7_PRGAG),'',STRZERO(ZZ7_PRGAG,6))" ,"C",06,0},;
						{"Modal"          ,"A807RMODAL(ZZ7_MODAL)","C",06,0},;
						{"Veículo"        ,"ZZ7_VEIC","C",06,0},;
						{"Data Prevista"  ,"ZZ7_DTPREV" ,"D",06,0},;
						{"Janela Prevista","SubStr(ZZ7_HRPVIN,1,5)+' às '+SubStr(ZZ7_HRPVFN,1,5)" ,"C",06,0};
						}
Return aStru

Static Function MontaDados()
	Local cQuery
	Local cAliasTmp
	Local aQryStru
	Local nI
	
	MV_PAR01 := cParam02
	
	If Empty(cAliasZZ7)
		cAliasZZ7 := GetNextAlias()
		cAliasZZ7 := sCriaTbTmp({GetStruct(),{'ZZ7_RESERV+ZZ7_CNTID','cValToChar(ZZ7_MARCAD)+ZZ7_RESERV+ZZ7_CNTID'}})
	Else
		dbSelectArea(cAliasZZ7)
//		ZAP
		(cAliasZZ7)->(dbSetOrder(1))
		(cAliasZZ7)->(dbGotop())
		
		While !(cAliasZZ7)->(Eof())
			RecLock(cAliasZZ7,.F.)
			DBdELETE()
			msunlock()
			(cAliasZZ7)->(dbskip())
		EndDo
	EndIf
	
	cQuery := "SELECT                                "+;
				"    c.res_id ZZ7_RESID,          "+;
				"    c.cli_id ZZ7_BENID,          "+;
				"    j.cli_cgc ZZ7_CGCBEN,          "+;
			   "    c.res_numero ZZ7_RESERV,          "+;
				"    a.rcnt_id ZZ7_RCNTID,             "+;
				"    a.cnt_id ZZ7_CNTID,               "+;
				"    d.tiso_id ZZ7_CNTISO,             "+;
				"    n.tiso_descricao ZZ7_DSISO,       "+;
				"    d.cnt_tipo ZZ7_CNTTAM,            "+;
				"    d.cnt_tara ZZ7_TAR,               "+;
				"    d.cnt_mgw ZZ7_MGW,                "+;	
				"    convert(VARCHAR,b.trp_cnt_cheio) ZZ7_STATUS,       "+;
				"    convert(VARCHAR,b.trp_id) ZZ8_TRPID,               "+;
				"    a.cp_id ZZ7_CPID,                 "+;
				"    e.cp_descricao ZZ7_CPDS,          "+;
    			"    e.cp_classe_risco ZZ7_CPRISC,     "+;
				"    a.rcnt_lacre_manifestado ZZ7_LACRE1, "+;
				"    a.rcnt_lacre_manifestado2 ZZ7_LACRE2, "+;
				"    a.rcnt_temperatura ZZ7_TMP, "+;
				"    a.rcnt_variacao_temper ZZ7_VAR, "+;
				"    a.rcnt_compr_excedente ZZ7_CMP, "+;
				"    a.rcnt_largura_excedente ZZ7_LRG, "+;
				"    a.rcnt_altura_excedente ZZ7_ALT, "+;
				"    (SELECT COUNT(rrc_id) FROM tab_reserva_rateio_cnt ra where ra.res_id = b.res_id and ra.rcnt_id = a.rcnt_id) ZZ7_QTDOC, "+;
				"    (SELECT SUM(dent_peso_rateio) FROM tab_reserva_rateio_cnt rb where rb.res_id = b.res_id and rb.rcnt_id = a.rcnt_id) ZZ7_PESDOC, "+;
				"    (SELECT SUM(dent_valor_rateio) FROM tab_reserva_rateio_cnt rb where rb.res_id = b.res_id and rb.rcnt_id = a.rcnt_id) ZZ7_VALDOC, "+;
				"    g.prog_id ZZ7_PRGAG,              "+;
				"    g.PROG_TIPO_MODAL ZZ7_MODAL,      "+;
				"    g.vei_id ZZ7_VEIC,    "+;
				"    CONVERT(VARCHAR, i.paj_datahora_ini , 103) ZZ7_DTPREV," +;
				"    CONVERT(VARCHAR, i.paj_datahora_ini , 108) ZZ7_HRPVIN," +;
				"    CONVERT(VARCHAR, i.paj_datahora_fim , 108) ZZ7_HRPVFN," +;
				"   k.res_tipo_descricao ZZ7_DSRESR,   "+;
				" (CASE LEN(j.cli_cgc)                 "+;
				"      WHEN 14 then                    "+;
				"         SUBSTRING(j.cli_cgc,1,2)++'.'++SUBSTRING(j.cli_cgc,3,3)++'.'++SUBSTRING(j.cli_cgc,6,3)++'/'++SUBSTRING(j.cli_cgc,9,4)++'-'++SUBSTRING(j.cli_cgc,13,2) "+;
				"      WHEN 11 then                    "+;
				"         SUBSTRING(j.cli_cgc,1,3)++'.'++SUBSTRING(j.cli_cgc,4,3)++'.'++SUBSTRING(j.cli_cgc,7,3)++'-'++SUBSTRING(j.cli_cgc,10,2) "+;
				"      ELSE                            "+;
				"         j.cli_cgc                    "+;
				" END)++' - '++j.cli_nome ZZ7_BENDS,   "+;
				"   l.nav_n2 ZZ7_NAVIO,                "+;
				"   m.vgm_numero ZZ7_VIAGEM            "+;
				"from tab_reserva_container a          "+;
				"  inner join tab_reserva_programacao b"+;
				"     on b.trp_id = a.trp_id           "+;
				"  inner join tab_reserva c            "+;
				"     on c.res_id = b.res_id           "+;
				"  left outer join tab_cargas_perigosas e   "+;
				"     on e.cp_id = a.cp_id             "+;				
				"  left outer join tab_container d     "+;
				"     on d.cnt_id = a.cnt_id           "+;
				" LEFT OUTER JOIN TAB_PROGRAMACAO G ON G.op_id IN (2,3) AND "+; 
              " EXISTS (SELECT 1 FROM TAB_PROGRAMACAO_CNT FF "+;
              " WHERE  FF.CNT_ID = A.CNT_ID "+;
              "    AND FF.RES_ID = C.RES_ID "+;
              "    AND G.prog_id = FF.prog_id ) "+;
              " AND G.DT_CANCELAMENTO IS NULL "+;
				"  left outer join tab_prog_janela h   "+;
				"     on h.prog_id = g.prog_id         "+;
				"  left outer join tab_portal_agenda_janela i"+;
				"     on i.paj_id = h.paj_id           "+;
				"  LEFT OUTER JOIN tab_clientes j      "+;
				"    ON j.cli_id = c.cli_id            "+;
				"  LEFT OUTER JOIN tab_reserva_tipo k  "+;
				"    ON k.res_tipo = c.res_tipo        "+;
				"  LEFT OUTER JOIN tab_viagem m        "+;
				"    ON m.vgm_id = c.vgm_id            "+;
				"  LEFT OUTER JOIN tab_navios l        "+;
				"    ON l.nav_id = m.vei_id            "+;
				"  left outer join tab_TIPO_ISO n      "+;
				"    on n.tiso_id = d.tiso_id          "+ cFiltroSql
				
	aLst := {0,0}
	cAliasTmp := GetNextAlias()
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAliasTmp,.F.,.T.)
	aQryStru := (cAliasZZ7)->(dbStruct())
	(cAliasTmp)->(dbGoTop())
	While !(cAliasTmp)->(Eof())
	    (cAliasZZ7)->(DbAppend())
	    For nI := 1 To Len(aQryStru)
	        If (cAliasTmp)->(FieldPos(aQryStru[nI,1])) > 0
	        	 If aQryStru[nI,2] == 'D'
	        	 	(cAliasZZ7)->(FieldPut(nI,CTOD((cAliasTmp)->(FieldGet(FieldPos(aQryStru[nI,1]))))))
	        	 ElseIf aQryStru[nI,2] == 'L'
	        	 	(cAliasZZ7)->(FieldPut(nI,(cAliasTmp)->(FieldGet(FieldPos(aQryStru[nI,1]))) == 'T'))
	        	 ElseIf aQryStru[nI,2] <> 'M'
	        	 	(cAliasZZ7)->(FieldPut(nI,(cAliasTmp)->(FieldGet(FieldPos(aQryStru[nI,1])))))
	        	 EndIf
	        EndIf
	    Next nI
	    aLst[1]++
	    aLst[2]+=(cAliasTmp)->ZZ7_PESDOC
	    (cAliasTmp)->(DbSkip())
	End
	
	(cAliasTmp)->(dbCloseArea())
	(cAliasZZ7)->(dbGoTop())			
	aLst[1] := "Documentos: " + cValToChar(aLst[1])
	aLst[2] := "Peso documental (Kg): " + Transform(aLst[2],"@E 9,999,999,999.99")
Return

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Visualizar"			 		ACTION "VIEWDEF.PRAA807"	OPERATION 2	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Incluir" 					ACTION "A807VALEXEC('VIEWDEF','PRAA807',3,'Incluir')"	OPERATION 3	ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" 					ACTION "VIEWDEF.PRAA807"	OPERATION 4	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Excluir" 					ACTION "VIEWDEF.PRAA807"	OPERATION 5	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Associar Documentos"		ACTION "PRAA807A(),A807Atualizar()"		OPERATION 4	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Agendamento"					ACTION "A807AG(),A807Atualizar()"			OPERATION 4	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Imprimir"   					ACTION "VIEWDEF.PRAA807"	OPERATION 8	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Parâmetros" 					ACTION "A807PARAM()"		OPERATION 3	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Atualizar Grid"		 		ACTION "A807Atualizar()"	OPERATION 3	ACCESS 0 DISABLE MENU
	
Return aRotina

Static Function ModelDef()
	Local oModel  	 := Nil
	Local oStructZZ7 := FWFormModelStruct():New()
	Local oStructZZ8 := FWFormModelStruct():New()
	Local oStructZZ9 := FWFormModelStruct():New()
	Default ALTERA := .F.
	
	lEdit := !ALTERA
	
	oStructZZ7:AddTable(cAliasZZ7, {'ZZ7_RESERV'},"Registro de Contêineres")
	oStructZZ7:AddIndex(1,'01','ZZ7_RESERV+ZZ7_CNTID','Indice 1','','',.T.)
	oStructZZ7:AddIndex(2,'02','cIntToBool(ZZ7_MARCAD)+ZZ7_RESERV+ZZ7_CNTID','Indice 2','','',.T.)
	
	oStructZZ8:AddTable(cAliasZZ7, {'ZZ8_TRPID'},"Programação Contêineres")
	oStructZZ8:AddIndex(1,'01','ZZ8_TRPID','Indice 1','','',.T.)
	
	oStructZZ9:AddTable(cAliasZZ7, {'ZZ7_RESERV'},"Registro de Contêineres")
	oStructZZ9:AddIndex(1,'01','ZZ8_TRPID','Indice 1','','',.T.)
	

	//Reserva:
	
	oStructZZ7:AddField("RCNT_ID"	, "RCNT_ID"          , 	"ZZ7_RCNTID" ,"N",10,0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ7:AddField("Reserva"	, "Código da reserva", 	"ZZ7_RESID", "N",  10, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ7:AddField("Reserva"	, "Código da reserva", 	"ZZ7_RESERV", "C",  30, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ7:AddField("Tipo"		, "Tipo da reserva"	, 	"ZZ7_DSRESR", "C",  50, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ7:AddField("Beneficiário", "Beneficiário"	, 	"ZZ7_BENDS" , "C",  100, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ7:AddField("Navio"		, "Navio"			, 	"ZZ7_NAVIO" , "C",  50, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ7:AddField("Viagem"	, "Viagem"			, 	"ZZ7_VIAGEM", "C",  15, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ8:AddField("Cod.Progr.","Cod.Progr.","ZZ8_TRPID"  ,"C",10,0,{||VAL_TRPID()},{||.T.},Nil,.T.,/**/,lEdit,.F.,.F.)
	oStructZZ8:AddField("ISO"       ,"ISO"       ,"ZZ8_CNTISO" ,"C",04,0,{||.T.},{||.T.},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ8:AddField("Tamanho"   ,"Tamanho"   ,"ZZ8_CNTTAM" ,"C",02,0,{||.T.},{||.T.},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ8:AddField("Qtde Prog" ,"Qtde Prog" ,"ZZ8_QTPRG"  ,"N",13,0,{||.T.},{||.T.},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ8:AddField("Qtde Reg"  ,"Qtde Reg"  ,"ZZ8_QTREG"  ,"N",13,0,{||.T.},{||.T.},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ8:AddField("Situacao"  ,"Situacao"  ,"ZZ8_STATUS" ,"C",01,0,{||.T.},{||.T.},{"0=VAZIO","1=CHEIO"},.F.,/**/,.F.,.F.,.F.)
	
	//Dados do container
	oStructZZ9:AddField("Contêiner"       ,"Contêiner"       ,"ZZ7_CNTID"  ,"C",11,0,{||VAL_CNT()},{||.T.},Nil,.T.,/**/,.F.,.F.,.F.)
	oStructZZ9:AddField("Tipo ISO"        ,"Tipo ISO"        ,"ZZ7_CNTISO" ,"C",04,0,{||VAL_ISO()},{||CNTEXIST()},Nil,.T.,/**/,.F.,.F.,.F.)
	oStructZZ9:AddField("Descrição","Descrição","ZZ7_DSISO"  ,"C",50,0,{||.T.},{||.T.},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ9:AddField("Tamanho"         ,"Tamanho"         ,"ZZ7_CNTTAM" ,"C",02,0,{||.T.},{||CNTEXIST()},a_Cnt_Tipo,.T.,/**/,.F.,.F.,.F.)
	oStructZZ9:AddField("Tara (Kg)"       ,"Tara (Kg)"       ,"ZZ7_TAR"    ,"N",13,2,{||.T.},{||CNTEXIST()},Nil,.T.,/**/,.F.,.F.,.F.)
	oStructZZ9:AddField("MGW (Kg)"       ,"MGW (Kg)"       ,"ZZ7_MGW"    ,"N",13,2,{||.T.},{||.T.},Nil,.T.,/**/,.F.,.F.,.F.)
	
	//Complementos
	oStructZZ9:AddField("Código IMO"	  ,"Código IMO"      , "ZZ7_CPID"   ,"C",10,0,{||VAL_IMO()},{||.T.},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ9:AddField("Descrição"       ,"Descrição"       , "ZZ7_CPDS"   ,"C",80,0,{||.T.},{||.T.},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ9:AddField("Classe de risco" ,"Classe de risco" , "ZZ7_CPRISC" ,"C",10,0,{||.T.},{||.T.},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ9:AddField("Lacre 1"         ,"Lacre 1"         , "ZZ7_LACRE1" ,"C",30,0,{||.T.},{||.T.},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ9:AddField("Lacre 2"         ,"Lacre 2"         , "ZZ7_LACRE2" ,"C",30,0,{||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ9:AddField("Temperatura (ºC)","Temperatura (ºC)" ,"ZZ7_TMP"    ,"N",13,2,{||.T.},{||WHEN_REEF()},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ9:AddField("Variação (ºC)"       ,"Variação (ºC)","ZZ7_VAR"    ,"N",13,2,{||.T.},{||WHEN_REEF()},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ9:AddField("Excedente Comp (m)" ,"Excedente Comp (m)" ,"ZZ7_CMP"    ,"N",13,2,{||.T.},{||WHEN_EXCE()},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ9:AddField("Excedente Larg (m)" ,"Excedente Larg (m)" ,"ZZ7_LRG"    ,"N",13,2,{||.T.},{||WHEN_EXCE()},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ9:AddField("Excedente Alt (m)"  ,"Excedente Alt (m)" ,"ZZ7_ALT"    ,"N",13,2,{||.T.},{||WHEN_EXCE()},Nil,.F.,/**/,.F.,.F.,.F.)
	//Triggers
	oStructZZ9:AddTrigger('ZZ7_CNTISO','ZZ7_DSISO'  ,,{||GetIsoInfo('ZZ7_DSISO')})
	oStructZZ9:AddTrigger('ZZ7_CNTISO','ZZ7_CNTTAM' ,,{||GetIsoInfo('ZZ7_CNTTAM')})
	oStructZZ9:AddTrigger('ZZ7_CPID'  ,'ZZ7_CPDS'   ,,{||GetImoInfo('ZZ7_CPDS')})
	oStructZZ9:AddTrigger('ZZ7_CPID'  ,'ZZ7_CPRISC' ,,{||GetImoInfo('ZZ7_CPRISC')})
	
	oModel := MPFormModel():New('PRAA807',,{|oModel|A807BPOS(oModel)})
	oModel:SetDescription("Registro de Contêiner")
	
	oModel:AddFields('PRAA807_ZZ7', Nil, oStructZZ7,,,)
	oModel:GetModel('PRAA807_ZZ7'):SetDescription("Container")
	
	oModel:AddFields('PRAA807_ZZ8', 'PRAA807_ZZ7', oStructZZ8,,,,,)
	oModel:GetModel('PRAA807_ZZ8'):SetDescription("Programação")
	
	oModel:AddFields('PRAA807_ZZ9', 'PRAA807_ZZ7', oStructZZ9,,,)
	oModel:GetModel('PRAA807_ZZ9'):SetDescription("Container")
	
	oModel:SetPrimaryKey({'ZZ7_RESERV','ZZ7_CNTID'})
	
	oModel:InstallEvent("_A807EVENT",, _A807EVENT():New())
	
	oModel:SetActivate ( { |oMod| A807ATIVAR( oMod ) }) 
	oModel:SetVldActivate({|oModel| A807ACTIVE(oModel)})
Return oModel

Static Function ViewDef()
	Local oView := FWFormView():New()
	Local oModel := FWLoadModel('PRAA807')
	Local oStructZZ7	:= FWFormViewStruct():New()
	Local oStructZZ8	:= FWFormViewStruct():New()
	Local oStructZZ9	:= FWFormViewStruct():New()
    Default ALTERA := .F.
	
	lEdit := !ALTERA
	
	oStructZZ7:AddFolder('01','Reserva')
	
	oStructZZ9:AddFolder('01','Dados do Contêiner')

	oStructZZ9:AddGroup("Container", "Container", '01', 2)
	oStructZZ9:AddGroup("compl", "Complementos", '01', 2)
	
	//Reserva:
	oStructZZ7:AddField("ZZ7_RESERV", "01","Reserva"	, "Código da reserva", ,"C","@!"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/,"Reserva"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)	
	oStructZZ7:AddField("ZZ7_DSRESR", "02","Tipo"	, "Tipo da reserva"	,  ,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/,"Reserva"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ7:AddField("ZZ7_BENDS" , "03","Beneficiário"	, "Beneficiário"	,  ,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/,"Reserva"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ7:AddField("ZZ7_NAVIO" , "04","Navio"	, "Navio"			,  ,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/,"Reserva"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ7:AddField("ZZ7_VIAGEM", "05","Viagem"	, "Viagem"			,  ,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/,"Reserva"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	//reserva
	oStructZZ8:AddField("ZZ8_TRPID"  , "01","Cod.Progr.", "Cod.Progr.",  ,"C",Replicate("9",10)/*PIC*/,/*BPIC*/,'SRTRID'/*LOOKUP*/,lEdit/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ8:AddField("ZZ8_CNTISO" , "02","ISO"       , "ISO"       ,  ,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ8:AddField("ZZ8_CNTTAM" , "03","Tamanho"   , "Tamanho"   ,  ,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ8:AddField("ZZ8_QTPRG"  , "04","Qtde Prog" , "Qtde Prog" ,  ,"N",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ8:AddField("ZZ8_QTREG"  , "05","Qtde Reg"  , "Qtde Reg"  ,  ,"N",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ8:AddField("ZZ8_STATUS" , "06","Situacao"  , "Situacao"  ,  ,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,{"0=VAZIO","1=CHEIO"}/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)

	//container
	oStructZZ9:AddField("ZZ7_CNTID"  ,"01","Contêiner"       ,"Contêiner"       , ,"C", "@!"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/     ,"Container"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ9:AddField("ZZ7_CNTISO" ,"02","Tipo ISO"        ,"Tipo ISO"        , ,"C", "@!"/*PIC*/,/*BPIC*/,'SARISO'/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"Container"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ9:AddField("ZZ7_DSISO"  ,"03","Descrição","Descrição", , "C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/     ,"Container"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ9:AddField("ZZ7_CNTTAM" ,"04","Tamanho"         ,"Tamanho"         , , "C","@!"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/     ,"Container"/*CGROUP*/,a_Cnt_Tipo/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/) 
	oStructZZ9:AddField("ZZ7_TAR"    ,"05","Tara (Kg)"       ,"Tara (Kg)"       , , "C","@E 99,999,999.99" /*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/        ,"Container"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ9:AddField("ZZ7_MGW"    ,"06","MGW (Kg)"       ,"MGW (Kg)"       , , "C","@E 99,999,999.99" /*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/        ,"Container"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	
	//Complementares
	oStructZZ9:AddField("ZZ7_CPID"  ,"06","Código IMO"	       ,"Código IMO"	     , , "C","@!"/*PIC*/,/*BPIC*/,'SARIMO'/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/    ,"compl"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/) 
	oStructZZ9:AddField("ZZ7_CPDS"  ,"07","Descrição"      ,"Descrição"      , , "C", /*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/    ,"compl"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ9:AddField("ZZ7_CPRISC","08","Classe de risco"    ,"Classe de risco"    , , "C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/     ,"compl"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ9:AddField("ZZ7_LACRE1","09","Lacre 1","Lacre 1", , "C","@!"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"compl"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ9:AddField("ZZ7_LACRE2","10","Lacre 2","Lacre 2"                   , , "C","@!"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"compl"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ9:AddField("ZZ7_TMP"    ,"11","Temperatura (ºC)","Temperatura (ºC)" , , "C","@E 99,999,999.99" /*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/        ,"compl"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ9:AddField("ZZ7_VAR"    ,"12","Variação (ºC)","Variação (ºC)", , "C","@E 99,999,999.99" /*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/        ,"compl"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ9:AddField("ZZ7_CMP"    ,"13","Excedente Comp (m)","Excedente Comp (m)", , "C","@E 99,999,999.99" /*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/        ,"compl"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ9:AddField("ZZ7_LRG"    ,"14","Excedente Larg (m)","Excedente Larg (m)" , , "C","@E 99,999,999.99" /*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/        ,"compl"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ9:AddField("ZZ7_ALT"    ,"15","Excedente Alt (m)" ,"Excedente Alt (m)" , , "C","@E 99,999,999.99" /*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/        ,"compl"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	oView:SetModel(oModel)
	oView:AddField( "PRAA807_ZZ7" , oStructZZ7, /*cLinkID*/ )
	oView:AddField( "PRAA807_ZZ8" , oStructZZ8, /*cLinkID*/ )	
	oView:AddField( "PRAA807_ZZ9" , oStructZZ9, /*cLinkID*/ )
	
	oView:CreateHorizontalBox( "MASTER1" , 30,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox( "DETAIL1" , 25,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox( "MASTER2" , 45,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	oView:SetOwnerView("PRAA807_ZZ7","MASTER1")
	oView:SetOwnerView("PRAA807_ZZ8","DETAIL1")

	oView:SetOwnerView("PRAA807_ZZ9","MASTER2")
	
Return oView

Function A807PARAM(lMostra)
	Local lRet      := .F.
	Local afltr     := {}
	Local nX
	Default lMostra := .T.
	
	cParam := cParam02
	
	SetMVValue('PRAA807A', 'MV_PAR01', '')
	lRet := Pergunte('PRAA807A',lMostra,,.T.)
	
	lRetParam  := lRet
	afltr2     := {}
	cParam02   := IIF(Empty(MV_PAR01), cParam, MV_PAR01)
	afltr      := {}
	cFiltroSql := ''
	
	If !lMostra 
	    lRet     := .T.
	    lMostra  := .T.
	EndIf
	
	If !lRet
	  Return 
	ElseIf(Empty(cParam02))
	    MsgInfo('É necessário informar o número da reserva antes de prosseguir.')
		A807PARAM()	
	ElseIf lRet
	
	    SetMVValue('PRAA807A', 'MV_PAR01', '')
	    	
		If !Empty(AllTrim(cParam02))
			If !S_ValidRes(cParam02)
				MsgInfo('A reserva informada não foi localizada.')
				A807PARAM()
			EndIf
			
			If S_ValResF(cParam02)
				MsgInfo('A reserva informada está fechada e não pode ser modificada.')
				A807PARAM()
			EndIf
			
			If S_ValResC(cParam02)
				MsgInfo('A reserva informada está cancelada e não pode ser modificada.')
				A807PARAM()
			EndIf
			
			aAdd(afltr, {" c.res_numero = '" + ALLTRIM(cParam02) + "'","Reserva: " + ALLTRIM(cParam02)})
			if cEmpPai <> SGetTerm()
				cFiltroSql := " and exists (select 1  "
		   		cFiltroSql += " from vw_portal_permissao_acesso "
		        cFiltroSql += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "'"
		        cFiltroSql += " and cli_id_acesso_info = c.cli_id) "
		        afltr[1][1] += cFiltroSql
			endif	
		EndIf
		cFiltroSql := ""
		For nX := 1 To Len(afltr)
			If !Empty(cFiltroSql)
				cFiltroSql += " AND "
			EndIf
			cFiltroSql +=  afltr[nX][1]
			aAdd(afltr2,afltr[nX][2])
		Next nX
		
		If !Empty(cFiltroSql)
			cFiltroSql := " WHERE " + cFiltroSql
		EndIf
		MontaDados()
		If !Empty(PnlFltr)
			PnlFltr:SetList(afltr2)
			PnlFltr:Build()
		EndIf
		If !Empty(PnlFltr2)
			PnlFltr2:SetList(aLst)
			PnlFltr2:Build()
		EndIf
		
	Else 
	    lRetParam := .F. 
	EndIf
	
Return lRet

Function A807ATIVAR(oModel)
    //Seta os dados da reserva
    If !(lRetAtivar)
    	lRetAtivar := A807LOAD(oModel:GetModel('PRAA807_ZZ7'),'PRAA807_ZZ7',oModel)
    	lRetAtivar := .T.
    EndIf
    	
	//Seta os dados da programação
	If lRetAtivar
		A807PROG(oModel:GetModel('PRAA807_ZZ8'),'PRAA807_ZZ8',oModel)
		lRetAtivar := .F.
	EndIf
Return

/*/{Protheus.doc} A807LOAD
//TODO Descrição auto-gerada.
Faz o load dos dados da reserva
@author Mohamed S. B.
@since 08/05/2018
@version undefined
@param oModel, object, descricao
@param cModel, characters, descricao
@param oModelGen, object, descricao
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Function A807LOAD(oModel,cModel,oModelGen)
	Local lRet := .F.
	Local cQuery
	Local cAlTmp
	Local nOp := oModelGen:GetOperation()
	If ((cModel == 'PRAA807_ZZ7') .And. (nOp == 3))
		cAlTmp := GetNextAlias()
		cQuery := "SELECT                                "+;
				   "    c.res_id     ZZ7_RESID ,          "+;
		           "    c.res_numero ZZ7_RESERV,          "+;
		           "   k.res_tipo_descricao ZZ7_DSRESR,   "+;
 				   " (CASE LEN(j.cli_cgc)                 "+;
				   "      WHEN 14 then                    "+; 
				   "         SUBSTRING(j.cli_cgc,1,2)++'.'++SUBSTRING(j.cli_cgc,3,3)++'.'++SUBSTRING(j.cli_cgc,6,3)++'/'++SUBSTRING(j.cli_cgc,9,4)++'-'++SUBSTRING(j.cli_cgc,13,2) "+; 
				   "      WHEN 11 then                    "+;
 				   "         SUBSTRING(j.cli_cgc,1,3)++'.'++SUBSTRING(j.cli_cgc,4,3)++'.'++SUBSTRING(j.cli_cgc,7,3)++'-'++SUBSTRING(j.cli_cgc,10,2) "+;
	 			   "      ELSE                            "+;
				   "         j.cli_cgc                    "+;
			 	   " END)++' - '++j.cli_nome ZZ7_BENDS,   "+;
				   "   l.nav_n2 ZZ7_NAVIO,                "+;
				   "   m.vgm_numero ZZ7_VIAGEM            "+;
		           "  FROM tab_reserva c                  "+;
		           "  LEFT OUTER JOIN tab_clientes j      "+;
				   "    ON j.cli_id = c.cli_id            "+;
				   "  LEFT OUTER JOIN tab_viagem m        "+;
				   "    ON m.vgm_id = c.vgm_id            "+;
				   "  LEFT OUTER JOIN tab_navios l        "+;
				   "    ON l.nav_id = m.vei_id            "+;
				   "  LEFT OUTER JOIN tab_reserva_tipo k  "+;
				   "    ON k.res_tipo = c.res_tipo        "+;
				   "  where c.res_numero = '" + AllTrim(cParam02) + "'"
		
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAlTmp,.F.,.T.)
		If !Empty((cAlTmp)->ZZ7_RESID)
			oModel:LoadValue("ZZ7_RESID" ,(cAlTmp)->ZZ7_RESID )
			oModel:LoadValue("ZZ7_RESERV",(cAlTmp)->ZZ7_RESERV)
			oModel:LoadValue("ZZ7_DSRESR",(cAlTmp)->ZZ7_DSRESR)
			oModel:LoadValue("ZZ7_BENDS" ,(cAlTmp)->ZZ7_BENDS )
			oModel:LoadValue("ZZ7_NAVIO" ,(cAlTmp)->ZZ7_NAVIO )
			oModel:LoadValue("ZZ7_VIAGEM",(cAlTmp)->ZZ7_VIAGEM)

			lRet := .T.
		EndIf
		(cAlTmp)->(dbCloseArea())
	EndIf
Return lRet

/*/{Protheus.doc} A807PROG
//TODO Descrição auto-gerada.
Faz o load dos dados da programação
@author Mohamed S. B.
@since 08/05/2018
@version undefined
@param oModel, object, descricao
@param cModel, characters, descricao
@param oModelGen, object, descricao
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Function A807PROG(oModel,cModel,oModelGen)
	Local cQuery
	Local cAlTmp
	Local nOp := oModelGen:GetOperation()
	
	If ((cModel == 'PRAA807_ZZ8') .And. (nOp == 4))
		cAlTmp := GetNextAlias()
		cQuery := "SELECT                                                                                "+;
             "  a.trp_id ZZ8_TRPID,                                                                      "+;
             "  a.tiso_id ZZ8_CNTISO,                                                                    "+;
             "  coalesce(a.trp_cnt_tamanho,20) ZZ8_CNTTAM,                                               "+;
             "  a.trp_qtde ZZ8_QTPRG ,                                                                   "+;
             "  (select COUNT(trp_id) from tab_reserva_container x where x.trp_id = a.trp_id) ZZ8_QTREG ,"+;
             "  coalesce(a.trp_cnt_cheio,0) ZZ8_STATUS      "+;
             "  from tab_reserva_programacao a where a.res_id = " + cValToChar((cAliasZZ7)->ZZ7_RESID) + ;
             " and a.esp_id = 'CC' and a.trp_id = " + cValToChar((cAliasZZ7)->ZZ8_TRPID)
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAlTmp,.F.,.T.)
		If !Empty((cAlTmp)->ZZ8_TRPID)
			oModel:LoadValue('ZZ8_TRPID' ,cValToChar((cAltmp)->ZZ8_TRPID) )
			oModel:LoadValue('ZZ8_CNTISO',(cAltmp)->ZZ8_CNTISO)
			oModel:LoadValue('ZZ8_CNTTAM',cValToChar((cAltmp)->ZZ8_CNTTAM))
			oModel:LoadValue('ZZ8_QTPRG' ,(cAltmp)->ZZ8_QTPRG )
			oModel:LoadValue('ZZ8_QTREG' ,(cAltmp)->ZZ8_QTREG )
			oModel:LoadValue('ZZ8_STATUS',cValToChar((cAltmp)->ZZ8_STATUS))
		EndIf
       (cAlTmp)->(dbCloseArea())
	EndIf
Return 

Function A807ACTIVE(oModel)
	Local lRet := .T.
	Local cAlTmp
	If Empty(cParam02) .And. oModel:GetOperation() == 3 //Pergunte
		lRet := .F.
		oModel:SetErrorMessage('PRAA807',,,,'3000','É necessário informar uma reserva nos parâmetros antes de registrar um contêiner na reserva.' ,'', nil, nil)
	EndIf
	If (oModel:GetOperation() == 5 .Or. oModel:GetOperation() == 1)  .And. Empty((cAliasZZ7)->ZZ8_CNTTAM)
		If oModel:GetOperation() == 5 
			cAlTmp := GetNextAlias()
			cQuery := 'Select rcnt_id from tab_reserva_rateio_cnt where rcnt_id = ' + cValToChar((cAliasZZ7)->ZZ7_RCNTID)
			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAlTmp,.F.,.T.)
			If !(cAlTmp)->(Eof()) .And. !Empty((cAlTmp)->rcnt_id)
				oModel:SetErrorMessage('PRAA807',,,,'3000','O registro não poderá ser excluido pois existe um ou mais documentos associados a este contêiner.' ,'', nil, nil)
				(cAlTmp)->(dbCloseArea())
				Return .F.
			EndIf
			(cAlTmp)->(dbCloseArea())
		EndIf
		cAlTmp := GetNextAlias()
		cQuery := "SELECT                                                                                 "+;
             "  a.trp_id ZZ8_TRPID,                                                                      "+;
             "  a.tiso_id ZZ8_CNTISO,                                                                    "+;
             "  coalesce(a.trp_cnt_tamanho,20) ZZ8_CNTTAM,                                               "+;
             "  a.trp_qtde ZZ8_QTPRG ,                                                                   "+;
             "  (select COUNT(trp_id) from tab_reserva_container x where x.trp_id = a.trp_id) ZZ8_QTREG ,"+;
             "  coalesce(a.trp_cnt_cheio,0) ZZ8_STATUS      "+;
             "  from tab_reserva_programacao a where a.res_id = " + cValToChar((cAliasZZ7)->ZZ7_RESID) + ;
             " and a.esp_id = 'CC' and a.trp_id = " + cValToChar((cAliasZZ7)->ZZ8_TRPID)
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAlTmp,.F.,.T.)
		RecLock(cAliasZZ7,.F.)
		(cAliasZZ7)->ZZ8_TRPID  := cValToChar((cAltmp)->ZZ8_TRPID) 
		(cAliasZZ7)->ZZ8_CNTISO := (cAltmp)->ZZ8_CNTISO
		(cAliasZZ7)->ZZ8_CNTTAM := cValToChar((cAltmp)->ZZ8_CNTTAM)
		(cAliasZZ7)->ZZ8_QTPRG  := (cAltmp)->ZZ8_QTPRG
		(cAliasZZ7)->ZZ8_QTREG  := (cAltmp)->ZZ8_QTREG
		(cAliasZZ7)->ZZ8_STATUS := cValToChar((cAltmp)->ZZ8_STATUS)
		(cAliasZZ7)->(MsUnlock())
		(cAlTmp)->(dbCloseArea())
	EndIf
	
Return lRet

Function A807RMODAL(cModal)
	Local cRet := ''
	cModal := UPPER(AllTrim(cModal))
	if cModal == 'V'
     cRet := "Rodoviário"
	EndIF
   if cModal == 'F'
     cRet := "Ferroviário"
   EndIF
   if cModal == 'A'
     cRet := "Aéreo"
   EndIF
Return cRet
Function A807Atualizar()
	A807PARAM(.F.)
Return

Function A807SZIMO()
	Local aRet := {}
	Local aFields := {}
	Local cSql := ''

	cSql := "	SELECT cp_id,cp_descricao,cp_classe_risco FROM tab_cargas_perigosas where cp_cancelada = 0"

	Aadd(aRet, 1)
	Aadd(aRet, cSql)
	Aadd(aRet, 'ORDER BY cp_id')

              //aFields,   cCampo         ,  cDesc          , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "cp_id"          , 'Código'          , "C"  , 10      , 0        , ""      , .T.     , .T., .T., 1)
	SAddPField(@aFields , "cp_descricao"   , 'Descrição'       , "C"  , 80      , 0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "cp_classe_risco", 'Classe de risco' , "C"  , 10      , 0        , ""      , .T.     , .F.)

	Aadd(aRet, aFields)

return aRet

Static Function VAL_ISO()
	Local lRet := .T.
	Local cQuery := ""
	Local oModel := FwModelActive()
	Local oModelZZ9 := oModel:GetModel('PRAA807_ZZ9') //Container
	Local oModelZZ8 := oModel:GetModel('PRAA807_ZZ8') //Programacao
	Local cIso	:= oModelZZ9:GetValue('ZZ7_CNTISO')
	
	
        oModelZZ9:Loadvalue('ZZ7_TMP', 0)
        oModelZZ9:Loadvalue('ZZ7_VAR', 0)
        oModelZZ9:Loadvalue('ZZ7_CMP', 0)
        oModelZZ9:Loadvalue('ZZ7_LRG', 0)
        oModelZZ9:Loadvalue('ZZ7_ALT', 0)    	
	
	If !Empty(cIso)
		cQuery := "SELECT tiso_id,tiso_descricao,tiso_tamanho FROM tab_tipo_iso where tiso_id = '" +  alltrim(cIso) + "'"
		
		cAlTiso := GetNextAlias()
			
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlTiso, .F., .T.)
		
		If (cAlTiso)->(Eof()) .Or. Empty((cAlTiso)->tiso_id)
			lRet := .F.
			(cAlTiso)->(dbCloseArea())
			cAlTiso := ""
		else
			if  !Empty(alltrim(oModelZZ8:GetValue("ZZ8_CNTISO"))) .And. alltrim(oModelZZ8:GetValue('ZZ8_CNTISO')) <> alltrim(oModelZZ9:GetValue('ZZ7_CNTISO'))
				oModel:SetErrorMessage('PRAA807',,,,'3000','O tipo ISO do contêiner é inválido: ' + alltrim((cAlTiso)->tiso_id) + Chr(13) + 'Atenção! O tipo ISO do contêiner deve ser igual ao tipo ISO da programação. ',nil,nil)
       		lRet := .F.
       	else
          		if !Empty((cAlTiso)->tiso_tamanho) 
         			If Empty(alltrim(oModelZZ8:GetValue("ZZ8_CNTISO"))) .And. UPPER(ALLTRIM(oModelZZ8:GetValue('ZZ8_CNTTAM'))) != UPPER(ALLTRIM((cAlTiso)->tiso_tamanho))
						oModel:SetErrorMessage('PRAA807',,,,'3000','Atenção! O tamanho do tipo ISO do contêiner deve ser igual ao tamanho da programação. ',nil,nil)
						lRet := .F.
					endif       				
				endif
			endif			
		EndIf
	EndIf
	
Return lRet

Static Function GetIsoInfo(cCpo)
Local cRet
	If !Empty(cAlTiso)
		If cCpo == 'ZZ7_DSISO'
			cRet := (cAlTiso)->tiso_descricao
		ElseIf cCpo == 'ZZ7_CNTTAM' 
			cRet := (cAlTiso)->tiso_tamanho
			(cAlTiso)->(dbCloseArea())
			cAlTiso := ""
		EndIf
	Else
		cRet := ""
	EndIf
Return cRet

Static Function VAL_IMO()
	Local lRet := .T.
	Local cQuery := ""
	Local oModel := FwModelActive()
	Local oModelZZ9 := oModel:GetModel('PRAA807_ZZ9')
	Local cCpId	:= oModelZZ9:GetValue('ZZ7_CPID')
	If !Empty(cCpId)
		cQuery := "SELECT cp_id,cp_descricao,cp_classe_risco FROM tab_cargas_perigosas where cp_cancelada = 0 and cp_id = '" + cCpId + "'"
		
		If Empty(cAlImo)
			cAlImo := GetNextAlias()
		EndIf
			
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlImo, .F., .T.)
		If (cAlImo)->(Eof()) .Or. Empty((cAlImo)->cp_id)
			lRet := .F.
			(cAlImo)->(dbCloseArea())
			cAlImo := ""
		EndIf
	EndIf
Return lRet

Static Function GetImoInfo(cCpo)
Local cRet
	If !Empty(cAlImo)
		If cCpo == 'ZZ7_CPDS'
			cRet := (cAlImo)->cp_descricao
		ElseIf cCpo == 'ZZ7_CPRISC'
			cRet := (cAlImo)->cp_classe_risco
			(cAlImo)->(dbCloseArea())
			cAlImo := ""
		EndIf
	Else
		cRet := ""
	EndIf
Return cRet

Static Function VAL_TRPID()
	Local lRet := .T.
	Local cQuery := ""
	Local oModel := FwModelActive()
	Local oModelZZ8 := oModel:GetModel('PRAA807_ZZ8')
	Local cTrpId	:= oModelZZ8:GetValue('ZZ8_TRPID')
	Local oModelZZ9 := oModel:GetModel('PRAA807_ZZ9')
	
	
        oModelZZ9:Loadvalue('ZZ7_TMP', 0)
        oModelZZ9:Loadvalue('ZZ7_VAR', 0)
        oModelZZ9:Loadvalue('ZZ7_CMP', 0)
        oModelZZ9:Loadvalue('ZZ7_LRG', 0)
        oModelZZ9:Loadvalue('ZZ7_ALT', 0) 	
	
	If !Empty(cTrpId)
		cQuery := "SELECT                                                                                    "+;
             "  a.trp_id ZZ8_TRPID,                                                                      "+;
             "  a.tiso_id ZZ8_CNTISO,                                                                    "+;
             "  coalesce(a.trp_cnt_tamanho,20) ZZ8_CNTTAM,                                               "+;
             "  a.trp_qtde ZZ8_QTPRG ,                                                                   "+;
             "  (select COUNT(trp_id) from tab_reserva_container x where x.trp_id = a.trp_id) ZZ8_QTREG ,"+;
             "  coalesce(a.trp_cnt_cheio,0) ZZ8_STATUS      "+;
             "  from tab_reserva_programacao a where a.res_id = " + cValToChar(oModel:GetModel('PRAA807_ZZ7'):GetValue("ZZ7_RESID")) + ;
             " and a.esp_id = 'CC' and a.trp_id = " + cTrpId
		
		If Empty(cAlTrpId)
			cAlTrpId := GetNextAlias()
		EndIf
			
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlTrpId, .F., .T.)
		If (cAlTrpId)->(Eof()) .Or. Empty((cAlTrpId)->ZZ8_TRPID)
			lRet := .F.
		Else
			oModelZZ8:LoadValue('ZZ8_CNTISO',(cAlTrpId)->ZZ8_CNTISO)
			oModelZZ8:LoadValue('ZZ8_CNTTAM',cValToChar((cAlTrpId)->ZZ8_CNTTAM))
			oModelZZ8:LoadValue('ZZ8_QTPRG' ,(cAlTrpId)->ZZ8_QTPRG )
			oModelZZ8:LoadValue('ZZ8_QTREG' ,(cAlTrpId)->ZZ8_QTREG )
			oModelZZ8:LoadValue('ZZ8_STATUS',cValTochar((cAlTrpId)->ZZ8_STATUS))
			If Empty((cAlTrpId)->ZZ8_CNTISO)
				oModelZZ9:SetValue('ZZ7_CNTTAM',(cAlTrpId)->ZZ8_CNTTAM )
			Else
				oModelZZ9:SetValue('ZZ7_CNTISO',(cAlTrpId)->ZZ8_CNTISO )	
			EndIf
			
		EndIf
		(cAlTrpId)->(dbCloseArea())
		cAlTrpId := ""
	EndIf

Return lRet

Function A807SZTRID()
	Local aRet := {}
	Local aFields := {}
	Local cSql := ''
	Local oModel := FwModelActive()
	cSql := "SELECT                                                                                    "+;
             "  a.trp_id ZZ8_TRPID,                                                                      "+;
             "  a.tiso_id ZZ8_CNTISO,                                                                    "+;
             "  coalesce(a.trp_cnt_tamanho,20) ZZ8_CNTTAM,                                               "+;
             "  a.trp_qtde ZZ8_QTPRG ,                                                                   "+;
             "  (select COUNT(trp_id) from tab_reserva_container x where x.trp_id = a.trp_id) ZZ8_QTREG ,"+;
             "  CASE a.trp_cnt_cheio WHEN 1 THEN 'CHEIO' ELSE 'VAZIO' END ZZ8_STATUS      "+;
             "  from tab_reserva_programacao a where a.res_id = " + cValToChar(oModel:GetModel('PRAA807_ZZ7'):GetValue("ZZ7_RESID")) + ;
             " and a.esp_id = 'CC'"

	Aadd(aRet, 1)
	Aadd(aRet, cSql)
	Aadd(aRet, 'ORDER BY ZZ8_TRPID')

              //aFields,   cCampo         ,  cDesc          , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "ZZ8_TRPID"      , "Cod.Progr." , "C",10,0        , ""      , .T.     , .T., .T., 1)
	SAddPField(@aFields , "ZZ8_CNTISO"     , "ISO"        , "C",04,0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "ZZ8_CNTTAM"     , "Tamanho"    , "C",02,0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "ZZ8_QTPRG"      , "Qtde Prog"  , "N",13,0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "ZZ8_QTREG"      , "Qtde Reg"   , "N",13,0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "ZZ8_STATUS"     , "Situacao"   , "C",05,0        , ""      , .T.     , .F.)
	
	Aadd(aRet, aFields)
	
Return aRet

Function A807BPOS(oModel)
	Local lRet := .T.
	Local oModelZZ8 := oModel:GetModel('PRAA807_ZZ8')
	Local oModelZZ9 := oModel:GetModel('PRAA807_ZZ9')
	
	If oModel:GetOperation() != 5
		If UPPER(ALLTRIM(oModelZZ8:GetValue('ZZ8_CNTTAM'))) != UPPER(ALLTRIM(oModelZZ9:GetValue('ZZ7_CNTTAM')))
			oModel:SetErrorMessage('PRAA807',,,,'3000','O tamanho do contêiner deve ser o mesmo do item da programação.' ,'', nil, nil)
			lRet := .F.
		ElseIf !Empty(oModelZZ8:GetValue('ZZ8_CNTISO')) .And. UPPER(ALLTRIM(oModelZZ8:GetValue('ZZ8_CNTISO'))) != UPPER(ALLTRIM(oModelZZ9:GetValue('ZZ7_CNTISO')))
			oModel:SetErrorMessage('PRAA807',,,,'3000','O ISO do contêiner deve ser o mesmo do item da programação.' ,'', nil, nil)
			lRet := .F.
		EndIf
		
		If oModel:GetOperation() == 3 .And. oModelZZ8:GetValue("ZZ8_QTREG") >= oModelZZ8:GetValue("ZZ8_QTPRG")
			oModel:SetErrorMessage('PRAA807',,,,'3000','Todos os contêineres programados já foram registrados.' ,'', nil, nil)
			lRet := .F.
		EndIf
	EndIf
Return lRet

Function A807BCOMMIT(oModel)
	Local lRet := .T.
	Local nOp := oModel:GetOperation()
	Local oModelZZ7 := oModel:GetModel('PRAA807_ZZ7')
	Local oModelZZ8 := oModel:GetModel('PRAA807_ZZ8')
	Local oModelZZ9 := oModel:GetModel('PRAA807_ZZ9')
	Local aResult
	
	aResult := TCSPExec("proc_diu_tab_reserva_container", nOp,; // @w_operacao	int
						oModelZZ7:GetValue('ZZ7_RCNTID'),; // @w_rcnt_id	int
						Val(oModelZZ8:GetValue('ZZ8_TRPID' )),; // @w_trp_id	int
						oModelZZ9:GetValue('ZZ7_CNTID' ),; // @w_cnt_id	varchar	11
						oModelZZ9:GetValue('ZZ7_CPID'  ),; // @w_cp_id	varchar	10
						oModelZZ9:GetValue('ZZ7_LACRE1'),; // @w_rcnt_lacre_manifestado	varchar	30
						oModelZZ9:GetValue('ZZ7_LACRE2'),; // @w_rcnt_lacre_manifestado2	varchar	30
						oModelZZ9:GetValue("ZZ7_CNTISO"),; // @w_tiso_id	varchar(04) = null,
						oModelZZ9:GetValue("ZZ7_CNTTAM"),; // @w_cnt_tipo	varchar(02) = null,
						oModelZZ9:GetValue("ZZ7_TAR"   ),; // @w_cnt_tara	float = null
						oModelZZ9:GetValue("ZZ7_MGW"   ),; // @w_cnt_mgw 	float = null
						oModelZZ9:GetValue("ZZ7_TMP"   ),; // @w_rcnt_temperatura float = null
						oModelZZ9:GetValue("ZZ7_VAR"   ),; // @w_rcnt_variacao_temper float = null
						oModelZZ9:GetValue("ZZ7_CMP"   ),; // @w_rcnt_compr_excedente float = null
						oModelZZ9:GetValue("ZZ7_LRG"   ),; // @w_rcnt_largura_excedente float = null
						oModelZZ9:GetValue("ZZ7_ALT"   ); // @w_rcnt_altura_excedente float = null
					)                                       
	IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''                     
		cErro := AllTrim(TCSQLError())
		oModel:SetErrorMessage('PRAA806',,,,,cErro )
		lRet := .F.
	elseIF !empty(aResult) .And. AllTrim(aResult[1]) <> ''
		cErro := "Ocorreu um erro no processo da gravação do documento"+Chr(13)+AllTrim(aResult[1])
		oModel:SetErrorMessage('PRAA806',,,,,cErro )
		lRet := .F.
	EndIF
	
	If oModel:GetOperation() != 5
		RecLock(cAliasZZ7,.F.)
		(cAliasZZ7)->ZZ7_CNTISO := oModelZZ9:GetValue("ZZ7_CNTISO")
		(cAliasZZ7)->ZZ7_CNTTAM := oModelZZ9:GetValue("ZZ7_CNTTAM")
		(cAliasZZ7)->ZZ7_STATUS := oModelZZ8:GetValue("ZZ8_STATUS")
		(cAliasZZ7)->ZZ7_CNTID  := oModelZZ9:GetValue("ZZ7_CNTID" )
		(cAliasZZ7)->ZZ7_DSISO  := oModelZZ9:GetValue("ZZ7_DSISO" )
		(cAliasZZ7)->ZZ7_TAR    := oModelZZ9:GetValue("ZZ7_TAR"   )
		(cAliasZZ7)->ZZ7_MGW    := oModelZZ9:GetValue("ZZ7_MGW"   )
		(cAliasZZ7)->ZZ7_CPID   := oModelZZ9:GetValue("ZZ7_CPID"  )
		(cAliasZZ7)->ZZ7_CPDS   := oModelZZ9:GetValue("ZZ7_CPDS"  )
		(cAliasZZ7)->ZZ7_CPRISC := oModelZZ9:GetValue("ZZ7_CPRISC")
		(cAliasZZ7)->ZZ7_LACRE1 := oModelZZ9:GetValue("ZZ7_LACRE1")
		(cAliasZZ7)->ZZ7_LACRE2 := oModelZZ9:GetValue("ZZ7_LACRE2")
        (cAliasZZ7)->ZZ7_TMP     := oModelZZ9:GetValue("ZZ7_TMP")
        (cAliasZZ7)->ZZ7_VAR    := oModelZZ9:GetValue("ZZ7_VAR")
        (cAliasZZ7)->ZZ7_CMP    := oModelZZ9:GetValue("ZZ7_CMP")
        (cAliasZZ7)->ZZ7_LRG    := oModelZZ9:GetValue("ZZ7_LRG")
        (cAliasZZ7)->ZZ7_ALT    := oModelZZ9:GetValue("ZZ7_ALT")
		(cAliasZZ7)->ZZ8_TRPID  := oModelZZ8:GetValue("ZZ8_TRPID" )  
		(cAliasZZ7)->ZZ8_CNTISO := oModelZZ8:GetValue("ZZ8_CNTISO") 
		(cAliasZZ7)->ZZ8_CNTTAM := oModelZZ8:GetValue("ZZ8_CNTTAM") 
		(cAliasZZ7)->ZZ8_QTPRG  := oModelZZ8:GetValue("ZZ8_QTPRG" )  
		(cAliasZZ7)->ZZ8_QTREG  := oModelZZ8:GetValue("ZZ8_QTREG" )  
		(cAliasZZ7)->ZZ8_STATUS := oModelZZ8:GetValue("ZZ8_STATUS") 
		(cAliasZZ7)->(MsUnlock())
	EndIf
	A807Atualizar()
Return lRet

Function A807AG()
	Local oFWMVCWin := FWMVCWindow():New()
	Local oModel   
	Local oModelDOC
	Local oModelTMP
	Local oModelCNT
	Local aSz		:= FWGetDialogSize( oMainWnd )
	Local aAreaZZ7 := (cAliasZZ7)->(getArea())
	Local lAdd := .T.
	Local cQuery := ""
	Local cAliasT
	Private aCamposTMP := {}
	Private cAliasTMP  := GetNextAlias()//'TMP'
	Private aCamTMPEve := {}
	Private cAliTMPEve := GetNextAlias()//'EVE'
	Private aCamTMPReb := {}
	Private cAliTMPReb := GetNextAlias()//'REB'
	Private aCamTMPDoc := {}
	Private cAliTMPDoc := GetNextAlias()//'DOC'
	Private aCamTMPAne := {}
	Private cAliTMPAne := GetNextAlias()//'ANE'
	Private aCamTMPPCNT := {}
	Private cAliTMPP := GetNextAlias()//'CNT'
	Private aCamTMPITCAR := {}
	Private cAliTMPITCAR := GetNextAlias()//'ITC'
	Private aCamTMPITDES := {}
	Private cAliTMPITDES := GetNextAlias()//'ITD'
	
	(cAliasZZ7)->(DbSetOrder(2))
	If !(cAliasZZ7)->(dbSeek(cValToChar(1)))
		MsgAlert('Selecione ao menos um contêiner antes de realizar o agendamento.')
		RestArea(aAreaZZ7)
		Return
	EndIf	
	
	If (cAliasZZ7)->(dbSeek(cValToChar(1)))
		While !(cAliasZZ7)->(Eof())
			If !Empty((cAliasZZ7)->ZZ7_PRGAG)
				MsgAlert('O contêiner ' + (cAliasZZ7)->ZZ7_CNTID + " já possui um agendamento registrado.")
				Return
			EndIf
			If (cAliasZZ7)->ZZ7_STATUS == '1' .And. (cAliasZZ7)->ZZ7_QTDOC == 0
				MsgAlert('Não há documentos associados ao contêiner cheio ' + (cAliasZZ7)->ZZ7_CNTID + ".")
				Return
			EndIf
			
			(cAliasZZ7)->(dbSkip())
		EndDo

		(cAliasZZ7)->(dbSeek(cValToChar(1)))
		
		If !Pergunte("PRAA806A")
			Return
		EndIf
		
		//Limpeza da variavel da viagem ferroviaria
		MV_PAR05 := ""
		A802CARPAR()
		
		If (cAliasZZ7)->ZZ7_STATUS == '1' 
			If cTipomodal == "V"
				cSub := SubStr(cValToChar(GetSParam('SUB_OPERACAO_DESCARGA_CNT_CHEIO_RODOVIARIO','','',.T.)),1,10)
			EndIf
			If cTipomodal == "F"
				cSub := SubStr(cValToChar(GetSParam('SUB_OPERACAO_DESCARGA_CNT_CHEIO_FERROVIARIO','','',.T.)),1,10)
			EndIf
			If Empty(cSub)
				Return
			EndIf
		Else
			If cTipomodal == "V"
				cSub := SubStr(cValToChar(GetSParam('SUB_OPERACAO_DESCARGA_CNT_VAZIO_RODOVIARIO','','',.T.)),1,10)
			EndIf
			If cTipomodal == "F"
				cSub := SubStr(cValToChar(GetSParam('SUB_OPERACAO_DESCARGA_CNT_VAZIO_FERROVIARIO','','',.T.)),1,10)
			EndIf
			If Empty(cSub)
				RestArea(aAreaZZ7)
				Return
			EndIf
		EndIf
		
		A802CRI_TABTMP()
		
		oModel   := FWLoadModel("PRAA802")
		oModelDOC:= oModel:GetModel("PRAA802DOC")
		oModelTMP:= oModel:GetModel("PRAA802")
		oModelCNT:= oModel:GetModel("PRAA802CNT")
		
		oModel:SetOperation(3)
		oModel:Activate()
		
		oModelTMP:SetValue('TMP_OPE_ID','2')
		oModelTMP:SetValue('TMP_SUB_ID',cSub)
		
		If (cAliasZZ7)->ZZ7_STATUS != '1' //container vazio
			oModelTMP:SetValue('TMP_CLI_CG',SubStr((cAliasZZ7)->ZZ7_CGCBEN,1,14))
		EndIf
	
		oModelDOC:SetNoInsertLine(.F.)
		oModelDOC:SetNoDeleteLine(.F.)
		oModelDOC:SetNoUpdateLine(.F.)
		oModelCNT:SetNoInsertLine(.F.)
		oModelCNT:SetNoDeleteLine(.F.)
		oModelCNT:SetNoUpdateLine(.F.)
		lAdd := .T.
		While !(cAliasZZ7)->(Eof()) .And. lAdd
		
		//	oModelDOC:SetValue('DOC_PRG_ID',)
		//	oModelDOC:SetValue('DOC_DP_ID' ,)
			If (cAliasZZ7)->ZZ7_MARCAD	== 1
				If (cAliasZZ7)->ZZ7_STATUS == '1'
					cAliasT := GetNextAlias()
					cQuery :=	"SELECT                                        "+;
								"   b.res_numero ZZ4_RESERV,                   "+;
								"   c.doc_id ZZ4_TPDOC,                        "+;
								"   CONVERT(VARCHAR, a.dent_dt_emissao , 103) ZZ4_DTEMIS,"+;
								"   SUBSTRING (a.dent_id,                      "+;
								"              9,                              "+;
								"              13) ZZ4_NRDC,                   "+;
								"case when c.doc_id = 'NF' then                "+;
								"   SUBSTRING (a.dent_id,                      "+;
								"              6,                              "+;
								"              3) else '' end ZZ4_SRDC,        "+;
								"   SUBSTRING (a.dent_id,                      "+;
								"              22,                             "+;
								"              3) ZZ4_TPPROC,                  "+;
								"   a.cfop_id ZZ4_CFOP,                        "+;
								"   j.cfop_descricao ZZ4_DSCFOP,               "+;
								"   d.cli_id ZZ4_BENID,                        "+;
								"   d.cli_nome ZZ4_DSBEN,                      "+;
								"   d.cli_cgc ZZ4_CGCBEN,                      "+;
								"   b.res_id ZZ4_RESID,                        "+;
								"   a.dent_id ZZ4_DENTID                       "+;
								" from tab_tmp_doc_entrada a                   "+;
								" inner join tab_reserva_rateio_cnt e          "+;
								"  on e.dent_id = a.dent_id                    "+;
								"  and e.res_id = a.res_id                    "+;
								"  and e.rcnt_id = " + cValToChar((cAliasZZ7)->ZZ7_RCNTID) +;
								" LEFT OUTER JOIN  tab_reserva b              "+;
								"   ON b.res_id = a.res_id                    "+;
								" LEFT OUTER JOIN tab_documentos c            "+;
								"   ON c.doc_ordem1 = SUBSTRING (a.dent_id,5,1)"+;
								" LEFT OUTER JOIN tab_clientes d              "+;
								"   ON d.cli_id = a.ben_id                    "+;
								" LEFT OUTER JOIN tab_cfop j					"+;
							   	"  ON j.cfop_id = a.cfop_id						"
					DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAliasT,.F.,.T.)
					
					If !(cAliasT)->(Eof()) .And. !Empty((cAliasT)->ZZ4_DENTID)
						While !(cAliasT)->(Eof()) .And. lAdd
							If !oModelDOC:SeekLine({{"DOC_DOC_ID", (cAliasT)->ZZ4_DENTID}})
								If (cAliasZZ7)->ZZ7_STATUS == '1' .And. Empty(oModelTMP:GetValue('TMP_CLI_CG'))
									oModelTMP:SetValue('TMP_CLI_CG',SubStr((cAliasT)->ZZ4_CGCBEN,1,14))
								EndIf
								If !Empty(oModelDOC:GetValue('DOC_DOC_ID'))
									oModelDOC:AddLine(.T.)
								EndIf
								oModelDOC:SetValue('DOC_RES_NU',(cAliasT)->ZZ4_RESERV)
								oModelDOC:SetValue('DOC_TPO_ES','E')
								oModelDOC:SetValue('DOC_TPO_DC',(cAliasT)->ZZ4_TPDOC)
								oModelDOC:SetValue('DOC_ANO_DC',cValtochar(Year(CTOD((cAliasT)->ZZ4_DTEMIS))))
								oModelDOC:SetValue('DOC_NUM_DC',(cAliasT)->ZZ4_NRDC)
								oModelDOC:LoadValue('DOC_SER_DC',(cAliasT)->ZZ4_SRDC)
								oModelDOC:LoadValue('DOC_PRC_DC',(cAliasT)->ZZ4_TPPROC)
								oModelDOC:LoadValue('DOC_CFOP'  ,(cAliasT)->ZZ4_CFOP)
								oModelDOC:LoadValue('DOC_CFOP_D',SubStr((cAliasT)->ZZ4_DSCFOP,1,100))
								oModelDOC:LoadValue('DOC_BEN_ID',(cAliasT)->ZZ4_BENID)
								oModelDOC:LoadValue('DOC_BEN_CG',(cAliasT)->ZZ4_CGCBEN) 
								oModelDOC:LoadValue('DOC_BEN'   ,(cAliasT)->ZZ4_DSBEN)
								oModelDOC:SetValue('DOC_RES_ID',cValToChar((cAliasT)->ZZ4_RESID))
								oModelDOC:SetValue('DOC_DOC_ID',(cAliasT)->ZZ4_DENTID)
								If !oModelDOC:VldLineData()
									If !MsgYesNo("O seguinte erro ocorreu ao tentar inserir o documento " + (cAliasT)->ZZ4_NRDC + " : " + oModel:GetErrorMessage()[6] + CRLF + "Prosseguir relacionando os documentos?")
										lAdd := .F.
									EndIf
								EndIf
							Else
								lAdd := .T.
							EndIf
							If lAdd
								If !oModelCNT:SeekLine({{"CNT_CNT_ID",(cAliasZZ7)->ZZ7_CNTID}})
									oModelTMP:SetValue('TMP_PESO',oModelTMP:GetValue('TMP_PESO') + (cAliasZZ7)->ZZ7_TAR + (cAliasZZ7)->ZZ7_PESDOC)
									oModelTMP:SetValue('TMP_QUANT',oModelTMP:GetValue('TMP_QUANT') + 1 )
								EndIf
								If !oModelCNT:SeekLine({{"CNT_DP_DS",(cAliasT)->ZZ4_DENTID},{"CNT_CNT_ID",(cAliasZZ7)->ZZ7_CNTID}})
									
									If !Empty(oModelCNT:GetValue('CNT_CNT_ID'))
										oModelCNT:AddLine(.T.)
									EndIf
									oModelCNT:LoadValue('CNT_CNT_ID',(cAliasZZ7)->ZZ7_CNTID)
									oModelCNT:LoadValue('CNT_TPO_ES','E')
									oModelCNT:LoadValue('CNT_TIS_TA',(cAliasZZ7)->ZZ7_CNTTAM)
									oModelCNT:LoadValue('CNT_TISO_I',(cAliasZZ7)->ZZ7_CNTISO)
									oModelCNT:LoadValue('CNT_CNTCHE',If (cValToChar((cAliasZZ7)->ZZ7_STATUS) == '0', 'N','S'))
									oModelCNT:LoadValue('CNT_QTD_CN','1')
									oModelCNT:LoadValue('CNT_RES_ID',cValToChar((cAliasZZ7)->ZZ7_RESID))
									oModelCNT:LoadValue('CNT_RES_NU',(cAliasZZ7)->ZZ7_RESERV)
									oModelCNT:LoadValue('CNT_DP_DS' ,(cAliasT)->ZZ4_DENTID)
									If !oModelCNT:VldLineData()
										If !MsgYesNo("O seguinte erro ocorreu ao tentar inserir o contêiner " + (cAliasZZ7)->ZZ7_CNTID + " : " + oModel:GetErrorMessage()[6] + CRLF + "Prosseguir relacionando os contêineres?")
											lAdd := .F.
										EndIf
									EndIf
									If lAdd
										(cAliasT)->(dbSkip())
									EndIf
								Else
									lAdd := .T.
								EndIf
							EndIf
						EndDo
					EndIf
					(cAliasT)->(dbclosearea())
					(cAliasZZ7)->(dbSkip())
				Else
					If !Empty(oModelCNT:GetValue('CNT_CNT_ID'))
						oModelCNT:AddLine(.T.)
					EndIf				
					oModelCNT:LoadValue('CNT_CNT_ID',(cAliasZZ7)->ZZ7_CNTID)
					oModelCNT:LoadValue('CNT_TPO_ES','E')
					oModelCNT:LoadValue('CNT_TIS_TA',(cAliasZZ7)->ZZ7_CNTTAM)
					oModelCNT:LoadValue('CNT_TISO_I',(cAliasZZ7)->ZZ7_CNTISO)
					oModelCNT:LoadValue('CNT_CNTCHE',If ( Val((cAliasZZ7)->ZZ7_STATUS) == 0, 'N','S'))
					oModelCNT:LoadValue('CNT_QTD_CN','1')
					oModelCNT:LoadValue('CNT_RES_ID',cValToChar((cAliasZZ7)->ZZ7_RESID))
					oModelCNT:LoadValue('CNT_RES_NU',(cAliasZZ7)->ZZ7_RESERV)
					oModelCNT:LoadValue('CNT_DP_DS' ,'')					
					If !oModelCNT:VldLineData()
						If !MsgYesNo("O seguinte erro ocorreu ao tentar inserir o contêiner " + (cAliasZZ7)->ZZ7_CNTID + " : " + oModel:GetErrorMessage()[6] + CRLF + "Prosseguir relacionando os contêineres?")
							lAdd := .F.
						EndIf
					EndIf
					If lAdd
						oModelTMP:SetValue('TMP_PESO',oModelTMP:GetValue('TMP_PESO') + (cAliasZZ7)->ZZ7_TAR)
						(cAliasZZ7)->(dbSkip())	
					EndIf
				EndIf
			Else
				(cAliasZZ7)->(dbSkip())
			EndIf
		EndDo
		oModelDOC:GoLine(1)
		oModelCNT:GoLine(1)
		oModelDOC:SetNoInsertLine(.T.)
		oModelDOC:SetNoDeleteLine(.T.)
		oModelDOC:SetNoUpdateLine(.T.)
		oModelCNT:SetNoInsertLine(.T.)
		oModelCNT:SetNoDeleteLine(.T.)
		oModelCNT:SetNoUpdateLine(.T.)
		
		oView := FWLoadView("PRAA802")
		oView:SetModel(oModel)
		oView:SetOperation(3)
		                               
		oFWMVCWin:SetUseControlBar(.T.)
		oFWMVCWin:SetView(oView)
		oFWMVCWin:SetCentered(.T.)
		oFWMVCWin:SetPos(aSz[1],aSz[2])
		oFWMVCWin:SetSize(aSz[3],aSz[4]) 
		oFWMVCWin:SetTitle("Agendamento")
		oFWMVCWin:oView:BCloseOnOk := {|| .T. }
		oFWMVCWin:Activate(,{|| .T. })
	EndIf
	
	RestArea(aAreaZZ7)
	delTabTmp(cAliasTMP)
  delTabTmp(cAliTMPEve)
  delTabTmp(cAliTMPReb)
  delTabTmp(cAliTMPDoc)
  delTabTmp(cAliTMPAne)
  delTabTmp(cAliTMPP)
  delTabTmp(cAliTMPITCAR)
  delTabTmp(cAliTMPITDES)
  dbClearAll()
Return

function A807VALEXEC( cAct, cStr, nType,cDsc)
	If IsInCallStack("EXECUTEMDEF")//Verifica se a chamada é pelo menu principal
//		MsgStop("Execute esta ação pelo menu príncipal.")
		lKill := .T.
//		Return
	EndIf
	If cAct == 'VIEWDEF'
		FwExecView(cDsc,cStr,nType)
	Else
		&(cStr)
	EndIf

Return

Function A807KILL() 
	If lKill
		oDialog807:End()
	EndIf
Return

Static Function VAL_CNT()
	Local oModel := FWModelActive()
	Local oModelZZ9 := oModel:GetModel('PRAA807_ZZ9') //CoZZ7_CNTIDntainer
	Local oModelZZ8 := oModel:GetModel('PRAA807_ZZ8') //Programação
	Local cQuery
	Local cAlias
	Local nI
	Private cdigito
	
	if (alltrim(oModelZZ9:GetValue('ZZ7_CNTID')) <> '' )

			if (len(alltrim(oModelZZ9:GetValue('ZZ7_CNTID'))) <> 11 )
				oModel:SetErrorMessage('PRAA807',,,,'3000','O contêiner deve possuir 11 caracteres.' ,'', nil, nil)
				return .F.
			endif

			for nI := 1 to 11
				if nI <= 4
					if isdigit(substring(alltrim(oModelZZ9:GetValue('ZZ7_CNTID')),nI,1))
						oModel:SetErrorMessage('PRAA807',,,,'3000','O número do contêiner é composto por 4 letras e 7 números.' ,'', nil, nil)
						return .F.
					endif
				endif

				if nI > 4
					if isalpha(substring(alltrim(oModelZZ9:GetValue('ZZ7_CNTID')),nI,1))
						oModel:SetErrorMessage('PRAA807',,,,'3000','Digite um valor no formato: AAAA1111111.' ,'', nil, nil)
						return .F.
					endif
				endif
			next nI

				if A802VALDIG(alltrim(oModelZZ9:GetValue('ZZ7_CNTID'))) == .F.
					Msginfo('Dígito de Controle Inválido!'+ Chr(13) +'Dígito Correto: ' + alltrim(cdigito) + Chr(13) +;
					           'Atenção! Confira se o número do contêiner '+Chr(13)+ ;
                               'digitado está correto antes de trocar o dígito.')                                       				
				endif 
				containerAtu := AllTrim(oModelZZ9:GetValue('ZZ7_CNTID'))
				cQuery := "	select isnull(a.cnt_id,'') as cnt_id, "
					cQuery += "		    isnull(a.tiso_id,'') as tiso_id, "
					cQuery += "		    isnull(a.cnt_tara,0) as cnt_tara, "
					cQuery += "		    isnull(a.cnt_mgw,0) as cnt_mgw, "							
					cQuery += "	       b.tiso_tamanho cnt_tipo "
					cQuery += "    from tab_container a"
					cQuery += 	"			left join tab_tipo_iso b "
					cQuery += 	"			on b.tiso_id  = a.tiso_id"
					cQuery += "    where cnt_id = '" + containerAtu + "'"
					calias := getnextalias()
					DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),calias,.F.,.T.)
					
					if alltrim((calias)->cnt_id) <> ''						
						If !Empty(alltrim((calias)->tiso_id))
					    	if !Empty(alltrim(oModelZZ8:GetValue("ZZ8_CNTISO"))) .And. alltrim(oModelZZ8:GetValue("ZZ8_CNTISO")) <> alltrim((calias)->tiso_id)
								oModel:SetErrorMessage('PRAA807',,,,'3000','O tipo ISO do contêiner é inválido: ' + alltrim((calias)->tiso_id) + Chr(13) + 'Atenção! O contêiner selecionado deve ter o mesmo tipo ISO da programação. ',nil,nil)					
            					return .F.							    								    							    
					    	else	
					    		cAtualizaCNT := .T.									
								oModelZZ9:Setvalue('ZZ7_CNTISO',alltrim((calias)->tiso_id))
								cAtualizaCNT := .F.
							endif																
						endif
						
						If !Empty(alltrim((calias)->cnt_tipo))
								if alltrim(oModelZZ8:GetValue("ZZ8_CNTTAM")) <> alltrim((calias)->cnt_tipo)
									oModel:SetErrorMessage('PRAA807',,,,'3000','O tamanho do contêiner é inválido: ' + alltrim((calias)->tiso_id) + Chr(13) + 'Atenção! O contêiner selecionado deve ter o mesmo tamanho da programação. ',nil,nil)
            						return .F.							    								    							    
					    		else	
					    	   		cAtualizaCNT := .T.									
							   		oModelZZ9:Setvalue('ZZ7_CNTTAM',alltrim((calias)->cnt_tipo))
							   		cAtualizaCNT := .F.										
								endif
						else
						   if !Empty(alltrim((calias)->tiso_id)) .And. Empty(alltrim((calias)->cnt_tipo))
								oModel:SetErrorMessage('PRAA807',,,,'3000','O tamanho do contêiner é inválido: ' + alltrim((calias)->tiso_id) + Chr(13) + 'Atenção! O tamanho do contêiner selecionado não está cadastrado. ',nil,nil)
								return .F.
							endif	
					    	  cAtualizaCNT := .T.									
							  oModelZZ9:Setvalue('ZZ7_CNTTAM','')																						
						endif	
						
						oModelZZ9:loadvalue('ZZ7_TAR',(calias)->cnt_tara)	
						oModelZZ9:loadvalue('ZZ7_MGW',(calias)->cnt_mgw)
				
					endif
					(calias)->(dbCloseArea())

				
	else
		oModelZZ9:LOADvalue('ZZ7_CNTISO','')
		oModelZZ9:LOADvalue('ZZ7_DSISO','')
		oModelZZ9:LOADvalue('ZZ7_CNTTAM','')
		oModelZZ9:loadvalue('ZZ7_TAR',0)
	        oModelZZ9:loadvalue('ZZ7_MGW',0)
                oModelZZ9:Loadvalue('ZZ7_TMP', 0)
                oModelZZ9:Loadvalue('ZZ7_VAR', 0)
                oModelZZ9:Loadvalue('ZZ7_CMP', 0)
                oModelZZ9:Loadvalue('ZZ7_LRG', 0)
                oModelZZ9:Loadvalue('ZZ7_ALT', 0)                	        		
	endif
Return .T.

Function CNTEXIST()
	Local cQuery
	Local cAlias
	Local oModel := FWModelActive()
	Local oModelZZ9 := oModel:GetModel('PRAA807_ZZ9')
	If !Empty(oModelZZ9:GetValue('ZZ7_CNTID'))
		calias := getnextalias()
		cQuery := "SELECT CNT_ID FROM TAB_CONTAINER WHERE CNT_ID = '" + oModelZZ9:GetValue('ZZ7_CNTID') + "'"
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),calias,.F.,.T.)
		if alltrim((calias)->cnt_id) <> '' .And. !cAtualizaCNT 
      		(calias)->(dbCloseArea())
			return .F.
		EndIf 
		(calias)->(dbCloseArea())
	EndIf 
Return .T.

Function WHEN_EXCE()
  Local cQuery
  Local cAlias
  Local lRet      := .F. 
  Local oModel    := FWModelActive()  
  Local oModelZZ9 := oModel:GetModel('PRAA807_ZZ9')
  Local oModelZZ8 := oModel:GetModel('PRAA807_ZZ8')  
  Local cTipoIso  := oModelZZ9:GetValue("ZZ7_CNTISO")
  
  If oModelZZ8:GetValue("ZZ8_STATUS") == '1'  
  
     cAlias := getnextalias()
     
     cQuery := "select distinct '1' as carga_excede "
     cQuery += "  from tab_tipo_iso a, "
     cQuery += "       tab_modelo_container b "
     cQuery += " where a.tiso_id = '"+cTipoIso+"'"
     cQuery += "   and a.mc_id   = b.mc_id "
     cQuery += "   and ( b.mc_descricao like '%OPEN%' "
     cQuery += "         or "
     cQuery += "         b.mc_descricao like '%PLATAFORM%' "
     cQuery += "         or "
     cQuery += "         b.mc_descricao like '%FLAT%RACK%' "
     cQuery += "        ) "
      
     DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
      
     if alltrim((cAlias)->carga_excede) = '1'
        (calias)->(dbCloseArea())
        lRet := .T. 
     else 
        (calias)->(dbCloseArea())
     EndIf  
  
  EndIf
  
  if !(lRet)
     oModelZZ9:Loadvalue('ZZ7_CMP', 0)
     oModelZZ9:Loadvalue('ZZ7_LRG', 0)
     oModelZZ9:Loadvalue('ZZ7_ALT', 0)
  Endif  

Return lRet

Function WHEN_REEF()
  Local cQuery
  Local cAlias
  Local lRet      := .F. 
  Local oModel    := FWModelActive()  
  Local oModelZZ9 := oModel:GetModel('PRAA807_ZZ9')
  Local oModelZZ8 := oModel:GetModel('PRAA807_ZZ8')
  Local cTipoIso  := ""
  
  If oModelZZ8:GetValue("ZZ8_STATUS") == '1'    
  
     cTipoIso  := oModelZZ9:GetValue("ZZ7_CNTISO")         
     
     cAlias := getnextalias()
     
     cQuery := "select distinct '1' as reefer "
     cQuery += "  from tab_tipo_iso a, "
     cQuery += "       tab_modelo_container b "
     cQuery += " where a.tiso_id = '"+cTipoIso+"'"
     cQuery += "   and a.mc_id   = b.mc_id "
     cQuery += "   and b.mc_reefer = 1 "
      
     DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
      
     if alltrim((cAlias)->reefer) = '1'
        (calias)->(dbCloseArea())
        lRet := .T. 
     else 
        (calias)->(dbCloseArea())
     EndIf  
     
  EndIf
  
  if !(lRet)
     oModelZZ9:Loadvalue('ZZ7_TMP', 0)
     oModelZZ9:Loadvalue('ZZ7_VAR', 0)
  Endif
Return lRet


