#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'DBINFO.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"

#define INFO_ZOOM_TIPO_EXECUCAO_SQL   1
#define INFO_ZOOM_TIPO_EXECUCAO_ARRAY 2
#define INFO_ZOOM_OBJETO 2

Static lRetPAR := .F.

//---------------------------------
/*{Protheus.doc}
	Agendamento ferroviário
@param
@author Siegklenes.beulke
@version P11
@since 25/06/2014
*/
//---------------------------------
Function PRAA804()
	Local aSelEmp
	Local aCampos
	Local oBrowse
	Local aSeek 			:= {}
	Local aFieFilter 		:= {}
	Local oDlg
	Local aCoors 			:= FWGetDialogSize(oMainWnd)
	Private cEmpPai
	Private cVarEmp
	Private cDescEmp
	Private aCamposZZ1 	:= {}
	Private cAliasZZ1  	:= GetNextAlias()
	Private cRetLkSara 	:= ''
	Private cUsuario 		:= RET_USER()
	Private cFiltroSql 	:= ''
	Private userInf := {}
	Private lKill := .F.

    if cUsuario == ""
        MsgStop("Este usuário não está cadastrado no sistema SARA"+Chr(13)+"Entre em contato com o administrador do sistema")
        Return .F.
    EndIF
   
	userInf := A804VACES()
	   
	if sempty(userInf)
		alert('Usuário sem permissão de acesso!')
	   	return .F.
	endif
	
	aSelEmp := A804SELEMP()
	
	If aSelEmp <> Nil
		If !aSelEmp[4] .Or. Empty(aSelEmp[1])
			Return
		EndIf
	ElseIf aSelEmp == Nil 
	    Return
	EndIf
	
	cEmpPai	:= aSelEmp[1]
	cVarEmp	:= aSelEmp[2]
	cDescEmp	:= aSelEmp[3]
	
	If Empty(cEmpPai)
	    return .F.
	EndIf
	
	lRetPAR := A804Param(.F.)
	
	If !(lRetPAR)
	     Return .F.    
	EndIf
	
	CarregaPar()
	CarregaDados(.T.)
	aCampos := CriaTab()[2]
	Aadd(aSeek,{"Código viagem", {{"","C",8,0, "ZZ1_VIAGEM",""}}, 1, .T. } )
	Aadd(aSeek,{"Previsão chegada", {{"","C",10,0, "DTOS(ZZ1_DTCHEG) + ZZ1_HRCHEG",}} , 2, .T. } )
	Aadd(aSeek,{"Previsão saída", {{"","C",10,0, "DTOS(ZZ1_DTSAID) + ZZ1_HRSAID",}} , 3, .T. } )
	Aadd(aSeek,{"Cliente", {{"","C",50,0, "ZZ1_CLIN",}} , 4, .T. } )
	
	Aadd(aFieFilter,{'ZZ1_VIAGEM', "Código viagem",'C', 8, 0})
	
	DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]
	
	oBrowse := FWMBrowse():New(oDlg)
	oBrowse:SetMenuDef("PRAA804") // Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Registro de viagens ferroviárias")
	oBrowse:SetAlias(cAliasZZ1)
	oBrowse:setowner(oDlg)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetSeek(.T.,aSeek)
	oBrowse:setFieldFilter(aFieFilter)
	oBrowse:SetUseFilter()
	oBrowse:SetLocate()
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetFields(aCampos)
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	
	oBrowse:AddLegend("ZZ1_SIT == 'R'", "RED"	   ,"Registrada") 
	oBrowse:AddLegend("ZZ1_SIT == 'L'", "BLUE"	,"Liberada")
	oBrowse:AddLegend("ZZ1_SIT == 'C'", "GRAY"   ,"Cancelada")
	oBrowse:AddLegend("ZZ1_SIT == 'E'", "YELLOW"	,"Em operação")
	oBrowse:AddLegend("ZZ1_SIT == 'F'", "BLACK"	,"Finalizada")
	
	oBrowse:Activate()
	If !lKill
		oBrowse:FWFilter():DisableSave(.T.)
		oBrowse:FWFilter():DisableDel(.T.)
		oBrowse:FWFilter():DisableSave(.T.)
		oBrowse:FWFilter():DisableAdd(.T.)
	      
		oBrowse:oFWFilter:SetExecute({||C905FILTER(oBrowse)})
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
	delTabTmp(cAliasZZ1)
Return Nil

//---------------------------------
/*{Protheus.doc}
Função A802VACES verifica se o usuario tem acesso para fazer agendamento das programações.
@param
@author Fernando da Cruz Pinheiro
@version P11
@since 02/01/2014
*/
//---------------------------------
function A804VACES()
	local cQuery := ''
	Local cAlias := GetNextAlias()
   
	cQuery :=  " select cli_id_principal, mnu_id, mod_id, usu_id, cli_id_acesso_info from vw_portal_permissao_acesso where usu_id = 'c"  + StrTran(SCodUsr(),'ECPF','',1,1) +  "' and mnu_id = 'B'"

		
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
	
	dbSelectArea(cAlias)
	(cAlias)->( dbGoTop() )
	
	if alltrim((calias)->cli_id_principal) <> ''
		While (cAlias)->(!Eof())
			aadd(userInf,{(calias)->cli_id_principal,(calias)->mnu_id,(calias)->mod_id,(calias)->usu_id,(calias)->cli_id_acesso_info})
			(cAlias)->(dbSkip())
		EndDo	
	endif

return userInf

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Visualizar"			 	ACTION "VIEWDEF.PRAA804"	              OPERATION 2	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Incluir" 					ACTION 'A804VALEXEC("VIEWDEF.PRAA804",3)' OPERATION 3	ACCESS 0
	ADD OPTION aRotina TITLE "Alterar" 					ACTION 'A804VALEXEC("VIEWDEF.PRAA804",4)' OPERATION 4	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Imprimir"   				ACTION "VIEWDEF.PRAA804"	              OPERATION 8	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Libera/estorna viagem" 	ACTION "A804LibViagem()"	              OPERATION 4	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Cancela/estorna viagem" 	ACTION "A804CanViagem()"	              OPERATION 4	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Atualizar Grid"		 	ACTION "A804Atualizar()"	              OPERATION 3	ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE "Parâmetros" 				ACTION "A804Param()"                      OPERATION 3	ACCESS 0 DISABLE MENU
Return aRotina

Function A804SELEMP()
       Local cAliasEmp := GetNextAlias()        
       Local nCount
       Local cQuery
       Local nlist := 0
       Local oPanelB
       Local oPanelAllClient
       Local oTButtonAbrir
       Local oTButtonSair
       Private oDlgEmp
       Private aReturn //{cEmpPai,cVarEmp,cDescEmp,lAbreTela}
       Private aEmpresas := {}
       Private aEmpresasDesc :={}
       Private oListEmp
       nCount := 0
       cQuery := ''
       cQuery += ' select b.gru_id, '
       cQuery += '        b.cli_id, '
       cQuery += '              case '
       cQuery += '              when b.cli_id is null then c.gru_nome '
       cQuery += '              when b.gru_id is null then d.cli_nome '
       cQuery += '              end as cliente_info, '
       cQuery += '        a.pc_id '
       cQuery += '   from tab_portal_usuario_cliente a '
       cQuery += '       left join tab_portal_cliente b on a.pc_id = b.pc_id '
       cQuery += '       left join tab_grupos c on b.gru_id = c.gru_id '
       cQuery += '       left join tab_clientes d on b.cli_id = d.cli_id '
       cQuery += '       left outer join rel_portal_cliente_menu g on a.pc_id = g.pc_id and g.pcm_bloqueado = 0 '
       cQuery += " where a.usu_id = 'c" + SCodUsr() + "' and g.mnu_id = 'B'" 
             
       cQuery := ChangeQuery(cQuery)
       
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
             MsgAlert("Usuário não possui permissão de administrador para nenhuma empresa. ")           
             aReturn :={,,,.F.}
             Return aReturn
       Endif
    
	   If nCount == 1
	    	If Empty(aEmpresas[1,1])
	       	    aEmpresas[1,1] := SGetTerm()
	        EndIf
	    	    aReturn := {aEmpresas[1,1],aEmpresas[1,1],aEmpresasDesc[1],.T.}
			Return aReturn
	   Endif

       DEFINE MSDIALOG oDlgEmp TITLE "SELEÇÃO DE EMPRESA" FROM 0,0 TO 200,200 PIXEL

       oPanelB:= TPanel():Create(oDlgEmp,01,01,"",,,,,,10,15)
       oPanelB:Align := 4 //CONTROL_ALIGN_BOTTOM

       oPanelAllClient  := TPanel():Create(oDlgEmp,01,102,"",,,,,,100,100)
       oPanelAllClient:Align := 5 //CONTROL_ALIGN_ALLCLIENT

       oListEmp:= TListBox():New(10,10,{|u|If(Pcount()>0,nList:=u,nList)} ,aEmpresasDesc,100,100,,oPanelAllClient,,,,.T.,,{||A804SETEMP()})
       oListEmp:Select(1)
       oListEmp:Align := 5 //CONTROL_ALIGN_ALLCLIENT

       oTButtonAbrir := TButton():New( 01,01,"Confirmar",oPanelB,{||A804SETEMP()},40,10,,,,.T.,,,,,,)
       oTButtonSair  := TButton():New( 01,42,"Cancelar",oPanelB,{||A804CANEMP()},40,10,,,,.T.,,,,,,)

       ACTIVATE MSDIALOG oDlgEmp CENTERED

Return aReturn

//---------------------------------
/*{Protheus.doc}
Função A804SETEMP seleciona 1 cliente para criar a programação
@param
@author Siegklenes.beulke
@version P11
@since 25/06/2014
*/
//---------------------------------
Static Function A804SETEMP() 
	local nIndex
	
	nIndex := oListEmp:GetPos()
	aReturn := {aEmpresas[nIndex,1],aEmpresas[nIndex,1],aEmpresasDesc[nIndex],.T.}
	oDlgEmp:End() 
return
//---------------------------------
/*{Protheus.doc}
Função A804CANEMP cancela a seleção dos clientes.
@param
@author siegklenes.beulke
@version P11
@since 25/06/2014
*/
//---------------------------------
static function A804CANEMP()
	aReturn :={,,,.F.}
	oDlgEmp:End()
return

//---------------------------------
/*{Protheus.doc}
Função PRAA804PER Limpa os campos de data quando a viagem for sim
@param parametros do pergunte
@author siegklenes.beulke
@version P11
@since 25/06/2014
*/
//---------------------------------

Function PRAA804PER(nViagem,dDataIni,dDataFim)
	If nViagem == 1
		dDataIni := STOD(Replicate(" ",8))
		dDataFim := STOD(Replicate(" ",8))
	EndIf
Return .T.


//Carrega as informações nas tabelas e cria as tabelas, se necessário
Static Function CarregaDados(lCriaTab)
	Local cQuery := ""
	Local aCampos
	Local nCampos
	Local nI
	Local cAliasTmp
	Default lCriaTab := .F.
	
	aCampos := CriaTab(lCriaTab)[1]
	nCampos := Len(aCampos)
	cQuery += "SELECT"
	cQuery += "    a.vf_id ZZ1_VIAGEM,"
	cQuery += "    a.vf_tipo_viagem  ZZ1_TIPO,"
	cQuery += "    CASE WHEN a.vf_tipo_viagem  = 'E' THEN 'Entrada' ELSE 'Saída'END ZZ1_DSTIPO,"
	cQuery += "    CAST(a.op_id AS VARCHAR(10)) ZZ1_OPER,"
	cQuery += "    b.op_descricao ZZ1_DSOPER,"
	cQuery += "    CONVERT(VARCHAR, a.vf_dt_prev_chegada , 103) ZZ1_DTCHEG,"
	cQuery += "    CONVERT(VARCHAR, a.vf_dt_prev_chegada , 108) ZZ1_HRCHEG,"
	cQuery += "    CONVERT(VARCHAR, a.vf_dt_prev_saida, 103) ZZ1_DTSAID,"
	cQuery += "    CONVERT(VARCHAR, a.vf_dt_prev_saida, 108) ZZ1_HRSAID,"
	cQuery += "    a.vf_nr_vagao_cheio  ZZ1_VAGCHE,"
	cQuery += "    a.vf_nr_vagao_vazio ZZ1_VAGVAZ,"
	cQuery += "    a.vf_nr_vagao_cheio  + a.vf_nr_vagao_vazio ZZ1_VAGPRE,"
	cQuery += "    CASE WHEN a.vf_tipo_viagem  = 'E' "
	cQuery += "         THEN (SELECT COUNT(*) FROM tab_programacao WHERE vf_id = a.vf_id)"
	cQuery += "         ELSE 0"
	cQuery += "    END ZZ1_VAGAGE,"
	cQuery += "    (SELECT COUNT(*) FROM tab_programacao WHERE vf_id = a.vf_id and cesv_id is not null) ZZ1_VAGREC,"
	cQuery += "    CAST(a.cli_operador AS VARCHAR(10)) ZZ1_OPFERR,"
	cQuery += "    c.cli_cgc ZZ1_CGCOPF,"
	cQuery += "    c.cli_nome ZZ1_DSOPFE,"
	cQuery += "    CAST(a.cli_transportador AS VARCHAR(10)) ZZ1_TRFERR,"
	cQuery += "    d.cli_cgc ZZ1_CGCTRF,"
	cQuery += "    d.cli_nome ZZ1_DSTRFE,"
	cQuery += "    CAST(a.rec_origem AS VARCHAR(10)) ZZ1_RECORI,"
	cQuery += "    e.rec_nome ZZ1_NMREOR,"
	cQuery += "    CAST(a.rec_destino AS VARCHAR(10)) ZZ1_RECDES,"
	cQuery += "    f.rec_nome ZZ1_NMREDE,"
	cQuery += "    CONVERT(VARCHAR, a.vf_dt_liberacao, 103) ZZ1_DTLIB,"
	cQuery += "    CONVERT(VARCHAR, a.vf_dt_liberacao, 108) ZZ1_HRLIB,"
	cQuery += "    CONVERT(VARCHAR, a.vf_dt_cancelamento, 103) ZZ1_DTCAN,"
	cQuery += "    CONVERT(VARCHAR, a.vf_dt_cancelamento, 108) ZZ1_HRCAN,"
	cQuery += "    Coalesce(vf_situacao,'R') ZZ1_SIT, "
	cQuery += "    Coalesce(i.cli_nome, ' ') ZZ1_CLIN, "
	cQuery += "    CASE "
	cQuery += "         WHEN vf_situacao  = 'L' "
	cQuery += "            THEN 'Liberada' "
	cQuery += "         WHEN vf_situacao  = 'C' "
	cQuery += "            THEN 'Cancelada' "
	cQuery += "         WHEN vf_situacao  = 'E' "
	cQuery += "            THEN 'Em operação' "
	cQuery += "         WHEN vf_situacao  = 'F' "
	cQuery += "            THEN 'Finalizada' "
	cQuery += "         ELSE 'Registrada'"
	cQuery += "    END ZZ1_DSIT "
	
	cQuery += "    FROM tab_viagem_ferroviaria a"
	cQuery += "    INNER JOIN tab_operacao b"
	cQuery += "    ON a.op_id = b.op_id"
	
	cQuery += "    INNER JOIN rel_trans_ben_com g"	
	cQuery += "    ON g.trans_id = a.cli_operador"
	
	cQuery += "    INNER JOIN tab_clientes c"
	cQuery += "    ON c.cli_id = g.ben_id"
	
	cQuery += "    INNER JOIN rel_trans_ben_com h"	
	cQuery += "    ON h.trans_id = a.cli_transportador"
	
	cQuery += "    INNER JOIN tab_clientes d"
	cQuery += "    ON d.cli_id = h.ben_id"
	
	cQuery += "    LEFT JOIN tab_recintos e
	cQuery += "    ON a.rec_origem = e.rec_id"
	
	cQuery += "    LEFT JOIN tab_recintos f"
	cQuery += "    ON a.rec_destino = f.rec_id"
	
	cQuery += "    LEFT JOIN tab_clientes i"
	cQuery += "    ON a.cli_id_resp = i.cli_id"
	
	If (A802GetcEmpPai() != SGetTerm())
      cQuery += " WHERE a.cli_id_resp = '" + A802GetcEmpPai() + "'"
      If !Empty(cFiltroSql)
         cQuery +=  " and " + cFiltroSql
      EndIf
    ElseIf !Empty(cFiltroSql)
   	   cQuery += " WHERE " + cFiltroSql
    endif	

	cQuery += " ORDER BY a.vf_id "
	
	cAliasTmp := GetNextAlias()
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAliasTmp,.F.,.T.)
	If !lCriaTab
		dbSelectArea(cAliasZZ1)
		EndTran()
		ZAP
		dbSelectArea(cAliasTmp)
	EndIf
	While ! (cAliasTmp)->(Eof())
	    (cAliasZZ1)->(DbAppend())
	    For nI := 1 To nCampos
	        If (cAliasZZ1)->(FieldPos(aCampos[nI,1])) > 0 .And. aCampos[nI,2] <> 'D'
	            (cAliasZZ1)->(FieldPut(FieldPos(aCampos[nI,1]),(cAliasTmp)->(FieldGet((cAliasTmp)->(FieldPos(aCampos[nI,1]))))))
	        Endif
	        If (cAliasZZ1)->(FieldPos(aCampos[nI,1])) > 0 .And. aCampos[nI,2] == 'D'
	            (cAliasZZ1)->(FieldPut(FieldPos(aCampos[nI,1]),CTOD((cAliasTmp)->(FieldGet((cAliasTmp)->(FieldPos(aCampos[nI,1])))))))
	        Endif
	    Next nI
	    (cAliasTmp)->(DbSkip())
	End
	(cAliasTmp)->(dbCloseArea())
Return

Static Function CriaTab(lCriaTab)	

	Local aCampos := {	{'ZZ1_VIAGEM'	,'C',08,0},;
							{'ZZ1_TIPO'	,'C',01,0},;
							{'ZZ1_DSTIPO'	,'C',07,0},;
							{'ZZ1_OPER'	,'C',10,0},;
							{'ZZ1_DSOPER'	,'C',30,0},;
							{'ZZ1_DTCHEG'	,'D',08,0},;
							{'ZZ1_HRCHEG'	,'C',05,0},;
							{'ZZ1_DTSAID'	,'D',08,0},;
							{'ZZ1_HRSAID'	,'C',05,0},;
							{'ZZ1_VAGCHE'	,'N',10,0},;
							{'ZZ1_VAGVAZ'	,'N',10,0},;
							{'ZZ1_VAGPRE'	,'N',10,0},;
							{'ZZ1_VAGAGE'	,'N',10,0},;
							{'ZZ1_VAGREC'	,'N',10,0},;
							{'ZZ1_OPFERR'	,'C',10,0},;
							{'ZZ1_CGCOPF'	,'C',18,0},;
							{'ZZ1_DSOPFE'	,'C',50,0},;
							{'ZZ1_TRFERR'	,'C',10,0},;
							{'ZZ1_CGCTRF'	,'C',18,0},;
							{'ZZ1_DSTRFE'	,'C',50,0},;
							{'ZZ1_RECORI'	,'C',10,0},;
							{'ZZ1_NMREOR'	,'C',50,0},;
							{'ZZ1_RECDES'	,'C',10,0},;
							{'ZZ1_NMREDE'	,'C',50,0},;
							{'ZZ1_DTLIB'	,'D',08,0},;
							{'ZZ1_HRLIB'	,'C',05,0},;
							{'ZZ1_DTCAN'	,'D',08,0},;
							{'ZZ1_HRCAN'	,'C',05,0},;
							{'ZZ1_SIT'		,'C',01,0},;
							{'ZZ1_CLIN'   ,'C',50,0},;
							{'ZZ1_DSIT'   ,'C',11,0}}
							
	Local aCamposBrw :={	{'Cód.'					,'ZZ1_VIAGEM'	,'C',05,0},;
							{'Siuação'			       ,'ZZ1_DSIT'	,'C',04,0},;
							{'Tipo'					,'ZZ1_DSTIPO'	,'C',04,0},;
							{'Operação'				,'ZZ1_DSOPER'	,'C',04,0},;
							{'Operador'				,'ZZ1_DSOPFE'	,'C',05,0},;
							{'Previsão chegada' 		,'ZZ1_DTCHEG'	,'D',04,0},;
							{'Hora'					,'ZZ1_HRCHEG'	,'C',04,0},;
							{'Previsão saída' 		,'ZZ1_DTSAID'	,'D',04,0},;
							{'Hora'					,'ZZ1_HRSAID'	,'C',04,0},;
							{'Vagões cheios'			,'ZZ1_VAGCHE'	,'N',04,0},;
							{'Vagões vazios'			,'ZZ1_VAGVAZ'	,'N',04,0},;
							{'Vagões previstos'		,'ZZ1_VAGPRE'	,'N',04,0},;
							{'Vagões agendados'		,'ZZ1_VAGAGE'	,'N',04,0},;
							{'Vagões recebidos'		,'ZZ1_VAGREC'	,'N',04,0},;							
							{'Transportador'			,'ZZ1_DSTRFE'	,'C',10,0},;							
							{'Terminal origem'		,'ZZ1_NMREOR'	,'C',10,0},;
							{'Terminal destino'		,'ZZ1_NMREDE'	,'C',10,0},;
							{'Data da liberação'		,'ZZ1_DTLIB'	,'D',08,0},;
							{'Hora'					,'ZZ1_HRLIB'	,'C',05,0},;
							{'Data do cancelamento'	,'ZZ1_DTCAN'	,'D',08,0},;
							{'Hora'					,'ZZ1_HRCAN'	,'C',05,0},;
							{'Cliente'					,'ZZ1_CLIN'	,'C',10,0}}

	Default lCriaTab := .F.					
	If lCriaTab
		cAliasZZ1 := CriaTabTmp(aCampos,{'ZZ1_VIAGEM',"DTOS(ZZ1_DTCHEG) + ZZ1_HRCHEG","DTOS(ZZ1_DTSAID) + ZZ1_HRSAID", "ZZ1_CLIN"},cAliasZZ1)
	EndIf
Return {aCampos,aCamposBrw}

Static Function ModelDef()
	Local oModel  	   := Nil
	Local oStructZZ1   := FWFormModelStruct():New()

	Default cAliasZZ1 := GetNextAlias()
	
	oStructZZ1:AddTable(cAliasZZ1, {'ZZ1_VIAGEM'},"Viagens ferroviarias")
	oStructZZ1:AddIndex(1,'01','ZZ1_VIAGEM','Indice 1','','',.T.)
	
	oStructZZ1:AddField("Viagem", "Código da viagem", "ZZ1_VIAGEM", "C",  8, 0, {||.T./*bValid*/},{||.F./*bWhen*/},/*aValues*/,.T./*LOBRIGAT*/,{||GetCodViagem()} ,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ1:AddField("Situação", "Situação", "ZZ1_SIT", "C",  1, 0, {||FwFldGet("ZZ1_SIT") $ ("FECLR")/*BVALID*/},{||.T./*bWhen*/},{"R=Registrada","L=Liberada","C=Cancelada","E=Em operação","F=Finalizada"},.T./*LOBRIGAT*/,{||"R"/*bInit*/},/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ1:AddField("Operador", "Operador ferroviário", "ZZ1_OPFERR", "C",  10, 0, {||.T.},{||.T./*BWHEN*/},/*aValues*/,.T./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Operador (CNPJ/ CPF)", "Operador (CNPJ/ CPF)", "ZZ1_CGCOPF", "C",  21, 0, {||A804VALTRANSP(1)},{||.T./*BWHEN*/},/*aValues*/,.T./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Nome operador", "Nome operador ferroviário", "ZZ1_DSOPFE", "C",  50, 0, , ,/*aValues*/,.F./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ1:AddField("Transportador", "Transportador ferroviário", "ZZ1_TRFERR", "C",  10, 0, {||.T.},{||.T./*BWHEN*/},/*aValues*/,.T./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Transportador (CNPJ/ CPF)", "Transportador (CNPJ/ CPF)", "ZZ1_CGCTRF", "C",  21, 0, {||A804VALTRANSP(2)},{||.T./*BWHEN*/},/*aValues*/,.T./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Nome transportador", "Nome transportador ferroviário", "ZZ1_DSTRFE", "C",  50, 0, {||.T.},{||.F./*BWHEN*/},/*aValues*/,.F./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ1:AddField("Tipo viagem", "Tipo de viagem", "ZZ1_TIPO", "C",  1, 0, {||A804AtuTipo()/*BVALID*/},{||.T./*bWhen*/},{"E=Entrada","S=Saída"," = "},.T./*LOBRIGAT*/,{||" "/*bInit*/},/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Tipo viagem", "Tipo de viagem", "ZZ1_DSTIPO", "C",  7, 0, {||.T./*BVALID*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/,{||""/*bInit*/},/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ1:AddField("Tipo operação", "Tipo de operação", "ZZ1_OPER", "C",  10, 0, {||A804ExistReg("tab_operacao",{'ZZ1_OPER','op_id'},,{'ZZ1_DSOPER','op_descricao'},'PRAA804')},{||.T./*BWHEN*/},/*aValues*/,.T./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Descrição", "Descrição", "ZZ1_DSOPER", "C",  30, 0, {||.T.},{||.F./*BWHEN*/},/*aValues*/,.F./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ1:AddField("Terminal origem ", "Terminal de origem", "ZZ1_RECORI", "C",  10, 0, {||A804ExistReg("TAB_RECINTOS",{'ZZ1_RECORI','REC_ID'},,{'ZZ1_NMREOR','REC_NOME'},'PRAA804')},{||.T./*BWHEN*/},/*aValues*/,.T./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Descrição", "Descrição", "ZZ1_NMREOR", "C",  50, 0, {||.T.},{||.F./*BWHEN*/},/*aValues*/,.T./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ1:AddField("Terminal destino ", "Terminal de destino", "ZZ1_RECDES", "C",  10, 0, {||A804ExistReg("TAB_RECINTOS",{'ZZ1_RECDES','REC_ID'},,{'ZZ1_NMREDE','REC_NOME'},'PRAA804')},{||.T./*BWHEN*/},/*aValues*/,.T./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Descrição", "Descrição", "ZZ1_NMREDE", "C",  50, 0, {||.T.},{||.F./*BWHEN*/},/*aValues*/,.T./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ1:AddField("Previsão chegada", "Data da previsão chegada", "ZZ1_DTCHEG", "D",  8, 0, {||.T./*BVALID*/},{||FwFldGet("ZZ1_TIPO") == "E"/*bWhen*/},/*avalues*/,.F./*LOBRIGAT*/,/*{||/*bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Hora chegada", "Hora da previsão chegada", "ZZ1_HRCHEG", "C",  5, 0, {||.T./*BVALID*/},{||FwFldGet("ZZ1_TIPO") == "E"/*bWhen*/},/*avalues*/,.F./*LOBRIGAT*/,/*{||/*bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ1:AddField("Previsão saída", "Data da previsão saída", "ZZ1_DTSAID", "D",  8, 0, {||.T./*BVALID*/},{||FwFldGet("ZZ1_TIPO") == "S"/*bWhen*/},/*avalues*/,.F./*LOBRIGAT*/,/*{||/*bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Hora saída", "Hora da previsão saída", "ZZ1_HRSAID", "C",  5, 0, {||.T./*BVALID*/},{||FwFldGet("ZZ1_TIPO") == "S"/*bWhen*/},/*avalues*/,.F./*LOBRIGAT*/,/*{||/*bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ1:AddField("Vagões cheios", "Vagões cheios", "ZZ1_VAGCHE", "N",  10, 0, {||A804AtuPrev()/*BVALID*/},{||.T./*bWhen*/},/*avalues*/,.F./*LOBRIGAT*/,/*{||/*bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Vagões vazios", "Vagões vazios", "ZZ1_VAGVAZ", "N",  10, 0, {||A804AtuPrev()/*BVALID*/},{||.T./*bWhen*/},/*avalues*/,.F./*LOBRIGAT*/,/*{||/*bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Vagões previstos", "Vagões previstos", "ZZ1_VAGPRE", "N",  10, 0, {||.T./*BVALID*/},{||.F./*bWhen*/},/*avalues*/,.F./*LOBRIGAT*/,/*{||/*bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ1:AddField("Cliente", "Cliente", "ZZ1_CLIN", "C",  50, 0, {||.F./*BVALID*/},{||.F./*bWhen*/},/*avalues*/,.F./*LOBRIGAT*/,/*{||/*bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oModel := MPFormModel():New('PRAA804',,{|oModel|A804BPOS(oModel)})
	
	oModel:SetDescription("Viagens ferroviarias")
	oModel:AddFields('PRAA804', Nil, oStructZZ1,,,)
	oModel:GetModel('PRAA804'):SetDescription("Viagens ferroviarias")
	oModel:SetPrimaryKey({'ZZ1_VIAGEM'})
//	oModel:SetActivate({|oModel|A802LOAD(oModel)})
    
    oModel:InstallEvent("_A804EVENT",, _A804EVENT():New())
   
	oModel:SetVldActivate({|oModel| A804ACTIVE(oModel)})
Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel('PRAA804')
	Local oStructZZ1	:= FWFormViewStruct():New()
	Local oView := Nil
	oStructZZ1:AddField("ZZ1_VIAGEM","01","Viagem", "Código da viagem",/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oStructZZ1:AddField("ZZ1_SIT","02","Situação", "Situação",/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,{"R=Registrada","L=Liberada","C=Cancelada","E=Em operação","F=Finalizada"}/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oStructZZ1:AddField("ZZ1_CGCOPF","03","Operador (CNPJ/ CPF)", "Operador (CNPJ/ CPF)",/*aHelp*/,"C","@R 99.999.999/9999-99",{||S_PICPES( FwFldGet("ZZ1_CGCOPF")) },"SAROPE"/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_DSOPFE","04","Nome operador", "Nome operador ferroviário",/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)

	oStructZZ1:AddField("ZZ1_CGCTRF","05","Transportador (CNPJ/ CPF)", "Transportador (CNPJ/ CPF)",/*aHelp*/,"C","@R 99.999.999/9999-99",{||S_PICPES( FwFldGet("ZZ1_CGCTRF")) },"SAROPE"/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_DSTRFE","06","Nome transportador", "Nome transportador ferroviário",/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oStructZZ1:AddField("ZZ1_TIPO","07","Tipo viagem", "Tipo de viagem",/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,{"E=Entrada","S=Saída",""}/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oStructZZ1:AddField("ZZ1_OPER","08","Tipo operação", "Tipo de operação",/*aHelp*/,"C",/*PIC*/,/*BPIC*/,"SARAOP"/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_DSOPER","09","Descrição", "Descrição",/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oStructZZ1:AddField("ZZ1_RECORI","10","Terminal origem", "Terminal de origem",/*aHelp*/,"C",/*PIC*/,/*BPIC*/,"SARARC"/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_NMREOR","11","Descrição", "Descrição",/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oStructZZ1:AddField("ZZ1_RECDES","12","Terminal destino", "Terminal de destino",/*aHelp*/,"C",/*PIC*/,/*BPIC*/,"SARARC"/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,/*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_NMREDE","13","Descrição", "Descrição",/*aHelp*/,"C",/*PIC*/,/*BPIC*/,/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oStructZZ1:AddField("ZZ1_DTCHEG","14","Previsão chegada", "Data da previsão chegada",/*aHelp*/,"D",/*PIC*/,/*BPIC*/,/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.F./*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_HRCHEG","15","Hora chegada", "Hora da previsão chegada",/*aHelp*/,"C","@E 99:99",/*BPIC*/,/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oStructZZ1:AddField("ZZ1_DTSAID","16","Previsão saída", "Data da previsão saída",/*aHelp*/,"D",/*PIC*/,/*BPIC*/,/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.F./*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_HRSAID","17","Hora saída", "Hora da previsão saída",/*aHelp*/,"C","@E 99:99",/*BPIC*/,/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oStructZZ1:AddField("ZZ1_VAGCHE","18","Vagões cheios", "Vagões cheios",/*aHelp*/,"N","9999999999",/*BPIC*/,/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_VAGVAZ","19","Vagões vazios", "Vagões vazios",/*aHelp*/,"N","9999999999",/*BPIC*/,/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_VAGPRE","20","Vagões previstos", "Vagões previstos",/*aHelp*/,"N","9999999999",/*BPIC*/,/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
//	oView:SetUseCursor(.F.)
	oView:CreateHorizontalBox( 'SUPERIOR' , 100,,,,)
	//TABELA PRINCIPAL
	oView:AddField('PRAA804' , oStructZZ1)
	oView:SetOwnerView('PRAA804', 'SUPERIOR')
	//Caso Alterar a situação, verificar se a nova faz parte do parâmetro de pesquisa
//	oView:SetCloseOnOk({|oModel|A804ViewClose(oModel)})
Return oView

Static Function GetCodViagem()
	Local cAliasTmp := GetNextAlias()
	Local cQuery := " Select vf_id from tab_viagem_ferroviaria order by vf_id desc"
	Local cAno	:=	SubStr(cValToChar(Year(DDATABASE)),3,2)
	Local cCodViagem
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTmp,.F.,.T.)
	(cAliasTmp)->(dbgotop())
	cCodViagem := (cAliasTmp)->(FieldGet(1))
	If !(cAliasTmp)->(Eof()) .And. !Empty(cCodViagem)
		If cAno == SubStr(cCodViagem,1,2)
			cCodViagem := cAno + "/" + StrZero(Val(SubStr(cCodViagem,4))+1,5)
		Else
			cCodViagem := cAno + "/" + "00001"
		EndIf
	Else
		cCodViagem := cAno + "/" + "00001"
	EndIf
	
	(cAliasTmp)->(dbCloseArea())	 

Return cCodViagem

//Realiza a validação do transportador e atualiza a descrição
Function A804VALTRANSP(iVal)
    Local oModel    := FWModelActive()
    Local oModelTMP := oModel:GetModel('PRAA804')
	Local lRet := .T.
	Local cAliasTmp := GetNextAlias()
	Local cQuery := ""
	Local cVar
	Local cVarDesc
	Local cVarCgc
	Local cCodTransp
	Local oView := FwViewActive()
	Local cCodId := "12"
	If iVal == 1
		cVar := "ZZ1_OPFERR"
		cVarCgc := "ZZ1_CGCOPF"
		cVarDesc := "ZZ1_DSOPFE"
	ElseIf iVal == 2
		cVar := "ZZ1_TRFERR"
		cVarCgc := "ZZ1_CGCTRF"
		cVarDesc := "ZZ1_DSTRFE"
	EndIf
	
	cCodTransp := AllTrim(oModel:GetValue("PRAA804",cVarCgc))
	
	If !Empty(cCodTransp)
		cQuery += " select d.Trans_id,a.cli_nome,a.cli_cgc from tab_clientes a"
		cQuery += " inner join rel_tipo_cliente b on a.cli_id = b.cli_id"
		cQuery += " inner join tab_tipo_cliente c on b.tcli_id = c.tcli_id"
		cQuery += " inner join rel_trans_ben_com d on a.cli_id = d.ben_id"
		cQuery += " where c.tcli_id = " + cCodId
		cQuery += " and a.cli_cgc = '" + cValToChar(cCodTransp) + "'" 
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTmp,.F.,.T.)
		(cAliasTmp)->(dbGoTop())
		If !(cAliasTmp)->(Eof()) .And. !Empty((cAliasTmp)->(FieldGet(1)))
			oModel:GetModel('PRAA804'):SetValue(cVar,cValToChar((cAliasTmp)->(FieldGet(1))))
			oModel:GetModel('PRAA804'):LoadValue(cVarDesc,(cAliasTmp)->(FieldGet(2)))
			If ValType(oView) != "U"
				oView:Refresh()
			EndIf
		Else
		
		    if ((PRAA804TipoCli(cValToChar(cCodTransp)) != nil) .and.;
		        (PRAA804TipoCli(cValToChar(cCodTransp)) != 12))
			   MsgStop("O CPF ou CNPJ informado não está cadastrado como transportador ferroviário.") 
			   
			   iVal := 3
			   
			   oModel:GetModel('PRAA804'):LoadValue(cVarCgc,'')
			   oView:Refresh()
			   
			   return .F.
			   
			endif
		
		    if (iVal == 1)
		       
		       if(PRAA804ValidaCPFCNPJ(AllTrim(oModel:GetValue("PRAA804",'ZZ1_CGCOPF'))) == .T.)
			       if(msgyesno('O operador não foi encontrado no sistema.' + chr(13) + 'Deseja cadastrar?','Aviso'))
					    PRAA808A(AllTrim(oModel:GetValue("PRAA804",'ZZ1_CGCOPF')),'O','B')
					    
					    oModelTMP:LoadValue('ZZ1_CGCOPF','')
					    oView:Refresh()
					    
					    (cAliasTmp)->(DbCloseArea())
					    
					    cQuery += " select d.Trans_id,a.cli_nome,a.cli_cgc from tab_clientes a"
						cQuery += " inner join rel_tipo_cliente b on a.cli_id = b.cli_id"
						cQuery += " inner join tab_tipo_cliente c on b.tcli_id = c.tcli_id"
						cQuery += " inner join rel_trans_ben_com d on a.cli_id = d.ben_id"
						cQuery += " where c.tcli_id = " + cCodId
						cQuery += " and a.cli_cgc = '" + cValToChar(cCodTransp) + "'" 
						
						DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTmp,.F.,.T.)
						
						oModel:GetModel('PRAA804'):LoadValue(cVarCgc,(cAliasTmp)->(FieldGet(3)))
						oModel:GetModel('PRAA804'):SetValue(cVar,cValToChar((cAliasTmp)->(FieldGet(1))))
			            oModel:GetModel('PRAA804'):LoadValue(cVarDesc,(cAliasTmp)->(FieldGet(2)))
	
	                    oView:Refresh() 
			            lRet := .T.
				   else
				        lRet := .F.
				   endif
			   else 
			      return .F.
			   endif
		    endif
		    
		    if (iVal == 2) 
		        if(PRAA804ValidaCPFCNPJ(AllTrim(oModel:GetValue("PRAA804",'ZZ1_CGCTRF'))) == .T.)
				    if(msgyesno('A transportadora não foi encontrado no sistema.'+chr(13)+'Deseja cadastrar?','Aviso'))
			              PRAA808A(AllTrim(oModel:GetValue("PRAA804",'ZZ1_CGCTRF')),'T','B')
			              
			              oModelTMP:LoadValue('ZZ1_CGCTRF','')
					      oView:Refresh()
					    
			              (cAliasTmp)->(DbCloseArea())
					    
					      cQuery += " select d.Trans_id,a.cli_nome,a.cli_cgc from tab_clientes a"
						  cQuery += " inner join rel_tipo_cliente b on a.cli_id = b.cli_id"
						  cQuery += " inner join tab_tipo_cliente c on b.tcli_id = c.tcli_id"
						  cQuery += " inner join rel_trans_ben_com d on a.cli_id = d.ben_id"
						  cQuery += " where c.tcli_id = " + cCodId
						  cQuery += " and a.cli_cgc = '" + cValToChar(cCodTransp) + "'" 
						
						  DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTmp,.F.,.T.)
						
						  oModel:GetModel('PRAA804'):LoadValue(cVarCgc,(cAliasTmp)->(FieldGet(3)))
						  oModel:GetModel('PRAA804'):SetValue(cVar,cValToChar((cAliasTmp)->(FieldGet(1))))
			              oModel:GetModel('PRAA804'):LoadValue(cVarDesc,(cAliasTmp)->(FieldGet(2)))

					      oView:Refresh()
			              lRet := .T.
			        else
			              lRet := .F.
					  
			        endif
			    else 
			       return .F.
		        endif
	        endif
		EndIf
		(cAliasTmp)->(dbCloseArea())
	else 
	   if(iVal == 1)
	       oModelTMP:LoadValue('ZZ1_DSOPFE','')
	   elseif(iVal == 2)
	       oModelTMP:LoadValue('ZZ1_DSTRFE','')
	   endif
	    
	   oView:Refresh()
	EndIf	
Return lRet

//Valida se o registro exibe conforme o aCampo e atualiza o aCampo2, se necessário
//aCampo := {'ZZ1_OPER','op_id'}
//aCampo2 := {'ZZ1_DSOPER','op_descricao'}
Function A804ExistReg(cTabela,aCampo,cCondicao,aCampo2,cModel)
	Local lRet := .T.
	Local oModel := FwModelActive()
	Local oView := FwViewActive()
	Local cAliasTmp := GetNextAlias()
	Local cQuery := ""
	Local uValue := AllTrim(oModel:GetValue("PRAA804",aCampo[1])) 
	Default aCampo2 := {}
	
	If Empty(uValue)
		oModel:GetModel(cModel):LoadValue(aCampo2[1],"")
		Return lRet
	EndIf
	
	uValue := "'" + uValue + "'"
		
	cQuery += "Select " + aCampo[2] + " ID " + If(Len(aCampo2) > 0,", " + aCampo2[2] + " DESCR ","")
	cQuery += " FROM " + cTabela
	cQuery += " WHERE " + aCampo[2] + " = " + uValue
	
	If !Empty(cCondicao)
		cQuery += " AND " + cCondicao
	EndIf
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTmp,.F.,.T.)
	(cAliasTmp)->(dbGoTop())
	If !(cAliasTmp)->(Eof()) .And. !Empty((cAliasTmp)->(FieldGet(1)))
		If Len(aCampo2) > 0
			oModel:GetModel(cModel):LoadValue(aCampo2[1],(cAliasTmp)->(FieldGet(2)))
			If ValType(oView) != "U"
				oView:Refresh()
			EndIf
		EndIf
	Else
		lRet := .F.		
	EndIf
	
	
Return lRet

//Atualiza a descrição do tipo de viagem
Function A804AtuTipo()
	Local oModel := FwModelActive()
	Local cVar := oModel:GetValue("PRAA804","ZZ1_TIPO")
	Local cVarDesc := "ZZ1_DSTIPO"
	
	If cVar == "E"
		oModel:GetModel('PRAA804'):LoadValue(cVarDesc,"Entrada")
	ElseIf cVar == "S"
		oModel:GetModel('PRAA804'):LoadValue(cVarDesc,"Saída")
	EndIf
Return .T.

//Atualiza os vagoes previstos
Function A804AtuPrev()
	Local oModel := FwModelActive()
	oModel:GetModel('PRAA804'):LoadValue("ZZ1_VAGPRE",oModel:GetValue("PRAA804","ZZ1_VAGCHE") + oModel:GetValue("PRAA804","ZZ1_VAGVAZ"))
Return .T.

//Zoom do operador de carga/transportador de modal
Function A804SZoomOPE(cMod)
   Local aRet := {}
   Local aFields := {}
   Local cSql := ""
   Local cCodId
   Default cMod := "F"
   If Empty(cMod)
      cMod := "F"
   EndIf
   If cMod == 'F'
      cCodId := "12"
   ElseIf cMod == 'V'
      cCodId := "5"
   	ElseIf cMod == 'M'
   	   cCodId := "14"
   	ElseIf cMod == 'A'
   	   cCodId := "11"
   	EndIf
   	
   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cSql +=  " select CASE LEN(a.cli_cgc) "   
	cSql +=  "      WHEN 14 then "   
	cSql +=  "         SUBSTRING(a.cli_cgc,1,2)++'.'++SUBSTRING(a.cli_cgc,3,3)++'.'++SUBSTRING(a.cli_cgc,6,3)++'/'++SUBSTRING(a.cli_cgc,9,4)++'-'++SUBSTRING(a.cli_cgc,13,2) "   
	cSql +=  "      WHEN 11 then "   
	cSql +=  "         SUBSTRING(a.cli_cgc,1,3)++'.'++SUBSTRING(a.cli_cgc,4,3)++'.'++SUBSTRING(a.cli_cgc,7,3)++'-'++SUBSTRING(a.cli_cgc,10,2) "   
	cSql +=  "      ELSE "   
	cSql +=  "         a.cli_cgc "   
	cSql +=  " END AS cli_cgc, "	
	cSql += " a.cli_nome, "
	cSql += "  cAST(d.trans_id AS VARCHAR(10)) trans_id from tab_clientes a "
	cSql += " inner join rel_tipo_cliente b on a.cli_id = b.cli_id"
	cSql += " inner join tab_tipo_cliente c on b.tcli_id = c.tcli_id"
	cSql += " inner join rel_trans_ben_com d on a.cli_id = d.ben_id"
	cSql += " where c.tcli_id = " + cCodId
	
	If cEmpPai <> SGetTerm()
		cSql += " and exists (select 1  "
   		cSql += " from vw_portal_permissao_acesso "
        cSql += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "'"
        cSql += " and cli_id_acesso_info = a.cli_id) "
	endif
   
   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY a.cli_nome')
              //aFields,   cCampo           ,  cDesc             , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "cli_cgc"     , "CNPJ/CPF"              , "C"  , 18    , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "cli_nome"     , "Nome"              , "C"  , 50    , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "trans_id"     , "Código"             , "C"  , 10      , 0        , ""      , .T.  , .F.)   

   Aadd(aRet, aFields)
Return aRet

//Validações do modelo de dados
Static Function A804BPOS(oModel)
	Local lRet := .T.
	Local nOP := oModel:GetOperation()
	
	If nOP != MODEL_OPERATION_DELETE
		
		If oModel:GetValue("PRAA804","ZZ1_VAGPRE") <= 0
			lRet := .F.
			Help(,,'HELP',,'A quantidade de vagões previstos não pode ser inferior ou igual a zero.',1,0)
		endif
		
		If nOP == MODEL_OPERATION_INSERT
			oModel:GetModel('PRAA804'):LoadValue("ZZ1_CLIN",cDescEmp)
		endif
		
		If oModel:GetValue("PRAA804","ZZ1_TIPO") == "E"
			oModel:GetModel('PRAA804'):LoadValue("ZZ1_DTSAID",STOD("        "))
			oModel:GetModel('PRAA804'):LoadValue("ZZ1_HRSAID","")
			
			If Empty(StrTran(oModel:GetValue("PRAA804","ZZ1_HRCHEG"),":",""))
				lRet := .F.
				Help(,,'HELP',,'A hora da previsão de chegada deve estar preenchida',1,0)
			EndIf
			
			If Empty(oModel:GetValue("PRAA804","ZZ1_DTCHEG"))
				lRet := .F.
				Help(,,'HELP',,'A data da previsão de chegada deve estar preenchida',1,0)
			EndIf
					
		EndIf
		
		If oModel:GetValue("PRAA804","ZZ1_TIPO") == "S"
			oModel:GetModel('PRAA804'):LoadValue("ZZ1_DTCHEG",STOD("        "))
			oModel:GetModel('PRAA804'):LoadValue("ZZ1_HRCHEG","")
			If Empty(StrTran(oModel:GetValue("PRAA804","ZZ1_HRSAID"),":",""))
				lRet := .F.
				Help(,,'HELP',,'A hora da previsão de saída deve estar preenchida',1,0)
			EndIf
			
			If Empty(oModel:GetValue("PRAA804","ZZ1_DTSAID"))
				lRet := .F.
				Help(,,'HELP',,'A data da previsão de saída deve estar preenchida',1,0)
			EndIf
			
		EndIf
	EndIf
	
Return lRet

//Gravação do modelo de daddos

Static Function A804BCOMMIT(oModel)
	Local aResult := {}
	Local cErro
	Local nOp := oModel:GetOperation()
	Local dDataCheg := oModel:GetValue("PRAA804","ZZ1_DTCHEG")
	Local dDataSai := oModel:GetValue("PRAA804","ZZ1_DTSAID")
	Local cViagem := GetCodViagem()
	Local cSit
	
	If Empty(dDataCheg)
		dDataCheg := '0'
	Else
		dDataCheg := SDBDate(dDataCheg,oModel:GetValue("PRAA804","ZZ1_HRCHEG"))
	EndIf
	
	If Empty(dDataSai)
		dDataSai := '0'
	Else
		dDataSai := SDBDate(dDataSai,oModel:GetValue("PRAA804","ZZ1_HRSAID"))
	EndIf

    aResult := TCSPExec("proc_diu_viagem_ferroviaria",;
                          nOp,;
                          If(nOp == 3, cViagem, oModel:GetValue("PRAA804","ZZ1_VIAGEM")),;
                          Val(AllTrim(oModel:GetValue("PRAA804","ZZ1_OPFERR"))),;
                          Val(AllTrim(oModel:GetValue("PRAA804","ZZ1_TRFERR"))),;
                          oModel:GetValue("PRAA804","ZZ1_TIPO"),;
                          Val(AllTrim(oModel:GetValue("PRAA804","ZZ1_OPER"))),;
                          Val(AllTrim(oModel:GetValue("PRAA804","ZZ1_RECORI"))),;
                          Val(AllTrim(oModel:GetValue("PRAA804","ZZ1_RECDES"))),;
                          dDataCheg,;
                          dDataSai,;
                          oModel:GetValue("PRAA804","ZZ1_VAGCHE"),;
                          oModel:GetValue("PRAA804","ZZ1_VAGVAZ"),;
                          oModel:GetValue("PRAA804","ZZ1_SIT"),;
                          If(cEmpPai==SGetTerm() .And. nOp==4,"",cEmpPai),;
                          'c' + alltrim(SCodUsr()))
                        	      
	IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
		cErro := AllTrim(TCSQLError())
		oModel:SetErrorMessage('PRAA804',,,,,cErro )
		Return .F.
	elseIF !empty(aResult) .And. AllTrim(aResult[1]) <> ''
		cErro := "Ocorreu um erro no processo de gravação da viagem ferrorviaria"+Chr(13)+AllTrim(aResult[1])
		oModel:SetErrorMessage('PRAA804',,,,,cErro )
		Return .F.
	EndIF
	
	cSit := oModel:GetValue("PRAA804","ZZ1_SIT") 
	A804Atualizar()
	
	dbSelectArea(cAliasZZ1)
	RecLock(cAliasZZ1,.F.)
	
	Do Case
		Case cSit == 'L'
			(cAliasZZ1)->ZZ1_DSIT := "Liberada"
		Case cSit == 'C'
			(cAliasZZ1)->ZZ1_DSIT := "Cancelada"
		Case cSit == 'E'
			(cAliasZZ1)->ZZ1_DSIT := "Em operação"
		Case cSit == 'F'
			(cAliasZZ1)->ZZ1_DSIT := "Finalizada"
		OtherWise
			(cAliasZZ1)->ZZ1_DSIT := "Registrada"
	EndCase
	MsUnLock(cAliasZZ1)	
	
Return .T.

//Realiza a validação antes da ativação do modelo de dados
Function A804ACTIVE(oModel)
	Local lRet := .T.
	Local nOp := oModel:getoperation()
	Local cQuery := ""
	Local cAliasTmp := GetNextAlias()
	Local nRec
	Local cViagem := (cAliasZZ1)->ZZ1_VIAGEM
	//Garante que está alterando a informação mais nova antes da ativação do modelo de dados
	If nOp != MODEL_OPERATION_INSERT
		nRec := (cAliasZZ1)->(RecNo())
		CarregaDados()
		(cAliasZZ1)->(dbGoTo(nRec))
		If (cAliasZZ1)->ZZ1_VIAGEM <> cViagem
			Help(,,'HELP',,'O registro foi excluído por outro processo.',1,0)
		EndIf
	EndIf
	
	If nOp <> MODEL_OPERATION_INSERT
		if ((cAliasZZ1)->ZZ1_SIT <> 'R') .and. (A802GetcEmpPai() <> SGetTerm())
			lRet := .F.
			Help(,,'HELP',,'Usuário não permitido para efetuar a alteração de uma viagem liberada.',1,0)
			return lRet
		endif

		cQuery := " select convert(varchar(50),vf_dt_liberacao) dat_lib,convert(varchar(50),vf_dt_cancelamento) dat_can from tab_viagem_ferroviaria where vf_id = '" + (cAliasZZ1)->ZZ1_VIAGEM + "'"
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasTmp, .F., .T.)
		if alltrim((cAliasTmp)->dat_lib) <> '' .AND. alltrim(A802GetcEmpPai()) <> SGetTerm()
			lRet := .F.
			Help(,,'HELP',,'Não é possível alterar a agenda após a programação ter sido liberada.',1,0)
		endif
		if alltrim((cAliasTmp)->dat_can) <> '' .AND. alltrim(A802GetcEmpPai()) <> SGetTerm()
			lRet := .F.
			Help(,,'HELP',,'Não é possível alterar a agenda após a programação ter sido cancelada.',1,0)
		endif
		(cAliasTmp)->(dbCloseArea())
	endif
	
Return lRet

// Libera/estorna a Viagem. Usuário deve ser terminal
Function A804LibViagem()
	Local aRet
	If alltrim(cEmpPai) = SGetTerm()
		aRet := PRAA804A((cAliasZZ1)->ZZ1_VIAGEM)
		If aRet[1]
			RecLock(cAliasZZ1,.F.)
			(cAliasZZ1)->ZZ1_DTLIB := aRet[2]
			if AllTrim(aRet[4]) != ''
				(cAliasZZ1)->ZZ1_SIT := aRet[4]
				
				If aRet[4] == 'L'
					(cAliasZZ1)->ZZ1_DSIT := 'Liberada'
				ElseIf aRet[4] == 'E'
					(cAliasZZ1)->ZZ1_DSIT := 'Em operação'
				ElseIf aRet[4] == 'C'
					(cAliasZZ1)->ZZ1_DSIT := 'Cancelada'
				ElseIf aRet[4] == 'F'
					(cAliasZZ1)->ZZ1_DSIT := 'Finalizada'
				Else
					(cAliasZZ1)->ZZ1_DSIT := 'Registrada'
				endif

			endif
			MsUnLock(cAliasZZ1)
		EndIf
	Else
		Alert('Usuário sem permissão.')
	EndIf
Return

//Cancela/estorna o cancelamento da viagem. Não deve possuir agendamento relacionado, usuário deve ser terminal
Function A804CanViagem()
	Local cAlias := GetNextAlias()
	Local cAlias2 := GetNextAlias()
	Local cQuery := ''

    If alltrim(cEmpPai) == SGetTerm()
		cQuery := " SELECT vf_id FROM TAB_programacao WHERE vf_id = '" + (cAliasZZ1)->ZZ1_VIAGEM + "'"
		
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
       If AllTrim((cAlias)->vf_id) == ''
			cQuery := " SELECT CONVERT(VARCHAR, vf_dt_cancelamento ,103) as dat_can, CONVERT(VARCHAR, vf_dt_liberacao ,103) as dat_lib FROM TAB_viagem_ferroviaria WHERE vf_id = '" + (cAliasZZ1)->ZZ1_VIAGEM + "'"
			dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias2, .F., .T.)
         	 
			If alltrim((cAlias2)->dat_can) <> ''
				If MSGYESNO('Deseja estornar o cancelamento da programação?')
					RecLock(cAliasZZ1,.F.)
					
					If alltrim((cAlias2)->dat_lib) <> ''
						TCSQLExec(" update TAB_viagem_ferroviaria set vf_dt_cancelamento = null, vf_situacao = 'L' WHERE vf_id = '" + (cAliasZZ1)->ZZ1_VIAGEM + "'")
						(cAliasZZ1)->ZZ1_SIT = 'L'
						(cAliasZZ1)->ZZ1_DSIT = 'Liberada'
					else
						TCSQLExec(" update TAB_viagem_ferroviaria set vf_dt_cancelamento = null, vf_situacao = 'R' WHERE vf_id = '" + (cAliasZZ1)->ZZ1_VIAGEM + "'")
						(cAliasZZ1)->ZZ1_SIT = 'R'
						(cAliasZZ1)->ZZ1_DSIT = 'Registrada'
					endif	
					
					(cAliasZZ1)->ZZ1_DTCAN := STOD("        ")					
					MsUnLock(cAliasZZ1)
				EndIf
			ElseIf !Empty((cAliasZZ1)->ZZ1_VIAGEM)
				If MSGYESNO('Deseja cancelar a viagem?')
					TCSQLExec(" update TAB_viagem_ferroviaria set vf_situacao = 'C', vf_dt_cancelamento = '" + SDBDate(DDATABASE,time())+ "' WHERE vf_id = '" + (cAliasZZ1)->ZZ1_VIAGEM + "'")
					RecLock(cAliasZZ1,.F.)
					(cAliasZZ1)->ZZ1_DTCAN := DDATABASE
					(cAliasZZ1)->ZZ1_SIT = 'C'
					(cAliasZZ1)->ZZ1_DSIT = 'Cancelada'
					MsUnLock(cAliasZZ1)            		
				EndIf
			EndIf
		Else
			Alert('Operação não permitida. A viagem possui uma programação relacionada')
		EndIf
		(cAlias2)->(dbCloseArea())
		(cAlias)->(dbCloseArea())
	Else
		Alert('Usuário sem permissão.')
	EndIf
    
Return

//Fecha caso o parâmetro do pergunte não atender a situação
Function A804ViewClose(oModel)
	Local lRet := .F.
	Local cViagem := oModel:GetValue("PRAA804","ZZ1_VIAGEM")
	Local nRec
	Local nOp := oModel:GetOperation()

	Pergunte('PRAA804',.F.)

	If nOp == MODEL_OPERATION_UPDATE
		If MV_PAR01 == 1 .And. oModel:GetValue("PRAA804","ZZ1_SIT") $ "EF"
			lRet := .T.
		EndIf
	EndIf
	//Caso o registro não existir mais
	If nOp != MODEL_OPERATION_INSERT
		nRec := (cAliasZZ1)->(RecNo())
		CarregaDados()
		(cAliasZZ1)->(dbGoTo(nRec))
		If (cAliasZZ1)->ZZ1_VIAGEM <> cViagem
			(cAliasZZ1)->(dbGoTop())
			lRet := .T.
		EndIf
	EndIf
Return lRet

//Abre a visualização de uma viagem
Function A804VISVIAGEM(cViagem)
	Private aCamposZZ1 	:= {}
	Private cAliasZZ1  	:= GetNextAlias()
	Private cFiltroSql 	:= " a.vf_id = '" + cViagem + "'"
	CarregaDados(.T.)
	(cAliasZZ1)->(dbGotop())
	If !(cAliasZZ1)->(Eof()) .And. !Empty((cAliasZZ1)->ZZ1_VIAGEM)
		FWExecView("Visualizar", "PRAA804", 1)
	Else
		MsgInfo("A viagem não foi localizada")
	EndIf
	delTabTmp(cAliasZZ1)
Return

//Atualiza as informações do Grid
Function A804Atualizar()
	If Type("cAliasZZ1") != "C"
		Return
	EndIf
	Pergunte('PRAA804',.F.)
	cFiltroSql := ""
	CarregaPar()
	CarregaDados()
	(cAliasZZ1)->(dbGoTop())
Return

Static Function CarregaPar()
    Local cAbre  := ''
    Local cFecha := ''
	If MV_PAR01 == 1
		cFiltroSql+= " a.vf_situacao in ('R','L','E') "
	EndIf
	
	If !Empty(mv_par02) .And. !Empty(mv_par03)
	    cAbre  := '('
	    cFecha := ')'
	EndIf
	
	If !Empty(mv_par02)
		If !Empty(cFiltroSql)
			cFiltroSql+= " AND "
		EndIf
		cFiltroSql+= cAbre+"( a.vf_dt_prev_chegada  between '" + alltrim(SDBDate(mv_par02,'00:00:00.000')) + "' AND '" + alltrim(SDBDate(mv_par03,'23:59:59.999')) + "') "
	endif
	
	If !Empty(mv_par03)
		If !Empty(cFiltroSql)
			cFiltroSql+= " OR "
		EndIf
		cFiltroSql+= " ( a.vf_dt_prev_saida  between '" + alltrim(SDBDate(mv_par02,'00:00:00.000')) + "' AND '" + alltrim(SDBDate(mv_par03,'23:59:59.999')) + "') "+cFecha
	endif
Return

Function A804VALEXEC(cOp,nOp)
    Local cTtitulo := "Incluir"
    
    If nOp == 4
        cTtitulo := "Alterar"
    EndIf
    
	If IsInCallStack("EXECUTEMDEF")//Verifica se a chamada é pelo menu principal
//		MsgStop("Execute esta ação pelo menu príncipal.")
		lKill := .T.
//		Return
	EndIf
	If "VIEWDEF." $ cOp
			FwExecView(cTtitulo,"PRAA804",nOp)
	Else
		//Macrosubstituição
		&(cOp)
	EndIf
Return

Function PRAA804ValidaCPFCNPJ(CPFCNPJ)
   Local uRet := .F.
   Local reg := PRAA802VerificaCli(CPFCNPJ)
   
   if (CGC(CPFCNPJ,,.F.) == .F.)
       MsgStop("O CPF ou CNPJ informado é inválido.", "Aviso")
	   uRet := .F.
   else 
       //verifica se não esta no sistema
       if(reg <> '') .and. (reg <> Nil)
          MsgStop("O CNPJ já existe.", "Aviso")
	      uRet := .F.
       else 
          uRet := .T.
       endif
   endif
   
return uRet

Function PRAA804TipoCli(CPFCNPJ)
      Local cAlias  := SGetNAlias()
      Local cQuery  := "select tcli_id from rel_tipo_cliente where cli_id = (select cli_id from tab_clientes where cli_cgc = '"+CPFCNPJ+"' or cli_cpf = '"+CPFCNPJ+"')"
      Local uRet    := nil

      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
      if (cAlias)->(!EOF())
            uRet := (cAlias)->(FieldGet(1))
      endif
      (cAlias)->(dbCloseArea())

return uRet

/*/{Protheus.doc} A804Param
//TODO Descrição auto-gerada.
Objetivo desta rotina é validar os filtros de acordo com aquilo que o usuario parametriza e, lembrando
que as validações são feitas se o campo pendentes for do tipo não e, caso contrario o sistema não obriga
as datas e so considera o campo "Somente viagens abertas?". O parametro lAtualiza determina se o filtro
ou o recarregamento da tela deve ser executado ou não.
@author 
@since 19/03/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function A804Param(lAtualiza)
    Local lPerg := .F.
    Default lAtualiza := .T.
    
    lRetPAR := .T.
    
    cFiltroSql := ""
    
    //se os parametros que recebe o valor da data tiver preenchido limpa os valores para receber novamente o valor informado
    If(!Empty(MV_PAR02))
         MV_PAR02 := "" 
    EndIf
    
    If(!Empty(MV_PAR03))
         MV_PAR03 := "" 
    EndIf
    
    lPerg := Pergunte("PRAA804",.T., "Filtro da Viagem")
	
	If !(lPerg) //Se usuario clicar em cancelar.
	    lRetPAR := .F.
	    Return .F. 
	ElseIf (MV_PAR01 == 2) 
		If Empty(MV_PAR02)
			alert('O período inicial precisa ser preenchido.')
			lRetPAR := .F.
		ElseIf Empty(MV_PAR03)
			alert('O período final precisa ser preenchido.')
			lRetPAR := .F.
		Else 
		    If(A804ValData(MV_PAR02,MV_PAR03))
		        alert('O período inicial não pode ser superior ao período final.')
			    lRetPAR := .F.
		    EndIf
		EndIf 
	ElseIf (MV_PAR01 == 1)  
	    If (A804ValData(MV_PAR02,MV_PAR03))
	        alert('O período inicial não pode ser superior ao período final.')
		    lRetPAR := .F.
		Else 
		    lRetPAR := .T. 
	    EndIf
	Else
	    lRetPAR := .T. 
	EndIf
	
	If !lRetPAR //se alguma informação obrigatória não for preenchida no pergunte. Abre novamente a tela do pergunte
	    A804Param(.F.)
	ElseIf(lAtualiza) .And. lRetPAR //Se o usario clicar no menu para atualizar grid e todos os campos foram preenchidos
       A804Atualizar()
    Else 
       lRetPAR := .T.
    EndIf
    
Return lRetPAR

/*/{Protheus.doc} A804ValData
//TODO Descrição auto-gerada.
Objetivo desta função é comparar as duas datas e retorna boolean (True = Data ini é maior que data fim )
@author Mohamed S B Djalo
@since 21/03/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Function A804ValData(dDtINI, dDtFIM)
    Local lRet := .F.
    Local dia1 := Day(dDtINI)
    Local mes1 := Month(dDtINI)
    Local ano1 := Year(dDtINI)
    Local dia2 := Day(dDtFIM)
    Local mes2 := Month(dDtFIM)
    Local ano2 := Year(dDtFIM)
    
    If (ano1 > ano2)
        lRet := .T.
    ElseIf(ano1 == ano2)
        If(mes1 > mes2)
        	lRet := .T.
        ElseIf(mes1 == mes2)
           If (dia1 > dia2)
              lRet := .T.
           EndIf
        EndIf
    EndIf
Return lRet








