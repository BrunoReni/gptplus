#INCLUDE "Protheus.CH"
#INCLUDE "FWMVCDEF.CH"

Static lRetParam := .T.
/*/{Protheus.doc} PRAA806
	Registro de documentos fiscais
@author siegklenes.beulke
@since 05/03/2015
@version 1.0

@example
	PRAA806()
/*/

Static cParam    := ""
Static cParam02  := ""

Function PRAA806()
    Local aSelEmp
	Local aCoors := FWGetDialogSize( oMainWnd )
	Private oBrowse := FWMBrowse():New()
	Private cAliasZZ4 := ""
	Private cFiltroSql := ""
	Private cAlRes:= ""
	Private cAlTpDoc:= ""
	Private cAlNcm:= ""
	Private cAlVol:= ""
	Private cAlCfop:= ""
	Private cAlBen:= ""
	Private cRetLkSara := ""
	Private PnlFltr
	Private PnlFltr2
	Private oPnlBx
	Private a_PRC_DC := {''}
	Private afltr2 := {}
	Private aLst := {0,0,0,0}
	Private lMarcado := .F.
	Private oPnlTop
	Private oDialog806
	Private cTipoModal
	Private cEmpPai
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
	Private cVarEmp 
	Private cDescEmp
	Private lAbreTela
	Private _cEmpPai
	Private lPergunte := .T. /* Se um dia quiser criar parametro para ligar ou desligar o preenchimento do campo ou não da pergunte. SUPERGETMV("MV_PERGUNT", .T., .F.)*/
	if cUsuario == ""
      MsgStop("Este usuário não está cadastrado no sistema SARA"+Chr(13)+"Entre em contato com o administrador do sistema")
      Return .F.
    EndIF
 
	userInf := A802VACES()
	   
	if sempty(userInf)
		alert('Usuário sem permissão de acesso!')
	   	return .F.
	endif
   
	aSelEmp := A802SELEMP()

	if (lAbreTela = .F.) .or. (alltrim(A802GetcEmpPai()) =  '')
		return .F.
	endif
	cEmpPai := _cEmpPai
	If Empty(cEmpPai)
	    return .F.
	EndIf
	
    cParam02 := ""
	If !A806PARAM()
		Return .F.
	EndIf
	
	If !lRetParam
	   Return .F.
	EndIf
	
	Define MsDialog oDialog806 Title "Registro de documentos fiscais" From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		/* -- Layers -------------------------------------------------- */
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDialog806, .F., .T.)
		
		// Tabela de Frete
		oFWLayer:AddLine('TOP', 90, .F.)
		oFWLayer:AddCollumn('BRW', 100, .T., 'TOP') // Lista
		oPnlTop := oFWLayer:GetColPanel('BRW', 'TOP')
		
		// Negociação
		oFWLayer:AddLine('BOTTON', 5, .F.) 
		oFWLayer:AddCollumn('PNL', 100, .T., 'BOTTON') // Painel 1
		oPnlBx := oFWLayer:GetColPanel('PNL', 'BOTTON')
		
		oFWLayer:AddLine('BOTTON2', 5, .F.) 
		oFWLayer:AddCollumn('PNL2', 100, .T., 'BOTTON2') // Painel 2 
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
		
			
	oBrowse:SetMenuDef("PRAA806") // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Registro de documentos fiscais")
	oBrowse:SetAlias(cAliasZZ4)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetOwner(oPnlTop)
    oBrowse:SetUseFilter(.F.)
	oBrowse:SetFields(GetBrwStru())
	oBrowse:DisableDetails()
	ADD MARKCOLUMN oColumn DATA {|| If(ZZ4_MARCAD == 1, 'LBOK', 'LBNO')};
		DOUBLECLICK {|| RecLock(cAliasZZ4,.F.),(cAliasZZ4)->ZZ4_MARCAD := If((cAliasZZ4)->ZZ4_MARCAD == 1,0,1),(cAliasZZ4)->(MsUnlock())};
		HEADERCLICK {|| A806MarkAll() } OF oBrowse
	oBrowse:Activate()
	Activate MsDialog oDialog806 Center ON INIT  A806KILL()
	If !Empty(PnlFltr)
		PnlFltr:Destroy()
	EndIf
	delTabTmp(cAliasZZ4)
Return

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Visualizar"			 	ACTION "VIEWDEF.PRAA806"	OPERATION 2	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Incluir" 					ACTION "A806VALEXEC('VIEWDEF','PRAA806',3,'Incluir')"	OPERATION 3	ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" 					ACTION "VIEWDEF.PRAA806"	OPERATION 4	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Excluir" 					ACTION "VIEWDEF.PRAA806"	OPERATION 5	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Upload do Documento"		ACTION "PRAA806B(),A806Atualizar()"		OPERATION 3	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Associar Contâiner"		ACTION "PRAA806A(),A806Atualizar()"		OPERATION 4	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Agendamento Descarga S."	ACTION "A806AGDS(),A806Atualizar()"		OPERATION 4	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Imprimir"   				ACTION "VIEWDEF.PRAA806"	OPERATION 8	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Parâmetros" 				ACTION "A806PARAM()"		OPERATION 3	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Atualizar Grid"		 	ACTION "A806Atualizar()"	OPERATION 3	ACCESS 0 DISABLE MENU
	
Return aRotina


Static Function GetStruct()

	Local aStructZZ4 := {{"ZZ4_RESID", "N",  10, 0},;
						{"ZZ4_DENTID", "C",  30, 0},;
						{"ZZ4_NCMID" , "N",  10, 0},;
						{"ZZ4_MARCAD", "N",  01, 0},;
						{"ZZ4_RESERV", "C",  30, 0},;
						{"ZZ4_DSRESR", "C",  50, 0},;
						{"ZZ4_NAVIO" , "C",  50, 0},;
						{"ZZ4_VIAGEM", "C",  15, 0},;
						{"ZZ4_TPDOC" , "C",  10, 0},;
						{"ZZ4_DSDOC" , "C",  50, 0},;
						{"ZZ4_DOCORD", "C",  01 ,0},;
						{"ZZ4_TPPROC", "C",  03, 0},;
						{"ZZ4_CGCBEN", "C",  18, 0},;
						{"ZZ4_BENID" , "C",  06, 0},;
						{"ZZ4_BENCGC", "C",  18, 0},;
						{"ZZ4_DSBEN" , "C",  50, 0},;
						{"ZZ4_DTEMIS", "D",  08, 0},;
						{"ZZ4_NRDC"  , "C",  13, 0},;
						{"ZZ4_SRDC"  , "C",  03, 0},;
						{"ZZ4_VLDC"  , "N",  13, 2},;
						{"ZZ4_VLCOF"  , "N",  13, 2},;
						{"ZZ4_VLACOF"  , "N",  13, 2},;
						{"ZZ4_CDEMB" , "C",  02, 0},;
						{"ZZ4_DSEMB" , "C",  88, 0},;
						{"ZZ4_QTDVOL", "N",  13, 0},;
						{"ZZ4_PESOKG", "N",  13, 2},;
						{"ZZ4_PESCOF", "N",  13, 2},;
						{"ZZ4_PESACF", "N",  13, 2},;
						{"ZZ4_CFOP"  , "C",  05, 0},;
						{"ZZ4_DSCFOP", "C",  100 ,0},;
						{"ZZ4_CHAVE",  "C",  44 ,0},;
						{"ZZ4_QTCONT", "N",  13, 0},;
						{"ZZ4_QTAGEN", "N",  13, 0},;
						{"ZZ4_ISREPO", "C",  03, 0},;
						{"ZZ4_ISUPLO", "C",  03, 0},;
						{"ZZ4_NCMPRD", "C",  10, 0},;
						{"ZZ4_DSNCM" , "C",  100, 0}}
						//{"ZZ4_DSPROC", "C",  50, 0},;
Return aStructZZ4

Static Function GetBrwStru()
	Local aBrwStrZZ4 := {{'Reserva'	,"ZZ4_RESERV", "C",  06, 0},;
						{'Tipo'			,"ZZ4_TPDOC" , "C",  06, 0},;
						{'Número'			,"ZZ4_NRDC"  , "C",  08, 0},;
						{'Série'			,"ZZ4_SRDC"  , "C",  04, 0},;
						{'Proced.'			,"ZZ4_TPPROC", "C",  04, 0},;
						{'CFOP'			,"ZZ4_CFOP"  , "C",  04, 0},;
						{'Emissão'			,"ZZ4_DTEMIS", "D",  06, 0},;
						{'Valor (R$)'		,"Transform(ZZ4_VLDC,'@E 9,999,999,999.99')"  , "N",  06, 2},; 
						{'Peso (KG)'		,"Transform(ZZ4_PESOKG,'@E 9,999,999,999.99')", "N",  06, 2},;
						{'Quant'			,"ZZ4_QTDVOL", "N",  06, 0},;
						{'Embalagem'		,"AllTrim(ZZ4_CDEMB+' - '+ZZ4_DSEMB)" , "C",  06, 0},;
						{'NCM'				,"ZZ4_NCMPRD", "C",  06, 0},;
						{'Beneficiário'	,"AllTrim(ZZ4_CGCBEN+' - '+ZZ4_DSBEN)" , "C",  06, 0},;
						{'Cntr'			,"ZZ4_QTCONT", "N",  04, 0},;
						{'Qtd Agendamento',"ZZ4_QTAGEN", "N",  04, 0},;
						{'Repositório'	,"ZZ4_ISREPO", "C",  04, 0},;
						{'Upload'			,"ZZ4_ISUPLO", "C",  04, 0},;
						{'Chave Acesso (NF-e)'	,"ZZ4_CHAVE"  , "C",  44, 0}}
						
Return aBrwStrZZ4

Static Function MontaDados()
	Local cQueryA806 := "SELECT                                        "+;
							"   b.res_id ZZ4_RESID,                        "+;
							"   b.res_numero ZZ4_RESERV,                   "+;
							"   c.doc_id ZZ4_TPDOC,                        "+;
							"   c.doc_nome ZZ4_DSDOC,                      "+;
							"   c.doc_ordem1 ZZ4_DOCORD,                   "+;
							"   e.res_tipo_descricao ZZ4_DSRESR,           "+;
							"   f.nav_n2 ZZ4_NAVIO,      				     "+;
							"   g.vgm_numero ZZ4_VIAGEM,      			     "+;
							"   a.dent_id ZZ4_DENTID,                       "+;
							"   SUBSTRING (a.dent_id,                      "+;
							"              9,                              "+;
							"              13) ZZ4_NRDC,                   "+;
							"   case when c.doc_id = 'NF' then             "+;
							"   SUBSTRING (a.dent_id,                      "+;
							"              6,                              "+;
							"              3) else '' end ZZ4_SRDC,        "+;
							"   SUBSTRING (a.dent_id,                      "+;
							"              22,                             "+;
							"              3) ZZ4_TPPROC,                  "+;
							"   d.cli_id ZZ4_BENID,                        "+;
							"   d.cli_cgc ZZ4_BENCGC,                      "+;
							"   a.cfop_id ZZ4_CFOP,                        "+;
							"   j.cfop_descricao ZZ4_DSCFOP,               "+;
							" (select tde_chave_nfe from tab_tmp_doc_entrada_comp where dent_id = a.dent_id) as ZZ4_CHAVE, "+;
							"   CONVERT(VARCHAR, a.dent_dt_emissao , 103) ZZ4_DTEMIS,"+;
							"   isnull((select min(lote_cif_tot_br) from tab_tmp_lote where dent_id = a.dent_id),a.dent_cif_tot) ZZ4_VLDC, "+;
							"   a.dent_peso_bruto_tot ZZ4_PESOKG,          "+;
							"   a.dent_qtd_vol_tot ZZ4_QTDVOL,             "+;
							"   i.esp_id ZZ4_CDEMB,                        "+;
							"   i.esp_descricao ZZ4_DSEMB,                 "+;
							"   h.ncm_cod ZZ4_NCMPRD,                      "+;
							"   h.ncm_descricao ZZ4_DSNCM,                 "+;
							"   h.ncm_id ZZ4_NCMID,							  "+;
							"   d.cli_cgc ZZ4_CGCBEN,                      "+;
							"   d.cli_nome ZZ4_DSBEN,                      "+;
							"   (SELECT COUNT (rcnt_id)                     "+;
							"    FROM tab_reserva_rateio_cnt re             "+;
							"    WHERE re.dent_id = a.dent_id) ZZ4_QTCONT, "+;
							"  (select count(distinct prog_id) as qt_agendamento "+;
							"		from rel_dent_programacao ra                    "+;
							"    where ra.dent_id = a.dent_id                  "+;
							"    and exists (select 1 from tab_programacao ta "+;
							"                where ta.prog_id = ra.prog_id "+;
							"					and ta.DT_CANCELAMENTO is null)) ZZ4_QTAGEN, "+;
							"   CASE WHEN EXISTS(SELECT 1 FROM tab_tmp_lote TLOT WHERE TLOT.dent_id = a.dent_id ) THEN 'Sim' Else 'Não' END ZZ4_ISREPO,"+; // SELECT 1 FROM tab_tmp_lote B WHERE A.dent_id 
							"   CASE WHEN EXISTS(SELECT 1 FROM tab_documentos_upload tdocup WHERE tdocup.du_chave = a.dent_id and tdocup.du_tipo_es = 'E') THEN 'Sim' Else 'Não' END ZZ4_ISUPLO "+; // tab_documentos_upload
							" FROM "+;
							" tab_tmp_doc_entrada a                       "+;
							" LEFT OUTER JOIN  tab_reserva b              "+;
							"   ON b.res_id = a.res_id                    "+;
							" LEFT OUTER JOIN tab_documentos c            "+;
							"   ON c.doc_ordem1 = SUBSTRING (a.dent_id,5,1)"+;
							" LEFT OUTER JOIN tab_clientes d              "+;
							"   ON d.cli_id = a.ben_id                    "+;
							" LEFT OUTER JOIN tab_reserva_tipo e          "+;
							"   ON e.res_tipo = b.res_tipo                "+;
							" LEFT OUTER JOIN tab_viagem g       			"+;
							"   ON g.vgm_id = b.vgm_id                	"+;
							" LEFT OUTER JOIN tab_navios f       			"+;
							"   ON f.nav_id = g.vei_id                	"+;
							" LEFT OUTER JOIN tab_ncm h						"+;
						   	"  ON h.ncm_id = a.ncm_id						"+;
						   	" LEFT OUTER JOIN tab_especie i					"+;
						   	"  ON i.esp_id = a.esp_id						"+;
						   	" LEFT OUTER JOIN tab_cfop j					"+;
						   	"  ON j.cfop_id = a.cfop_id						"+;
						   	" LEFT OUTER JOIN rel_cfop_doc k				"+;
						   	"  ON k.cfop_id = j.cfop_id	and k.doc_id = c.doc_id"+;
						   	" LEFT join tab_reserva_doc_cnt l				"+;
						   	" ON l.dent_id = a.dent_id						"+;
						   	"LEFT JOIN vw_inventario_container m			"+;
							"  on  l.mcnt_id = m.mcnt_id					"+;
							" left join tab_container n						"+;
							"  on n.cnt_id = m.cnt_id						" + cFiltroSql +; 
							" UNION											"+;
							"SELECT                                         "+;
						    "b.res_id ZZ4_RESID,                            "+;
						    "b.res_numero ZZ4_RESERV,                       "+;
						    "c.doc_id ZZ4_TPDOC,                            "+;
						    "c.doc_nome ZZ4_DSDOC,                          "+;
						    "c.doc_ordem1 ZZ4_DOCORD,                       "+;
						    "e.res_tipo_descricao ZZ4_DSRESR,               "+;
						    "f.nav_n2 ZZ4_NAVIO,                            "+;
						    "g.vgm_numero ZZ4_VIAGEM,                       "+;
						    "a.dent_id ZZ4_DENTID,                          "+;
						    "SUBSTRING (a.dent_id,                          "+;
						    "           9,                                  "+;
						    "           13) ZZ4_NRDC,                       "+;
						    "case when c.doc_id = 'NF' then                 "+;
						    "SUBSTRING (a.dent_id,                          "+;
						    "           6,                                  "+;
						    "           3) else '' end ZZ4_SRDC,            "+;
						    "SUBSTRING (a.dent_id,                          "+;
						    "           22,                                 "+;
						    "           3) ZZ4_TPPROC,                      "+;
						    "d.cli_id ZZ4_BENID,                            "+;
						    "d.cli_cgc ZZ4_BENCGC,                          "+;
						    "a.cfop_id ZZ4_CFOP,                            "+;
						    "j.cfop_descricao ZZ4_DSCFOP,                   "+;
						    "(select dec_chave_nfe from tab_doc_entrada_complemento where dent_id = a.dent_id) as ZZ4_CHAVE, "+;
						    "CONVERT (VARCHAR, a.dent_dt_emissao,  103) ZZ4_DTEMIS, "+;
						    "(select min(lote_cif_tot_br) from tab_lote where dent_id = a.dent_id) ZZ4_VLDC, "+;
						    "a.dent_peso_bruto_tot ZZ4_PESOKG,              "+;
						    "a.dent_qtd_vol_tot ZZ4_QTDVOL,                 "+;
						    "i.esp_id ZZ4_CDEMB,                            "+;
						    "i.esp_descricao ZZ4_DSEMB,                     "+;
						    "h.ncm_cod ZZ4_NCMPRD,                          "+;
						    "h.ncm_descricao ZZ4_DSNCM,                     "+;
						    "h.ncm_id ZZ4_NCMID,                            "+;
						    "d.cli_cgc ZZ4_CGCBEN,                          "+;
						    "d.cli_nome ZZ4_DSBEN,                          "+;
						    "(SELECT COUNT (rcnt_id)                        "+;
						    " FROM tab_reserva_rateio_cnt re                "+;
						    " WHERE re.dent_id = a.dent_id) ZZ4_QTCONT,     "+;
						    "(SELECT COUNT (DISTINCT prog_id) AS qt_agendamento "+;
						    " FROM rel_dent_programacao ra                  "+;
						    " WHERE ra.dent_id = a.dent_id                  "+;
						    " and EXISTS (SELECT 1                          "+;
						    "             FROM tab_programacao ta           "+;
						    "             WHERE                             "+;
						    "                 ta.prog_id = ra.prog_id AND   "+;
						    "                 ta.DT_CANCELAMENTO IS NULL)) ZZ4_QTAGEN, "+;
						    "'Sim' as ZZ4_ISREPO,                           "+;
						    "CASE WHEN EXISTS (SELECT 1                     "+;
						    "                  FROM tab_documentos_upload tdocup "+;
						    "                  WHERE                        "+;
						    "                      tdocup.du_chave = a.dent_id AND     "+;
						    "                      tdocup.du_tipo_es = 'E') THEN 'Sim' "+;
						    "ELSE 'Não' END ZZ4_ISUPLO                      "+;
							" FROM                                          "+;
						    "tab_doc_entrada a                              "+;
						    "LEFT OUTER JOIN tab_reserva_doc_cnt o          "+;
							"    ON o.dent_id = a.dent_id                   "+;
						    "LEFT OUTER JOIN tab_reserva b                  "+;
						    "	ON b.res_id = o.res_id                      "+;
						    "LEFT OUTER JOIN tab_documentos c               "+;
						    "	ON c.doc_ordem1 = SUBSTRING (a.dent_id, 5, 1) "+;
						    "LEFT OUTER JOIN tab_clientes d                 "+;
						    "	ON d.cli_id = a.ben_id                      "+;
						    "LEFT OUTER JOIN tab_reserva_tipo e             "+;
						    "	ON e.res_tipo = b.res_tipo                  "+;
						    "LEFT OUTER JOIN tab_viagem g                   "+;
						    "	ON g.vgm_id = b.vgm_id                      "+;
						    "LEFT OUTER JOIN tab_navios f                   "+;
						   	"	ON f.nav_id = g.vei_id                      "+;
						    "LEFT OUTER JOIN tab_ncm h                      "+;
						    "	ON h.ncm_id = a.ncm_id                      "+;
						    "LEFT OUTER JOIN tab_especie i                  "+;
						    "	ON i.esp_id = a.esp_id                      "+;
						    "LEFT OUTER JOIN tab_cfop j                     "+;
						    "	ON j.cfop_id = a.cfop_id                    "+;
						    "LEFT OUTER JOIN rel_cfop_doc k                 "+;
							"ON k.cfop_id = j.cfop_id AND k.doc_id = c.doc_id "+;
						    "LEFT JOIN tab_reserva_doc_cnt l                "+;
						    "ON l.dent_id = a.dent_id                       "+;
						    "LEFT JOIN vw_inventario_container m            "+;
						    "ON l.mcnt_id = m.mcnt_id                       "+;
							"LEFT JOIN tab_container n                      "+;
						    "ON n.cnt_id = m.cnt_id                         "+ cFiltroSql //Contém a clausula where
												
						
	Local cAliasTmp
	Local aQryStru
	Local nI
	Default cAliasZZ4 := nil
	
	MV_PAR01 := cParam02
    
	If Empty(cAliasZZ4)
		cAliasZZ4 := GetNextAlias()
		cAliasZZ4 := sCriaTbTmp({GetStruct(),{'ZZ4_NRDC','cValToChar(ZZ4_MARCAD)+ZZ4_DENTID'}})
	Else
		dbSelectArea(cAliasZZ4)
		(cAliasZZ4)->(dbSetOrder(1))
		(cAliasZZ4)->(dbGotop())
		While !(cAliasZZ4)->(Eof())
			RecLock(cAliasZZ4,.F.)
			DBdELETE()
			msunlock()
			(cAliasZZ4)->(dbskip())
		EndDo
	EndIf
	aLst := {0,0,0,0}
	cAliasTmp := GetNextAlias()
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQueryA806)),cAliasTmp,.F.,.T.)
	aQryStru := (cAliasZZ4)->(dbStruct())
	(cAliasTmp)->(dbGoTop())
	While !(cAliasTmp)->(Eof())
	    (cAliasZZ4)->(DbAppend())
	    For nI := 1 To Len(aQryStru)
	        If (cAliasTmp)->(FieldPos(aQryStru[nI,1])) > 0
	        	 If aQryStru[nI,2] == 'D'
	        	 	(cAliasZZ4)->(FieldPut(nI,CTOD((cAliasTmp)->(FieldGet(FieldPos(aQryStru[nI,1]))))))
	        	 ElseIf aQryStru[nI,2] == 'L'
	        	 	(cAliasZZ4)->(FieldPut(nI,(cAliasTmp)->(FieldGet(FieldPos(aQryStru[nI,1]))) == 'T'))
	        	 ElseIf aQryStru[nI,2] <> 'M'
	        	 	(cAliasZZ4)->(FieldPut(nI,(cAliasTmp)->(FieldGet(FieldPos(aQryStru[nI,1])))))
	        	 EndIf
	        EndIf
	    Next nI
	    aLst[1]++
	    aLst[2]+=(cAliasTmp)->ZZ4_VLDC
	    aLst[3]+=(cAliasTmp)->ZZ4_PESOKG
	    aLst[4]+=(cAliasTmp)->ZZ4_QTDVOL
	    (cAliasTmp)->(DbSkip())
	End
	(cAliasTmp)->(dbCloseArea())
	(cAliasZZ4)->(dbGoTop())
	aLst[1] := "Documentos: " + cValToChar(aLst[1])
	aLst[2] := "Valor (R$): " + Transform(aLst[2],"@E 9,999,999,999.99")
	aLst[3] := "Peso (Kg): " + Transform(aLst[3],"@E 9,999,999,999.99")
	aLst[4] := "Qtde de volumes: " + cValToChar(aLst[4])
Return
      
Static Function ModelDef()
	Local oModel  	    := Nil
	Local oStructZZ4	:= FWFormModelStruct():New()
	
	oStructZZ4:AddTable(cAliasZZ4, {'ZZ4_RESERV'},"Registro de documentos")
	oStructZZ4:AddIndex(1,'01','ZZ4_RESERV','Indice 1','','',.T.)
	oStructZZ4:AddIndex(1,'02','cIntToBool(ZZ4_MARCAD)+ZZ4_NRDC','Indice 2','','',.T.)
	//Reserva:
	oStructZZ4:AddField("ID"	, "ID reserva", 	"ZZ4_RESID", "N",  10, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.T./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ4:AddField("Reserva"	, "Código da reserva", 	"ZZ4_RESERV", "C",  30, 0, {|oModel|VALRES()/*bValid*/},{||.T./*bWhen*/},/*aValues*/,.T./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ4:AddField("Tipo"		, "Tipo da reserva"	, 	"ZZ4_DSRESR", "C",  50, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ4:AddField("Navio"		, "Navio"			, 	"ZZ4_NAVIO" , "C",  50, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ4:AddField("Viagem"	, "Viagem"			, 	"ZZ4_VIAGEM", "C",  15, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	//Documento
	oStructZZ4:AddField("Ordem","Ordem"										, "ZZ4_DOCORD", "C", 01 ,0  ,{||.T.},{||.T.},Nil,.T.,/**/,.F.,.F.,.F.) //Virtual
	oStructZZ4:AddField("Tipo Documento","Tipo Documento"					, "ZZ4_TPDOC", "C",  10 ,0  ,{||VAL_TP_DOC()},{||INCLUI},Nil,.T.,/**/,.F.,.F.,.F.)
	oStructZZ4:AddField("Descrição","Descrição"	, "ZZ4_DSDOC", "C",  50 ,0  ,{||.T.},{||.T.},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ4:AddField("Procedência","Procedência"							, "ZZ4_TPPROC", "C",  3 ,0  ,{||.T.},{||WHEN_PROC() .And. INCLUI},Nil,.F.,/**/,.F.,.F.,.F.)
//	oStructZZ4:AddField("Descrição","Descrição da Procedência"				, "ZZ4_DSPROC", "C", 50 ,0  ,{||.T.},{||.T.},Nil,.F.,/**/,.F.,.F.,.F.)
	
	oStructZZ4:AddField("Beneficiário (CNPJ/CPF)","Beneficiário (CNPJ/CPF)"	, "ZZ4_CGCBEN", "C",  21 ,0  ,{||VAL_IDBEN()},{||INCLUI},Nil,.T.,/**/,.F.,.F.,.F.)
	oStructZZ4:AddField("Cód. Ben"	,"Cód. Ben"	, "ZZ4_BENID", "C",  06 ,0  ,{||.T.},{||.T.},Nil,.T.,/**/,.F.,.F.,.F.)
	oStructZZ4:AddField("Descrição","Descrição do beneficiário"				, "ZZ4_DSBEN",  "C", 50 ,0  ,{||.T.},{||.T.},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ4:AddField("CFOP","CFOP"										, "ZZ4_CFOP",   "C",  05 ,0  ,{||VAL_CFOP()},{||!WHEN_PROC()},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ4:AddField("Descrição","Descrição da CFOP"					    , "ZZ4_DSCFOP", "C", 100 ,0  ,{||.T.},{||.T.},Nil,.F.,/**/,.F.,.F.,.F.)
	oStructZZ4:AddField("Chave Acesso (NF-e)","Chave Acesso (NF-e)"		    , "ZZ4_CHAVE",  "C", 44 ,0  ,{||A806VLDCHA()},{||!WHEN_PROC()},Nil,.F.,/**/,.F.,.F.,.F.)
	
	oStructZZ4:AddField("Emissão"	, "Data de Emissão"	, "ZZ4_DTEMIS"	, "D",  08, 0, {||.T./*bValid*/},{||INCLUI/*bWhen*/},/*aValues*/,.T./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ4:AddField("Número"	, "Número"			, "ZZ4_NRDC"	, "C",  13, 0, {||.T./*bValid*/},{||INCLUI/*bWhen*/},/*aValues*/,.T./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ4:AddField("Série"		, "Série"			, "ZZ4_SRDC"	, "C",  03, 0, {||.T./*bValid*/},{||!WHEN_PROC().AND. INCLUI/*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ4:AddField("Valor (R$)", "Valor (R$)"		, "ZZ4_VLDC"	, "N",  13, 2, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.T./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	//Volumes transportados
	oStructZZ4:AddField("Embalagem"	, "Embalagem"				, "ZZ4_CDEMB" , "C",  02, 0, {||VAL_VOLUM()/*bValid*/},{||.T./*bWhen*/},/*aValues*/,.T./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ4:AddField("Descrição", "Descrição", "ZZ4_DSEMB" , "C",  88, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ4:AddField("Quantidade", "Quantidade"				, "ZZ4_QTDVOL", "N",  13, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.T./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ4:AddField("Peso (Kg)", "Peso (Kg)"				, "ZZ4_PESOKG", "N",  13, 2, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.T./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ4:AddField("NCM ID"	,"NCM ID"	, "ZZ4_NCMID", "N",  10, 0, {||.T.},{||.T./*bWhen*/},/*aValues*/,.T./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ4:AddField("NCM Predominante"	,"NCM Predominante"	, "ZZ4_NCMPRD", "C",  10, 0, {||VAL_NCM()},{||.T./*bWhen*/},/*aValues*/,.T./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ4:AddField("Descrição"	, "Descrição do NCM"		, "ZZ4_DSNCM" , "C",  100, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ4:AddField("DENTID"	, "ZZ4_DENTID"		, "ZZ4_DENTID" , "C",  30, 0, {||.T./*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,/*{||init} */,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	//Triggers
	oStructZZ4:AddTrigger('ZZ4_RESERV','ZZ4_RESID',,{||GetResInfo('ZZ4_RESID')})
	oStructZZ4:AddTrigger('ZZ4_RESERV',"ZZ4_DSRESR",,{||GetResInfo('ZZ4_DSRESR')})
	oStructZZ4:AddTrigger('ZZ4_RESERV',"ZZ4_NAVIO" ,,{||GetResInfo('ZZ4_NAVIO')})
	oStructZZ4:AddTrigger('ZZ4_RESERV',"ZZ4_VIAGEM",,{||GetResInfo('ZZ4_VIAGEM')})
	
	oStructZZ4:AddTrigger('ZZ4_TPDOC',"ZZ4_DSDOC",,{||GetTPDInfo()})
	
	oStructZZ4:AddTrigger('ZZ4_CGCBEN','ZZ4_BENID',,{||GetBenInfo('ZZ4_BENID')})
	oStructZZ4:AddTrigger('ZZ4_CGCBEN','ZZ4_DSBEN',,{||GetBenInfo('ZZ4_DSBEN')})
	
	oStructZZ4:AddTrigger('ZZ4_NCMPRD','ZZ4_DSNCM',,{||GetNCMInfo()})
	
	oStructZZ4:AddTrigger('ZZ4_CDEMB','ZZ4_DSEMB',,{||GetVOLInfo()})
	
	oStructZZ4:AddTrigger('ZZ4_CFOP','ZZ4_DSCFOP',,{||GetCfpInfo()})
	
	oModel := MPFormModel():New('PRAA806',,{|oModel|A806BPOS(oModel)})
	
	oModel:SetDescription("Registro de documentos")
	
	oModel:AddFields('PRAA806_ZZ4', Nil, oStructZZ4,,,)
	oModel:GetModel('PRAA806_ZZ4'):SetDescription("Documento")
	
	oModel:SetPrimaryKey({'ZZ4_NRDC'})
	
	oModel:InstallEvent("_A806EVENT",, _A806EVENT():New())
	
	oModel:SetActivate({|oModel|A806LOAD(oModel)})
   
	oModel:SetVldActivate({|oModel| A806VLDLD(oModel)})
Return oModel

Static Function ViewDef()
	Local oModel       := FWLoadModel('PRAA806')
	Local oStructZZ4   := FWFormViewStruct():New()
	Local oView        := Nil
	
	oStructZZ4:AddFolder('01','Geral')
	
	oStructZZ4:AddGroup("Reserva", "Reserva", '01', 2)
	oStructZZ4:AddGroup("Documento", "Documento", '01', 2)
	oStructZZ4:AddGroup("VolTransp", "Volumes transportados", '01', 2)
	
	//Reserva:
	oStructZZ4:AddField("ZZ4_RESERV", "01","Reserva"	, "Código da reserva", ,"C","@!"/*PIC*/,/*BPIC*/,'SARRES'/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/,"Reserva"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ4:AddField("ZZ4_DSRESR", "02","Tipo"	, "Tipo da reserva"	,  ,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/,"Reserva"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ4:AddField("ZZ4_NAVIO" , "03","Navio"	, "Navio"			,  ,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/,"Reserva"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ4:AddField("ZZ4_VIAGEM", "04","Viagem"	, "Viagem"			,  ,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/,"Reserva"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	//Documento
	oStructZZ4:AddField("ZZ4_TPDOC", "05","Tipo Documento","Tipo Documento"					, ,"C", "@!"/*PIC*/,/*BPIC*/,'SARATD'/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"Documento"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ4:AddField("ZZ4_DSDOC", "06","Descrição","Descrição"	, ,"C", /*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"Documento"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oStructZZ4:AddField("ZZ4_TPPROC","07","Procedência","Procedência"						, , "C","@!"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/,"Documento"/*CGROUP*/,a_PRC_DC/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	oStructZZ4:AddField("ZZ4_CGCBEN" ,"09","Beneficiário (CNPJ/CPF)","Beneficiário (CNPJ/CPF)", , "C","@R 99.999.999/9999-99",{||S_PICPES( FwFldGet("ZZ4_CGCBEN")) },'SARACL'/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"Documento"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/) 
	oStructZZ4:AddField("ZZ4_DSBEN" ,"10","Descrição","Descrição da Procedência"			, , "C", /*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"Documento"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oStructZZ4:AddField("ZZ4_CFOP"  ,"11","CFOP","CFOP"										, , "C", "9.999"/*PIC*/,/*BPIC*/,'SRCFOP'/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/,"Documento"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/) 
	oStructZZ4:AddField("ZZ4_DSCFOP","12","Descrição","Descrição da CFOP"					, , "C", /*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/,"Documento"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	oStructZZ4:AddField("ZZ4_DTEMIS","13","Emissão"	, "Data de Emissão"	, , "D",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"Documento"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ4:AddField("ZZ4_NRDC"	,"14","Número"	, "Número"			, , "C",Replicate("9",13)/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"Documento"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ4:AddField("ZZ4_SRDC"	,"15","Série"	, "Série"			, , "C","@!"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/,"Documento"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/) 
	oStructZZ4:AddField("ZZ4_VLDC"	,"16","Valor (R$)", "Valor (R$)"	, , "N","@E 9,999,999,999.99"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/,"Documento"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	
	//Volumes transportados
	oStructZZ4:AddField("ZZ4_CDEMB" ,"17","Embalagem"	, "Embalagem"				, , "C","@!"/*PIC*/,/*BPIC*/,'SARVOL'/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"VolTransp"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/) 
	oStructZZ4:AddField("ZZ4_DSEMB" ,"18","Descrição", "Descrição"	, , "C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"VolTransp"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oStructZZ4:AddField("ZZ4_QTDVOL","19","Quantidade", "Quantidade"				, , "N","9999999999"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"VolTransp"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/) 
	oStructZZ4:AddField("ZZ4_PESOKG","20","Peso (Kg)", "Peso (Kg)"					, , "N","@E 99,999,999.99"/*PIC*/,/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"VolTransp"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	oStructZZ4:AddField("ZZ4_NCMPRD","21","NCM Predominante"	,"NCM Predominante"	, , "C","9999.99.99"/*PIC*/,/*BPIC*/,'SARNCM'/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"VolTransp"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ4:AddField("ZZ4_DSNCM" ,"22","Descrição"	, "Descrição do NCM"		, , "C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,'01'/*CFOLDER*/ ,"VolTransp"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ4:AddField("ZZ4_CHAVE" ,"23","Chave Acesso (NF-e)","Chave Acesso (NF-e)"       , , "C", "99999999999999999999999999999999999999999999",/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,'01'/*CFOLDER*/,"Documento"/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "PRAA806_ZZ4" , oStructZZ4, /*cLinkID*/ )
	
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:SetOwnerView("PRAA806_ZZ4","MASTER")
//	oView:SetViewProperty("PRAA806_ZZ4","SETLAYOUT",{ ,4})
Return oView

Function A806PARAM(lMostra)
	Local lRet      := .F.
	Local afltr     := {}
	Local nX
	Default lMostra := .T.
	
	cParam := cParam02

	SetMVValue('PRAA806B', 'MV_PAR01', '')
	lRet := Pergunte('PRAA806B',lMostra,,.T.)

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
		A806PARAM()	
	ElseIf lRet
	
	    SetMVValue('PRAA806B', 'MV_PAR01', '')
	    	
		If !Empty(AllTrim(cParam02))
			If !S_ValidRes(cParam02)
				MsgInfo('A reserva informada não foi localizada.')
				A806PARAM()
			EndIf
			
			If S_ValResF(cParam02)
				MsgInfo('A reserva informada está fechada e não pode ser modificada.')
				A806PARAM()
			EndIf
			
			If S_ValResC(cParam02)
				MsgInfo('A reserva informada está cancelada e não pode ser modificada.')
				A806PARAM()
			EndIf
			
			aAdd(afltr, {" b.res_numero = '" + ALLTRIM(cParam02) + "'","Reserva: " + ALLTRIM(cParam02)})
			if cEmpPai <> SGetTerm()
				cFiltroSql := " and exists (select 1  "
		   		cFiltroSql += " from vw_portal_permissao_acesso "
		        cFiltroSql += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "'"
		        cFiltroSql += " and cli_id_acesso_info = b.cli_id) "
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

Static Function A806LOAD(oModel)
	Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	Private lLoad := .T.
	If !Empty(cParam02) .And. oModel:GetOperation() == 3
		lLoad := .T.
		oModelZZ4:SetValue('ZZ4_RESERV',cParam02)
	EndIf
	SEL_AR_PRO()
	lLoad := .F.
Return

Static Function VALRES()
	Local cQuery := ""
	Local lRet := .T.
	Local oModel    
	Local oModelZZ4 
	Local cResNum
	oModel := FwModelActive()
	If Type("lLoad") == "L" .And. lLoad
		cResNum := cParam02
	ElseIf !Empty(oModel)
		oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
		If !Empty(oModelZZ4)
			cResNum := oModelZZ4:GetValue('ZZ4_RESERV')
		EndIf
	EndIf
	If !Empty(cResNum)
		cQuery += " select vgm_numero viagem,nav_n2 navio,res_tipo_descricao restipo, res_numero numero, tab_reserva.res_id id from tab_reserva "
		cQuery += "   left join tab_viagem "
		cQuery += "   on tab_reserva.vgm_id = tab_viagem.vgm_id "
		cQuery += "   left join tab_navios on "
		cQuery += " tab_navios.nav_id = tab_viagem.vei_id "
		cQuery += " left join tab_reserva_tipo on "
		cQuery += " tab_reserva_tipo.res_tipo = tab_reserva.res_tipo "
		cQuery += " where res_numero = '" + cResNum + "'"
		if cEmpPai <> SGetTerm()
			cQuery += " and exists (select 1  "
	    	cQuery += " from vw_portal_permissao_acesso "
	       cQuery += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "' "
	       cQuery += " and cli_id_acesso_info = tab_reserva.cli_id) "
		endif
		If Empty(cAlRes)
			cAlRes := GetNextAlias()
		EndIf
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAlRes,.F.,.T.)
		If (cAlRes)->(Eof()) .Or. Empty((cAlRes)->id) 
			lRet := .F.
			(cAlRes)->(dbCloseArea())
			cAlRes := ""
		EndIf
	EndIf
Return lRet

Static Function GetResInfo(cCampo)
	Local cRet := ""
	If !Empty(cAlRes)
		Do Case
			Case cCampo == 'ZZ4_RESID'
				cRet := (cAlRes)->id
			Case cCampo == "ZZ4_DSRESR"
				cRet := (cAlRes)->restipo
			Case cCampo == "ZZ4_NAVIO"
				cRet := (cAlRes)->navio
			Case cCampo == "ZZ4_VIAGEM"
				cRet := (cAlRes)->viagem
				(cAlRes)->(dbCloseArea())
				cAlRes := ""
		EndCase
	Else
		If cCampo == 'ZZ4_RESID'
			cRet := 0
		Else
			cRet := ""
		EndIf
	EndIf
Return cRet

//Lookup de Espécies
Function A806sZVOL()
	Local aRet := {}
	Local aFields := {}
	Local cSql := ""
	Aadd(aRet, 1)
	
	cSql := "  SELECT ESP_ID, ESP_DESCRICAO NOME FROM TAB_ESPECIE "
	
	Aadd(aRet, cSql)
	Aadd(aRet, 'ORDER BY ESP_ID')
              //aFields,   cCampo           ,  cDesc             , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "ESP_ID"	, "Ncm"	, "C"  , 02  , 0        , ""      , .T.     , .T., .T., 1)
	SAddPField(@aFields , "NOME", "Descrição"	, "C"  , 88  , 0        , ""      , .T.     , .F.)

	Aadd(aRet, aFields)
	
Return aRet

//Lookup de ncm
Function A806sZNCM()
	Local aRet := {}
	Local aFields := {}
	Local cSql := ""
	Aadd(aRet, 1)
	
	cSql := " SELECT NCM_COD, NCM_DESCRICAO NCM_NOME FROM TAB_NCM"
	
	Aadd(aRet, cSql)
	Aadd(aRet, 'ORDER BY NCM_COD')
              //aFields,   cCampo           ,  cDesc             , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "NCM_COD"	, "Ncm"	, "C"  , 10  , 0        , ""      , .T.     , .T., .T., 1)
	SAddPField(@aFields , "NCM_NOME", "Descrição"	, "C"  , 100  , 0        , ""      , .T.     , .F.)

	Aadd(aRet, aFields)
	
Return aRet

//Lookup de reservas
Function A806sZRes()
	Local aRet := {}
	Local aFields := {}
	Local cSql := ""
	Aadd(aRet, 1)
		cSql := "   select convert(varchar(6),a.res_id) as res_id, "+;
		    "   a.res_numero, "+;
		    "   c.vei_id, "+;
		    "   e.nav_n2, "+;
		    "   b.vgm_numero, "+;
		    "   d.cli_id, "+;
		    "   d.cli_nome   "+;
			"	from tab_reserva a "+;
			"	  left join tab_viagem b "+;
			"	    on a.vgm_id = b.vgm_id "+;
			"	  left join tab_veiculos c "+;
			"	    on c.vei_id = b.vei_id   "+;
			"	  left join tab_clientes d "+;
			"	    on d.cli_id = a.cli_id   " +;
			"     left outer join tab_navios e "+;
           "          on e.nav_id = c.vei_id "

		cSql += "	where a.res_dt_fechamento is null and a.res_dt_cancelamento is null "
		if cEmpPai <> SGetTerm()
			cSql += " and exists (select 1  "
	   		cSql += " from vw_portal_permissao_acesso "
	       cSql += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "'"
	       cSql += " and cli_id_acesso_info = a.cli_id) "
		endif
	
	Aadd(aRet, cSql)
	Aadd(aRet, 'ORDER BY res_numero')
              //aFields,   cCampo           ,  cDesc             , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	SAddPField(@aFields , "res_id"         , 'Código'          , "C"  , 6       , 0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "res_numero"     , 'Reserva'         , "C"  , 20      , 0        , ""      , .T.     , .T., .T., 1)
	SAddPField(@aFields , "vei_id"         , 'IMO'             , "C"  , 11      , 0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "nav_n2"         , 'Navio'           , "C"  , 50      , 0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "vgm_numero"     , 'Viagem'          , "C"  , 10      , 0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "cli_id"         , 'Cód. do cliente' , "C"  , 6       , 0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "cli_nome"       , 'Cliente'         , "C"  , 30      , 0        , ""      , .T.     , .F.)

	Aadd(aRet, aFields)
	
Return aRet

Function A806sZCFOP()
   Local aRet := {}
   Local aFields := {}
   Local cSql := ''
   Local oModel    := FWModelActive()
   Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')

	cSql := "	select a.cfop_id, "+;
			 "	       a.cfop_descricao "+;
			 "	from tab_cfop a       "+;
			"	  inner join rel_cfop_doc b "+;
			"	    on b.cfop_id = a.cfop_id "


	cSql += "	where b.doc_id = '" + alltrim(oModelZZ4:getvalue('ZZ4_TPDOC'))+"'"


   Aadd(aRet, 1)
   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY a.cfop_id')

              //aFields,   cCampo         ,  cDesc          , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "cfop_id"         , 'Código'          , "C"  , 6       , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "cfop_descricao"     , 'Booking'      , "C"  , 100      , 0        , ""      , .T.     , .F.)

	Aadd(aRet, aFields)

return aRet

Static Function VAL_NCM()
	Local lRet := .T.
	Local cQuery := ""
	Local oModel := FwModelActive()
	Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	Local cNcm	:= oModelZZ4:GetValue('ZZ4_NCMPRD')
	If !Empty(SubStr(cNcm,1,4) + SubStr(cNcm,6,2) +  SubStr(cNcm,9,2))
		cQuery := " SELECT NCM_ID, NCM_COD, NCM_DESCRICAO NCM_NOME FROM TAB_NCM WHERE NCM_COD = '"+cNcm+"'"
		If Empty(cAlNcm)
			cAlNcm := GetNextAlias()
		EndIf
			
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlNcm, .F., .T.)
		If (cAlNcm)->(Eof()) .Or. Empty((cAlNcm)->NCM_ID)
			lRet := .F.
			(cAlNcm)->(dbCloseArea())
			cAlNcm := ""
		Else
			oModelZZ4:LoadValue('ZZ4_NCMID',(cAlNcm)->NCM_ID)
		EndIf
	EndIf
Return lRet

Static Function GetNCMInfo()
	Local cRet
	If !Empty(cAlNcm)
		cRet := (cAlNcm)->NCM_NOME
		(cAlNcm)->(dbCloseArea())
		cAlNcm := ""
	Else
		cRet := ""
	EndIf
Return cRet

Static Function VAL_CFOP()
	Local lRet := .T.
	Local cQuery := ""
	Local oModel := FwModelActive()
	Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	Local cCfop	:= oModelZZ4:GetValue('ZZ4_CFOP')
	If !Empty(SubStr(cCfop,1,1) + SubStr(cCfop,3))
		cQuery := "	select a.cfop_id, "+;
			 "	       a.cfop_descricao cfop_nome"+;
			 "	from tab_cfop a       "+;
			"	  inner join rel_cfop_doc b "+;
			"	    on b.cfop_id = a.cfop_id "
		cQuery += "	where b.cfop_id = '" + alltrim(cCfop)+"'"
		
		If Empty(cAlCfop)
			cAlCfop := GetNextAlias()
		EndIf
			
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlCfop, .F., .T.)
		If (cAlCfop)->(Eof()) .Or. Empty((cAlCfop)->cfop_id)
			lRet := .F.
			(cAlCfop)->(dbCloseArea())
			cAlCfop := ""
		EndIf
	EndIf
Return lRet

Static Function GetCfpInfo()
	Local cRet
	If !Empty(cAlCfop)
		cRet := (cAlCfop)->cfop_nome
		(cAlCfop)->(dbCloseArea())
		cAlCfop := ""
	Else
		cRet := ""
	EndIf
Return cRet

Static Function VAL_VOLUM()
	Local lRet := .T.
	Local cQuery := ""
	Local oModel := FwModelActive()
	Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	Local cCdVol	:= oModelZZ4:GetValue('ZZ4_CDEMB')
	If !Empty(cCdVol)
		cQuery := " SELECT ESP_ID, ESP_DESCRICAO NOME FROM TAB_ESPECIE WHERE ESP_ID = '"+cCdVol+"'"
		If Empty(cAlVol)
			cAlVol := GetNextAlias()
		EndIf
			
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlVol, .F., .T.)
		If (cAlVol)->(Eof()) .Or. Empty((cAlVol)->ESP_ID)
			lRet := .F.
			(cAlVol)->(dbCloseArea())
			cAlVol := ""
		EndIf
	EndIf
Return lRet

Static Function GetVOLInfo()
	Local cRet
	If !Empty(cAlVol)
		cRet := (cAlVol)->NOME
		(cAlVol)->(dbCloseArea())
		cAlVol := ""
	Else
		cRet := ""
	EndIf
Return cRet

Static Function VAL_TP_DOC()
	Local lRet := .T.
	Local cQuery := ""
	Local oModel := FwModelActive()
	Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	Local cDocId	:= oModelZZ4:GetValue('ZZ4_TPDOC')
	
	If !Empty(cDocId) .And. oModel:GetOperation() != 5
		cQuery := " SELECT DOC_ID,DOC_NOME,DOC_ORDEM1 FROM TAB_DOCUMENTOS WHERE DOC_ID = '"+cDocId+"' AND DOC_TIPO IN (1,2,3)"
		If Empty(cAlTpDoc)
			cAlTpDoc := GetNextAlias()
		EndIf
			
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlTpDoc, .F., .T.)
		If (cAlTpDoc)->(Eof()) .Or. Empty((cAlTpDoc)->DOC_ID)
			lRet := .F.
			(cAlTpDoc)->(dbCloseArea())
			cAlTpDoc := ""
		Else
			If UPPER(AllTrim(cDocId)) == 'NF'
				oModelZZ4:LoadValue('ZZ4_TPPROC',GETPSARA("PROC_NAC"))
			EndIf
			oModelZZ4:LoadValue('ZZ4_DOCORD',(cAlTpDoc)->DOC_ORDEM1)
		EndIf
	EndIf
Return lRet

Static Function GetTPDInfo()
	Local cRet
	If !Empty(cAlTpDoc)
		cRet := (cAlTpDoc)->DOC_NOME
		(cAlTpDoc)->(dbCloseArea())
		cAlTpDoc := ""
	Else
		cRet := ""
	EndIf
Return cRet

Static Function VAL_IDBEN()
	Local lRet := .T.
	Local cQuery := ""
	Local oModel := FwModelActive()
	Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	Local cCgcBen	:= AllTrim(oModelZZ4:GetValue('ZZ4_CGCBEN'))
	If !Empty(cCgcBen)
		cQuery := "   		select convert(varchar(6),a.cli_id) as cli_id,convert(varchar(32),a.cli_nome) as cli_nome,convert(varchar(15),a.cli_cgc) as cli_cgc "
		cQuery += "			from tab_clientes a                    "
		cQuery += "			  inner join rel_tipo_cliente b  "
		cQuery += "			    on a.cli_id = b.cli_id  "
		cQuery += "			where b.tcli_id = 1 and a.cli_cgc ='" + cCgcBen + "'"
		If Empty(cAlBen)
			cAlBen := GetNextAlias()
		EndIf
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAlBen,.F.,.T.)
		If (cAlBen)->(Eof()) .Or. Empty((cAlBen)->cli_id) 
			lRet := .F.
			(cAlBen)->(dbCloseArea())
			cAlBen := ""	
		EndIf
	EndIf
Return lRet

Static Function GetBenInfo(cCampo)
	Local cRet
	If !Empty(cAlBen)
		Do Case
			Case cCampo == 'ZZ4_BENID'
				cRet := (cAlBen)->cli_id
			Case cCampo == "ZZ4_DSBEN"
				cRet := (cAlBen)->cli_nome
				(cAlBen)->(dbCloseArea())
				cAlBen := ""
		EndCase
	Else
		cRet := ""
	EndIf
Return cRet

Static Function WHEN_PROC()
	Local lRet := .T.
	Local oModel := FwModelActive()
	Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	If UPPER(AllTrim(oModelZZ4:GetValue('ZZ4_TPDOC'))) == 'NF'
		lRet := .F.
	EndIf 
Return lRet

Static Function A806BPOS(oModel)
	Local lRet := .T.
	Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	If oModel:GetOperation() != 5
		If UPPER(AllTrim(oModelZZ4:GetValue('ZZ4_TPDOC'))) == 'NF' 
			If Empty(oModelZZ4:GetValue('ZZ4_CFOP'))
				oModel:SetErrorMessage('PRAA806',,,,'3000','O CFOP da nota fiscal deve estar preenchido.' ,'', nil, nil)
				lRet := .F.
			EndIf
			
			If lRet .And. Len(AllTrim(oModelZZ4:GetValue('ZZ4_SRDC'))) <> 3
				oModel:SetErrorMessage('PRAA806',,,,'3000','A série da nota fiscal deve possuir 3 dígitos.' ,'', nil, nil)
				lRet := .F.
			EndIf
		Else
			oModelZZ4:LoadValue('ZZ4_CFOP','')
			oModelZZ4:LoadValue('ZZ4_SRDC','')
			If Empty(oModelZZ4:GetValue('ZZ4_TPPROC'))
				oModel:SetErrorMessage('PRAA806',,,,'3000','A procedência do documento deve estar preenchido.' ,'', nil, nil)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
Return lRet

Static Function A806BCOMMIT(oModel)
	Local aResult := {}
	Local nOp := oModel:GetOperation()
	Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	Local cErro
	Local cDentId := FWFldGet('ZZ4_DENTID')// Documento
	Local cDocOrd := FwFldGet("ZZ4_DOCORD")
	Local cCfop := FwFldGet('ZZ4_CFOP')
	Default cAliasZZ4 := nil
	
	If Empty(SubStr(cCfop,1,1) + SubStr(cCfop,3))
		cCfop := "" 
	EndIf
	If Empty(cDentId)
		cDentId := ""
		
		// ano
		cDentId += cValToChar(Year(FwFldGet("ZZ4_DTEMIS"))) 
		
		// tipo
		If Empty(cDocOrd)
			VAL_TP_DOC()
			cDocOrd := FWFldGet('ZZ4_DOCORD')
		EndIf
		cDentId += cDocOrd 
		
		//Série
		If UPPER(AllTrim(oModelZZ4:GetValue('ZZ4_TPDOC'))) == 'NF' 
		  cDentId += AllTrim(FWFldGet('ZZ4_SRDC')) 
		EndIf
		
		//Número
		If UPPER(AllTrim(oModelZZ4:GetValue('ZZ4_TPDOC'))) == 'NF'
		  cDentId += StrZero(VAL(FWFldGet('ZZ4_NRDC')),13)
		else
         cDentId += StrZero(VAL(FWFldGet('ZZ4_NRDC')),16)		
		EndIf 
		
		// Procedência
		cDentId += FWFldGet('ZZ4_TPPROC') 
		
		// Id Beneficiario
		If UPPER(AllTrim(oModelZZ4:GetValue('ZZ4_TPDOC'))) == 'NF'
		  cDentId += FWFldGet('ZZ4_BENID') 
		else
		  cDentId += '999999'
		EndIf
	EndIf
	
	if ValidDocJaCadastrado(cDentId, oModel)
	     
		aResult := TCSPExec("proc_diu_tmp_doc_entrada_ag",   nOp,; // @w_operacao   int
								cDentId,; // @w_dent_id        char    30
								'',; // @w_com_id char    6
								FwFldGet("ZZ4_TPPROC"),; // @w_proc_id   char    3
								'',; // @w_fem_id        char    7
								0,; // @w_veiculos      int
								0,; // @w_ag_id int
								FWFldGet('ZZ4_BENID'),; // @w_ben_id char    6
								0,; // @w_rec_id        int
								SDBDate(FwFldGet('ZZ4_DTEMIS'),"00:00:00.000"),; // @w_dent_dt_emissao     varchar 25
								If(AllTrim(UPPER(FwFldGet('ZZ4_TPDOC'))) == 'NF',1,0),; // @w_dent_qtd_conhec       int
								FwFldGet('ZZ4_QTDVOL'),; // @w_dent_qtd_vol_tot    numeric
								FwFldGet('ZZ4_PESOKG'),; // @w_dent_peso_bruto_tot numeric
								0,; // @w_dent_peso_liquido   numeric
								0,; // @w_dent_frete money
								0,; // @w_dent_seguro        money
								0,; // @w_dent_fob   money
								FwFldGet('ZZ4_VLDC'),; // @w_dent_cif_tot       money
								'',; // @w_dent_obs       varchar 255
								'',; // @w_dent_dt_perfuracao    datetime
								'',; // @w_dent_dt_atracacao     datetime
								'',; // @w_cesv_id  char    12
								'',; // @w_dent_parcial        char    1
								'',; // @w_dent_srodas char    1
								'',; // @w_dent_rfeiras        char    1
								'',; // @w_dent_consolidado    char    1
								'',; // @w_dent_ind    char    1
								0,; // @w_tipo_navegacao        int
								cCfop,; // @w_cfop_id char    5
								FwFldGet('ZZ4_RESID'),; // @w_res_id        int
								FwFldGet('ZZ4_NCMID'),; // @w_ncm_id        int
								FwFldGet('ZZ4_CDEMB'),; // @w_esp_id     char    2
								FwFldGet('ZZ4_CHAVE'); // @w_esp_id     char    2
								)
		
		IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
			cErro := AllTrim(TCSQLError())
			oModel:SetErrorMessage('PRAA806',,,,,cErro )
			Return .F.
		elseIF !empty(aResult) .And. AllTrim(aResult[1]) <> ''
			cErro := "Ocorreu um erro no processo da gravação do documento"+Chr(13)+AllTrim(aResult[1])
			oModel:SetErrorMessage('PRAA806',,,,,cErro )
			Return .F.
		End IF
	
		If Empty((cAliasZZ4)->ZZ4_DENTID)
			RecLock(cAliasZZ4,.F.)
			(cAliasZZ4)->ZZ4_DENTID := cDentId
			(cAliasZZ4)->(MsUnLock())
		EndIf
		
		A806Atualizar()
	else
		return .F.
	endif
Return .T.

Function A806Atualizar()
	A806PARAM(.F.)
Return

Function A806MarkAll(cAl,cCpo,pnl,brw)
	Local aArea := (cAl)->(GetArea())

	Local lDesk := GetRemoteType() != 5
	lMarcado := !lMarcado
	If lDesk	
		pnl:SetUpdatesEnabled( .F.)
	EndIf
	(cAl)->(dbGoTop())
	
	While !(cAl)->(Eof())
		RecLock(cAl,.F.)
		(cAl)->(FieldPut(FieldPos(cCpo), If(lMarcado,1,0)))
		(cAl)->(MsUnLock())
		(cAl)->(dbSkip())
	EndDo
	
	
	RestArea(aArea)
	aSize(aArea,0)
	If lDesk
		brw:UpdateBrowse()
		brw:Refresh()
	
		pnl:SetUpdatesEnabled( .T.)
	EndIf
	brw:GoTo((cAl)->(RecNo()),.T.)

Return

Function A806AGDS()
	Local oFWMVCWin := FWMVCWindow():New()
	Local oModel   
	Local oModelDOC
	Local oModelCNT
	Local oModelTMP
	Local aSz		:= FWGetDialogSize( oMainWnd )
	Local aAreaZZ4 := nil
	Local lAdd := .T.
	Local cQuery := ""
	Local cAliasT
	Local cPar := ""
	Local lConfirmou := .F.
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
	Default cAliasZZ4 := nil

	aAreaZZ4 := (cAliasZZ4)->(getArea())
	
	(cAliasZZ4)->(DbSetOrder(2))
	If !(cAliasZZ4)->(dbSeek(cValToChar(1)))
		MsgAlert('Selecione ao menos um documento antes de agendar a descarga solta.')
		RestArea(aAreaZZ4)
		Return
	EndIf
	
	While !(cAliasZZ4)->(Eof())
		cQuery := "Select rrc_id from tab_reserva_rateio_cnt where dent_id = '" + (cAliasZZ4)->ZZ4_DENTID + "'"
		cAliasT := GetNextAlias()
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAliasT,.F.,.T.)
		If !Empty((cAliasT)->rrc_id)
			MsgAlert('Não é possível agendar descarga solta para documentos associados a containers.')
			(cAliasT)->(dbcloseArea())
			RestArea(aAreaZZ4)
			Return
		EndIf
		If (cAliasZZ4)->ZZ4_QTAGEN > 0 .And. !lConfirmou 
			lConfirmou := MsgYesNo('O documento ' + (cAliasZZ4)->ZZ4_NRDC + ' já possui ' + cValTochar((cAliasZZ4)->ZZ4_QTAGEN) + ' agendamento(s).' + CRLF + 'Deseja continuar?')
			If !lConfirmou
				Return
			EndIf
		EndIf
		
		(cAliasT)->(dbcloseArea())
		(cAliasZZ4)->(dbSkip())
	EndDo
	(cAliasZZ4)->(dbSeek(cValToChar(1)))
	
	If !Pergunte("PRAA806A")
		RestArea(aAreaZZ4)
		Return
	EndIf
	
	A802CARPAR()
	
	A802CRI_TABTMP()
	
	oModel   := FWLoadModel("PRAA802")
	oModelDOC:= oModel:GetModel("PRAA802DOC")
	oModelCNT:= oModel:GetModel("PRAA802CNT")
	oModelTMP:= oModel:GetModel("PRAA802")
	
	oModel:SetOperation(3)
	oModel:Activate()
	
	oModelTMP:SetValue('TMP_OPE_ID','2')
	If cTipomodal == "V"
		cPar := GetSParam("SUB_OPERACAO_DESCARGA_SOLTA_RODOVIARIA","","",.T.)
	EndIf
	If cTipomodal == "F"
		cPar := GetSParam("SUB_OPERACAO_DESCARGA_SOLTA_FERROVIARIA","","",.T.)
	EndIf
	If Empty(cPar)
	  Return .F.  
	EndIf
	If !Empty(cPar)
		oModelTMP:SetValue('TMP_SUB_ID',SubStr(cValToChar(cPar),1,10))
	EndIf
	oModelTMP:SetValue('TMP_CLI_CG',SubStr((cAliasZZ4)->ZZ4_CGCBEN,1,14))
	oModelDOC:SetNoInsertLine(.F.)
	oModelDOC:SetNoDeleteLine(.F.)
	oModelDOC:SetNoUpdateLine(.F.)
	While !(cAliasZZ4)->(Eof()) .And. lAdd
	
	//	oModelDOC:SetValue('DOC_PRG_ID',)
	//	oModelDOC:SetValue('DOC_DP_ID' ,)
		
		oModelDOC:SetValue('DOC_RES_NU',(cAliasZZ4)->ZZ4_RESERV)
		oModelDOC:SetValue('DOC_TPO_ES','E')
		oModelDOC:SetValue('DOC_TPO_DC',(cAliasZZ4)->ZZ4_TPDOC)
		oModelDOC:SetValue('DOC_ANO_DC',cValtochar(Year((cAliasZZ4)->ZZ4_DTEMIS)))
		oModelDOC:SetValue('DOC_NUM_DC',(cAliasZZ4)->ZZ4_NRDC)
		oModelDOC:LoadValue('DOC_SER_DC',(cAliasZZ4)->ZZ4_SRDC)
		oModelDOC:LoadValue('DOC_PRC_DC',(cAliasZZ4)->ZZ4_TPPROC)
		oModelDOC:LoadValue('DOC_CFOP'  ,(cAliasZZ4)->ZZ4_CFOP)
		oModelDOC:LoadValue('DOC_CFOP_D',SubStr((cAliasZZ4)->ZZ4_DSCFOP,1,100))
		oModelDOC:LoadValue('DOC_BEN_ID',(cAliasZZ4)->ZZ4_BENID)
		oModelDOC:LoadValue('DOC_BEN_CG',(cAliasZZ4)->ZZ4_BENCGC)
		oModelDOC:LoadValue('DOC_BEN'   ,(cAliasZZ4)->ZZ4_DSBEN)
		oModelDOC:SetValue('DOC_RES_ID',cValToChar((cAliasZZ4)->ZZ4_RESID))
		oModelDOC:SetValue('DOC_DOC_ID',(cAliasZZ4)->ZZ4_DENTID)

		If !oModelDOC:VldLineData()
			If !MsgYesNo("O seguinte erro ocorreu ao tentar inserir o documento " + (cAliasZZ4)->ZZ4_NRDC + " : " + oModel:GetErrorMessage()[6] + CRLF + "Prosseguir relacionando os documentos?")
				lAdd := .F.
			EndIf
		EndIf
		If lAdd
			oModelTMP:SetValue('TMP_PESO',oModelTMP:GetValue('TMP_PESO') + (cAliasZZ4)->ZZ4_PESOKG)
			(cAliasZZ4)->(dbSkip())
			If !(cAliasZZ4)->(Eof())
				oModelDOC:AddLine(.T.)
			EndIf
		EndIf
	EndDo

    If ExistTemplate("PRAAXML")
        (cAliasZZ4)->(dbSeek(cValToChar(1)))
        oModelTMP = ExecTemplate("PRAAXML",.F.,.F.,{oModelTMP,(cAliasZZ4)})
    Endif

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
	RestArea(aAreaZZ4)
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

Function MontaSpText(cSp)
	Local cTxt := ""
	Local cQuery := "select IS_RESULT RESULT,PARAMETER_MODE PARAMETRO, PARAMETER_NAME NOME, DATA_TYPE TIPO, CHARACTER_MAXIMUM_LENGTH T_CHAR, NUMERIC_PRECISION - NUMERIC_SCALE  PREC_ESQ, NUMERIC_SCALE PREC_DIR from information_schema.parameters where specific_name='" + cSp + "'"
	Local cAlSp := GetNextAlias()
	
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAlSp,.F.,.T.) 
	(cAlSp)->(dbGoTop())
	While !(cAlSp)->(Eof())
		If alltrim((cAlSp)->PARAMETRO) == 'IN'
			If !Empty(cTxt)
				cTxt += CRLF 
			EndIf
			cTxt += "						"
			do case
				case 'INT' $ UPPER(ALLTRIM((cAlSp)->TIPO))
					cTxt += "0,; // " + AllTrim((cAlSp)->NOME) + "	" + AllTrim((cAlSp)->TIPO)
				case UPPER(ALLTRIM((cAlSp)->TIPO)) $ 'FLOAT'
					cTxt += Replicate("9",(cAlSp)->PREC_ESQ) + "." + Replicate("9",(cAlSp)->PREC_DIR) + ",; // " + AllTrim((cAlSp)->NOME) + "	" + AllTrim((cAlSp)->TIPO)
				case (UPPER(ALLTRIM((cAlSp)->TIPO)) == 'VARCHAR' .And. (cAlSp)->T_CHAR == 19)
					cTxt += "'" + SDBDate(DATE(),TIME()) + "',; // " + AllTrim((cAlSp)->NOME) + "	" + AllTrim((cAlSp)->TIPO)
				case 'CHAR' $ UPPER(ALLTRIM((cAlSp)->TIPO))
					cTxt += "'" + Replicate("A",If((cAlSp)->T_CHAR>30,30,(cAlSp)->T_CHAR)) + "',; // " + AllTrim((cAlSp)->NOME) + "	" + AllTrim((cAlSp)->TIPO) + "	" + cValToChar((cAlSp)->T_CHAR) 
				otherwise
					cTxt += ",; // " + AllTrim((cAlSp)->NOME) + "	" + AllTrim((cAlSp)->TIPO) + " CHARACTER_MAXIMUM_LENGTH " + AllTrim(cValToChar((cAlSp)->T_CHAR)) + " PREC_ESQ "  + AllTrim(cValToChar((cAlSp)->PREC_ESQ)) + " PREC_DIR " + AllTrim(cValToChar((cAlSp)->PREC_DIR))
			endcase
		EndIf
		(cAlSp)->(dbSkip())
	EndDo
	
	If !Empty(cTxt) 
		cTxt := ' aResult := TCSPExec("' + cSp + '",' + cTxt + CRLF +  "					)"
	Else
		cTxt := ' aResult := TCSPExec("' + cSp + '")'
	EndIf
	(cAlSp)->(dbCloseArea())
Return cTxt

Function montadebug()
	Local cTTa
	Local cTTb
	Local cSp := "proc_diu_viagem_ferroviaria"
	Local cTxt := ""
	Local cQuery := "select IS_RESULT RESULT,PARAMETER_MODE PARAMETRO, PARAMETER_NAME NOME, DATA_TYPE TIPO, CHARACTER_MAXIMUM_LENGTH T_CHAR, NUMERIC_PRECISION - NUMERIC_SCALE  PREC_ESQ, NUMERIC_SCALE PREC_DIR from information_schema.parameters where specific_name='" + cSp + "'"
	Local cAlSp := GetNextAlias()
	
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAlSp,.F.,.T.) 
		(cAlSp)->(dbGoTop())
	While !(cAlSp)->(Eof())
		cTxt += "DECLARE " + '@_' + alltrim(substr((cAlSp)->NOME,2)) 
	If !Empty((calsp)->t_char)
		ctxt += ' ' + (calsp)->tipo + '(' + cValtochar((calsp)->t_char) + ')'
	Else
		cTxt += ' ' +  (calsp)->tipo
	EndIf 
		ctxt += CRLF
	(cAlSp)->(DBSKIP())
	ENDDO
	cTxt += CRLF
		(cAlSp)->(dbGoTop())
	While !(cAlSp)->(Eof())
		cTxt += "SELECT " + '@_' + alltrim(substr((cAlSp)->NOME,2)) + ' = ' + alltrim((cAlSp)->NOME) + CRLF
	(cAlSp)->(DBSKIP())
	ENDDO
	cTTa := cSp + 'A'
	cTTb := cSp + 'B'
	cTxt += CRLF
	cTxt += 'SELECT '
	(cAlSp)->(dbGoTop())
	While !(cAlSp)->(Eof())
		cTxt +=  alltrim(substr((cAlSp)->NOME,2))
		(cAlSp)->(DBSKIP())
		if !(cAlSp)->(Eof())
			cTxt += ","
		ENDIF
		cTxt += CRLF
	ENDDO
	cTxt += " INTO " + cTTa + " FROM ( " + CRLF + ' SELECT '
	(cAlSp)->(dbGoTop())
	While !(cAlSp)->(Eof())
		cTxt +=  '@_' + alltrim(substr((cAlSp)->NOME,2)) + ' ' + alltrim(substr((cAlSp)->NOME,2))
		(cAlSp)->(DBSKIP())
		if !(cAlSp)->(Eof())
			cTxt += ","
		ENDIF
		cTxt += CRLF
	ENDDO
	cTxt += ' ) ' + cTTb
	_01SHOWERR({'',ctxt,ctxt})
Return

Function MontaSpCreate(cQuery,cTabela)
	Local cTxt := ""
	Local cAlSp := GetNextAlias()
	Local aStr
	
	Local aCamposSql := {}
	Local nX
	Local cType
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAlSp,.F.,.T.)
	aStr := (cAlSp)->(dbStruct())
	For nX := 1 to Len(aStr)
		cType := ""
		aStr[nX][1] := lower(aStr[nX][1])
		If aStr[nX][2] == "C"
			cType := "varchar(" + cValToChar(aStr[nX][3]) + ")"
		ElseIf aStr[nX][2] == "N"
			cType := "int"
		EndIf
		cType := "	@w_" + aStr[nX][1]  + "	" + cType + " = null,"
		aAdd(aCamposSql,{cType,aStr[nX][1]})
	Next nX
	cTxt := "( @w_operacao             int, " + CRLF
	For nX := 1 to Len(aCamposSql)
		cTxt += aCamposSql[nX][1] + CRLF
	Next nX
	cTxt += ")" + CRLF
	cTxt += "	AS" + CRLF         
	cTxt += "	BEGIN" + CRLF + CRLF
	
	cTxt += "	declare @w_existe       int" + CRLF + CRLF
	
	cTxt += "	BEGIN TRAN tran_" + cTabela + CRLF  + CRLF
	
	cTxt += "	if @w_operacao = 5 "                                       
	cTxt += "	begin " + CRLF 
	cTxt += "		delete" + CRLF 
	cTxt += "		from " + cTabela + CRLF                                              
	cTxt += "		where " + aCamposSql[1][2] + " = @w_" + aCamposSql[1][2] + CRLF                               
	cTxt += "	end" + CRLF + CRLF
	
	cTxt += "	select @w_existe = count(*)" + CRLF
	cTxt += "	                   from " + cTabela + CRLF
	cTxt += "	                   where " + aCamposSql[1][2] + " = @w_" + aCamposSql[1][2] + CRLF  + CRLF
	cTxt += "	if @w_operacao = 3 and  @w_existe > 0"  + CRLF
	cTxt += "	begin "  + CRLF
	cTxt += "		select @w_operacao = 4 "  + CRLF
	cTxt += "	end"  + CRLF + CRLF
	cTxt += "	if @w_operacao = 3" + CRLF                  
	cTxt += "	begin" + CRLF
	cTxt += "		select @w_" + aCamposSql[1][2] + " = coalesce(MAX(" + aCamposSql[1][2] + "),0)+1 from " + cTabela + CRLF+ CRLF
	cTxt += "		insert " + cTabela + " ( "
	For nX := 1 to Len(aCamposSql)
		If nX == 1
			cTxt += aCamposSql[nX][2] + "," + CRLF
		Else
			cTxt += "					" + aCamposSql[nX][2] + "," + CRLF
		EndIf
//		cTxt += "					" + aCamposSql[nX][2] + " = @w_" + aCamposSql[nX][2] + "," + CRLF
	Next nX
	cTxt += "		)" + CRLF
	cTxt += "		values ( "
	For nX := 1 to Len(aCamposSql)
		If nX == 1
			cTxt += "@w_" + aCamposSql[nX][2] + "," + CRLF
		Else
			cTxt += "					@w_" + aCamposSql[nX][2] + "," + CRLF
		EndIf
		
//		cTxt += "					" + aCamposSql[nX][2] + " = @w_" + aCamposSql[nX][2] + "," + CRLF
	Next nX
	cTxt += "		)" + CRLF + CRLF
	cTxt += "	end" + CRLF + CRLF
	
	
	cTxt += "	if @w_operacao = 4 " + CRLF
	cTxt += "	begin" + CRLF
	cTxt += "		update	" + cTabela + CRLF
	For nX := 2 to Len(aCamposSql)
		If nX == 2
			cTxt += "		set	" + aCamposSql[nX][2] + "	=	@w_" + aCamposSql[nX][2] + "," + CRLF
		Else
			cTxt += "		" + aCamposSql[nX][2] + "	=	@w_" + aCamposSql[nX][2] + "," + CRLF 
		EndIf
	Next nX
	
	cTxt += "		where	" + aCamposSql[1][2] + "	=	@w_" + aCamposSql[1][2] + CRLF + CRLF
	
	cTxt += "	end" + CRLF
	
	cTxt +="	if @@error <> 0 " + CRLF    
	cTxt +="		begin" + CRLF    
	cTxt +="			raiserror(' Nao foi possivel atualizar o Documento de Entrada Temporario',16,0)  " + CRLF
	cTxt +="			ROLLBACK TRAN tran_" + cTabela + CRLF    
	cTxt +="			return 1    " + CRLF
	cTxt +="		end" + CRLF
	cTxt +="		COMMIT TRAN tran_" + cTabela + CRLF    
	cTxt +="		return 0    " + CRLF
	cTxt +="	end" + CRLF
	cTxt +="	go" + CRLF
	
	
	(cAlSp)->(dbCloseArea())
//	CONOUT(CTXT)
Return cTxt

Function GetZZ4Struct()
Return GetStruct()

Function S_PICPES(CTIPO,lComChar)
	Default lComChar := .T.
	If Len(AllTrim(StrTran(StrTran(StrTran(cTipo,".",""),"-",""),"/",""))) <= 11 .And. !Empty(cTipo)
		Return "@R 999.999.999-999999" + IIf(lComChar,"%C","")
	Else
		Return "@R 99.999.999/9999-99" + IIf(lComChar,"%C","")
	EndIf
Return cPic

Function S_ValidRes(cResNum, cResId)

Local cQuery := ""
Local cFiltroSql := ""
Local cAliasQry := GetNextAlias()
Local lRet

	If Empty(cResId)
		cFiltroSql += " b.res_numero = '" + ALLTRIM(cResNum) + "'"
	Else
		cFiltroSql += " b.res_id = " + ALLTRIM(cValToChar(cResId)) + "'"
	EndIf
	
	if cEmpPai <> SGetTerm()
		cFiltroSql += " and exists (select 1  "
   		cFiltroSql += " from vw_portal_permissao_acesso "
       cFiltroSql += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "' "
       cFiltroSql += " and cli_id_acesso_info = b.cli_id) "
	endif
	cQuery := " Select b.res_id from tab_reserva b where " +  cFiltroSql
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	If (cAliasQry)->(Eof()) .Or. Empty((cAliasQry)->res_id)
		lRet := .F.
	Else
		lRet := .T.
	EndIf
	(cAliasQry)->(dbCloseArea())
Return lRet

function A806VALEXEC( cAct, cStr, nType,cDsc)
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

Function A806KILL() 
	If lKill
		oDialog806:End()
	EndIf
Return

Function A806VLDLD(oModel)
    Default cAliasZZ4 := nil
	If oModel:GetOperation() == 4 .Or. oModel:GetOperation() == 5		
		If (cAliasZZ4)->ZZ4_ISREPO == "Sim"
			oModel:SetErrorMessage('PRAA806',,,,'3000','Não é possível alterar ou excluir um documento registrado por meio do upload de documentos. A alteração deverá ser realizada na tela de "Pré-Cadastro" do módulo Portaria ou "Documento de Entrada" do módulo de Expedição.' ,'', nil, nil)
			Return .F.
		Else
		  	If S_ValRelac((cAliasZZ4)->ZZ4_DENTID) 
				oModel:SetErrorMessage('PRAA806',,,,'3000','O registro não poderá ser alterado pois existe um ou mais contêineres associados a este documento.' ,'', nil, nil)
				Return .F.
			EndIf
		EndIf		
	EndIf
	
Return .T.

Function S_ValResF(cResNum, cResId)
Local cQuery := ""
Local cFiltroSql := ""
Local cAliasQry := GetNextAlias()
Local lRet

	If Empty(cResId)
		cFiltroSql += " b.res_numero = '" + ALLTRIM(cResNum) + "'"
	Else
		cFiltroSql += " b.res_id = " + ALLTRIM(cValToChar(cResId)) + "'"
	EndIf
	
	cQuery := " Select b.res_id from tab_reserva b where b.res_dt_fechamento is not null and " +  cFiltroSql
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	If (cAliasQry)->(Eof()) .Or. Empty((cAliasQry)->res_id)
		lRet := .F.
	Else
		lRet := .T.
	EndIf
	
	(cAliasQry)->(dbCloseArea())
Return lRet

Function S_ValResC(cResNum, cResId)
Local cQuery := ""
Local cFiltroSql := ""
Local cAliasQry := GetNextAlias()
Local lRet

	If Empty(cResId)
		cFiltroSql += " b.res_numero = '" + ALLTRIM(cResNum) + "'"
	Else
		cFiltroSql += " b.res_id = " + ALLTRIM(cValToChar(cResId)) + "'"
	EndIf
	
	cQuery := " Select b.res_id from tab_reserva b where b.res_dt_cancelamento is not null and " +  cFiltroSql
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	If (cAliasQry)->(Eof()) .Or. Empty((cAliasQry)->res_id)
		lRet := .F.
	Else
		lRet := .T.
	EndIf
	
	(cAliasQry)->(dbCloseArea())
Return lRet

Function S_ValRelac(cDentId)
Local cQuery := ""
Local cAliasQry := GetNextAlias()
Local lRet

	cQuery := " SELECT dent_id FROM dbo.tab_reserva_rateio_cnt where dent_id = '" + ALLTRIM(cDentId) + "'"
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	If !(cAliasQry)->(Eof()) .Or. !Empty((cAliasQry)->dent_id)
		lRet := .T.
	Else
		lRet := .F.
	EndIf
	
	(cAliasQry)->(dbCloseArea())
Return lRet

function ValidDocJaCadastrado(aDentId, oModel)
	local cQueryTmp := ""
	local cQueryDoc := ""
	local cAliasQryTmp := GetNextAlias()
	local cAliasQryDoc := GetNextAlias()
   
    if oModel:GetOperation() == 3 // Incluir
		cQueryTmp := "select dent_id from tab_tmp_doc_entrada where dent_id = '" + aDentId + "' "
		DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQueryTmp),cAliasQryTmp,.F.,.T.)
	
		if !(cAliasQryTmp)->(Eof()) .Or. !Empty((cAliasQryTmp)->dent_id)
			cErro := "Já existe um documento cadastrado com o mesmo número."
			oModel:SetErrorMessage('PRAA806',,,,,cErro )
			Return .F.	
		else
			cQueryDoc	 := "select dent_id from tab_doc_entrada doc where dent_id = '" + aDentId +"'" 
			DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQueryDoc),cAliasQryDoc,.F.,.T.)
			if !(cAliasQryDoc)->(Eof()) .Or. !Empty((cAliasQryDoc)->dent_id)
				cErro := "Já existe um documento cadastrado com o mesmo número."
				oModel:SetErrorMessage('PRAA806',,,,,cErro )
				Return .F.
			endif
			(cAliasQryDoc)->(dbCloseArea())
		endif
		
		(cAliasQryTmp)->(dbCloseArea())
	endif	

Return .T.

/*/{Protheus.doc} A806VLDCHA
//TODO Descrição auto-gerada.
@author mohamed
@since 20/06/2018
@version undefined
@param cNFeChave, characters, descricao
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Function A806VLDCHA()
      Local lRet     := .T.
	  Local oModel := FwModelActive()
	  Local oModelZZ4 := oModel:GetModel('PRAA806_ZZ4')
	  Local cNFeChave := AllTrim(oModelZZ4:GetValue('ZZ4_CHAVE'))
	  Local cDentID   := AllTrim(oModelZZ4:GetValue('ZZ4_DENTID'))
	  Local cNF1      := ''
	 
	  Local cQuery := ""
	  Local cAliasQry := GetNextAlias()
	  Local nTamChave := Len(cNFeChave)
	
	  cQuery := " select tde_chave_nfe from tab_tmp_doc_entrada_comp  "  
      cQuery += "   where tde_chave_nfe = '" + cNFeChave + "'"
      cQuery += "   and dent_id <> '" + cDentID + "'"
	  DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
	
	  If !(Empty((cAliasQry)->tde_chave_nfe))
	     cNF1 := (cAliasQry)->tde_chave_nfe
		 lRet := .F.
	  EndIf
	 (cAliasQry)->(dbCloseArea()) 
	
	 If Empty(cNF1)
	 	  cQuery := " select dec_chave_nfe from tab_doc_entrada_complemento  "
	      cQuery += "   where dec_chave_nfe = '" + cNFeChave + "'"
	      cQuery += "   and dent_id <> '" + cDentID + "'"
		  DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)
		
		  If !(Empty((cAliasQry)->dec_chave_nfe))
			 lRet := .F.
		  EndIf
		 (cAliasQry)->(dbCloseArea()) 
	 EndIf
     
     If !Empty(cNFeChave) .And. lRet
	     If (nTamChave < 44)
	         //cMsg := 'A quantidade de digitos digitados no campo "Chave NFe" não deve ser inferior a 44! '
	         lRet     := .F.
	     EndIf
     EndIf
     
     //se a chave informada tiver correto então valida o digito verificador
     If lRet 
        If !(Trim(substring(cNFeChave,nTamChave, 1)) = Trim(cValToChar(calculaDV(substring(cNFeChave,1,43)))))
        	lRet := .F. 	
        EndIf	
     EndIf
     
Return lRet


/*/{Protheus.doc} calculaDV
//TODO Descrição auto-gerada.
Função para calcular o digito verificador da chave de NF-e
@author Mohamed S B Djalo
@since 12/04/2019
@version Release 12.1.25
parametersSection chave43
@return return, digito_verificador
@example
(examples)
@see (links_or_references)
/*/
Static Function calculaDV(chave43)
	  Local indice := 0
	  Local multiplicador       := 2
	  Local soma                := 0
	  Local resto 
	  Local digito_verificador
	  
	  For indice = Len(chave43) To 1 Step -1
	      
	     soma := soma + (val(substring(chave43, indice, 1)) * multiplicador)
	     multiplicador := multiplicador + 1
	     If (multiplicador > 9) 
	     	 multiplicador := 2
	     EndIf
		 
	  Next indice
	 
	  resto := soma % 11
	  
	  digito_verificador := 11 - resto
	  
	  If (digito_verificador >= 10) 
	     digito_verificador := 0
	  EndIf 
  
Return digito_verificador
