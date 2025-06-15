#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PRAA802.CH"
#INCLUDE 'DBINFO.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"


//-----------------------------------
/*/{Protheus.doc} praalllatinge802
Programação de Veiculos

@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Programação de Veículos Rodoviários, Aéreos e Ferroviários
/*/
//-----------------------------------

#define INFO_ZOOM_TIPO_EXECUCAO_SQL   1
#define INFO_ZOOM_TIPO_EXECUCAO_ARRAY 2
#define INFO_ZOOM_OBJETO 2
#define VEICULO_BLOQUEADO_MSG "Veículo bloqueado para: Entrada/Saída " 

static cDescModal := ''
static cModal := ''
static scEmpPai := ''
static cDocArray := {}
static teste := {'','1','2','3'}
static a_TPO_ES := {'E=ENTRADA','S=SAIDA'}
Static aDocId
Static lTemDepot := .F.


//Query Principal
static cQueryP := ''

static cG_dc_id := ''
static cG_Data :=  '  /  /    '
static cG_data2 := '  /  /    '
static cG_paj_id := ''
static cG_pa_id := ''
static cG_Resul_Agen := ''
static cG_dt_a_ini := ''
static cG_hr_a_ini := ''
static cG_dt_a_fim := ''
static cG_hr_a_fim := ''
static cG_pa_bloqueado := ''
static chamouConsulta := .F.
static triggerErro := .F.
Static cSubOpCntCheio  := ''
Static cSubOpCntVazio  := ''
Static cSubOpMercSolta := ''

Static cGRUID
Static cCLIID
Static cPCMID
Static cPUCID
Static cPCID
Static cPAIID

//---------------------------------
/*/{Protheus.doc} PRAA802
Função PRAA802 apresenta a tabela com o Browse na tela.
É a primeria função  chamada pelo programa.
@author Fernando da Cruz Pinheiro
@version P11
@since 02/01/2014
/*/
//---------------------------------
Function PRAA802()
   Local aCols := {}
   Local aSeek := {}
   Local lParametros := .F.
   Local aFieFilter := {}
   Local oDlg         := nil
   Local aCoors       := FWGetDialogSize(oMainWnd)

   Private oBrowse := nil
   Private userInf := {}

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

   Private cTipomodal := ""
   Private lTemDepot  := .F.
   Private cTipoPessoa := ""
   Private cNomPes := ""
   Private cNmPes2 := ""
   Private cCodPes := ""
   Private cCdPes2 := ""
   Private cCadPes := ""
   Private cUsuario := ""

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
   Private cVigTrCgc := ""

   Private cRetLkSara := ''
   Private acessoUser := {}

   //variaveis para a funcao da aline
   Private lAbreTela := .F.
   Private nIndex    := nil
   Private cVarAdm   := ''
   Private cVarEmp   := ''
   Private cDescAdm  := ''
   Private cDescEmp  := ''
   Private aRet      := ''
   Private cEmpPai   := ''

   Private cAliasTb   := SGetNAlias()
   Private nColSize   := 0
   Private aStructDesc
   Private aStruct
   Private lKill := .F.
   
   DEFINE MSDIALOG oDlg PIXEL FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4]

	   cUsuario := RET_USER()

	   if cUsuario == ""
	      MsgStop(STR0093+Chr(13)+STR0094)
	      Return .F.
	   EndIF

	   userInf := A802VACES()

	   if sempty(userInf)
	   		alert('Usuário sem permissão de acesso!')
	   		return .F.
	   endif

		A802SELEMP()

		if (lAbreTela = .F.) .or. (alltrim(cEmpPai) =  '')
			return .F.
		endif

		// verifica se os paraemtros UTILIZA_SUB_OPERACAO_CESV  e UTILIZA_AGENDAMENTO_WEB estao cadastrado e configurado para 'S'
		lParametros := A802VALPAR()

		if lParametros = .F.
			return .F.
		endif

	    If Pergunte('PRAA802',.T.,'Filtro do agendamento')

	   	   if mv_par04 = 2 .and. ( (alltrim(dtoc(mv_par02)) = '/  /') .or. (alltrim(dtoc(mv_par03)) = '/  /') )
	   	   		if alltrim(dtoc(mv_par02)) = '/  /'
	   	   			alert('O período inicial de cadastro precisa ser preenchido.')
	   	   			if ! Pergunte('PRAA802',.T.,'Filtro do agendamento')
	   	   				return .T.
	   	   			endif
	   	   		elseif alltrim(dtoc(mv_par03)) = '/  /'
	   	   			alert('O período final de cadastro precisa ser preenchido.')
	   	   			if ! Pergunte('PRAA802',.T.,'Filtro do agendamento')
	   	   				return .T.
	   	   			endif
	   	   		endif
	   	   endif
	   	   A802CARPAR()
	   	   If MV_PAR01 == 2 .And. !Empty(MV_PAR05) .And. !A802VALVIG(MV_PAR05,'F', .F.)
   	   			if ! Pergunte('PRAA802',.T.,'Filtro do agendamento')
   	   				Return .T.
   	   			EndIf
   	   			A802CARPAR()
   	   	   EndIf
   	   		
	   //Cria tabelas temporárias
	   A802CRI_TABTMP()

      //Carrega os dados das tebelas temporárias
      CAR_TABTMP(.T.)

      //Colunas da Grid        TMP_HR_PRE
      Aadd(aCols,{STR0265,"TMP_STR_PG","C" ,0,0,})
      Aadd(aCols,{STR0013,"TMP_EVE_DS","C" ,0,0,})
      Aadd(aCols,{STR0007,"TMP_DT_ENT" ,"D" ,0,0,})
      //Aadd(aCols,{STR0008,"TMP_HR_ENT","C" ,0,0,})
      Aadd(aCols,{STR0008,"TMP_HR_PRE","C" ,5,0,})
      Aadd(aCols,{STR0034,"TMP_OPE_DS","C" ,12,0,})
      Aadd(aCols,{STR0159,"TMP_SUB_DS","C" ,15,0,})
      Aadd(aCols,{STR0243,"TMP_QUANT","C" ,0,0,})
      If cTipoModal != "F"
      	Aadd(aCols,{STR0002,"TMP_VEI_ID","C" ,0,0,})
      Else
      	Aadd(aCols,{"Viagem ferr.","TMP_VIAGEM","C" ,5,0,})
      	Aadd(aCols,{"Vagão","TMP_VEI_ID","C" ,8,0,})
      EndIf
      Aadd(aCols,{STR0244,"TMP_ORI_DS","C",0,0,})
      If cTipoModal == "F"
      		Aadd(aCols,{"Operador","TMP_VIGOPE","C" ,0,0,})
      EndIf
      Aadd(aCols,{STR0174,"TMP_TRA_DS","C" ,0,0,})
      Aadd(aCols,{cTipoPessoa,"TMP_PES_DS","C" ,12,0,})
      Aadd(aCols,{STR0236 ,"TMP_CES_ID","C" ,10,0,})
	  Aadd(aCols,{STR0245,"TMP_CRE_DS","C",0,0,})
	  Aadd(aCols,{'Qtd. de documento',"TMP_TO_DOC","C",0,0,})
	  Aadd(aCols,{'Qtd. de container',"TMP_TO_CNT","C",0,0,})
	  Aadd(aCols,{'Dt. cancelamento',"TMP_DT_CAN","C",20,0,})

      Aadd(aSeek,{STR0238, {{"","C",10,0, "TMP_STR_PG",""}}, 1, .T. } )
      Aadd(aSeek,{STR0002 , {{"","C",10,0, "TMP_VEI_ID",}} , 2, .T. } )
      Aadd(aSeek,{STR0284 , {{"","C",10,0, "DTOS(TMP_DT_ENT) + TMP_HR_ENT",}} , 3, .T. } )

      Aadd(aFieFilter,{'TMP_EVE_ID', STR0002,'C', 10, 0})

      oBrowse := FWMBrowse():New(oDlg)
      oBrowse:setowner(oDlg)
      oBrowse:SetAlias(cAliasTMP)
      oBrowse:SetTemporary(.T.)
      oBrowse:SetSeek(.T.,aSeek)
      oBrowse:setFieldFilter(aFieFilter)
      oBrowse:SetMenuDef('PRAA802')

      oBrowse:SetUseFilter()
	   oBrowse:SetLocate()

      oBrowse:SetFields(aCols)

      if cTipomodal == 'V'
         oBrowse:SetDescription(STR0076)
      EndIF
      if cTipomodal == 'F'
         oBrowse:SetDescription(STR0077)
      EndIF
      if cTipomodal == 'A'
         oBrowse:SetDescription(STR0078)
      EndIF

      LEG_EVENTO()

    oBrowse:SetDBFFilter(.T.)

    oBrowse:ForceQuitButton()
    oBrowse:DisableDetails()

	oBrowse:Activate()
	If !lKill
		oBrowse:FWFilter():DisableSave(.T.)
		oBrowse:FWFilter():DisableDel(.T.)
		oBrowse:FWFilter():DisableSave(.T.)
		oBrowse:FWFilter():DisableAdd(.T.)

		oBrowse:oFWFilter:SetExecute({||C905FILTER(oBrowse)})

		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf

      delTabTmp(cAliasTMP)
      delTabTmp(cAliTMPEve)
      delTabTmp(cAliTMPReb)
      delTabTmp(cAliTMPDoc)
      delTabTmp(cAliTMPAne)
      delTabTmp(cAliTMPP)
      delTabTmp(cAliTMPITCAR)
      delTabTmp(cAliTMPITDES)
      dbClearAll()

      endif
Return .T.


Function C905FILTER(oBrowse)
	Local i := 0
    Local oFilter     := oBrowse:FWFilter()
    Local aFilter     := nil
    local cFilter := ''
	local aAliasTMP := ''

    aFilter := oFilter:GetFilter(.T.)

	for i := 1 to len(aFilter)
    	if i = 1
			cFilter +=  aFilter[i][2]
		else
			cFilter += ' .or. ' + aFilter[i][2]
		endif
	next
	
	if type('cAliasZZ1')=='U'
	   aAliasTMP:=cAliasTMP	   
	else
	   aAliasTMP:=cAliasZZ1    	
	endif	
    
    if AllTrim(cFilter) = ""
    	(aAliasTMP)->(DBClearFilter())
	else
    	(aAliasTMP)->(DbSetFilter({||&cFilter},cFilter) )
    	(aAliasTMP)->(DbGoTop())
	endif     

	oBrowse:refresh()

return .T.

//-----------------------------------
/*/{Protheus.doc} A802SELEMP
Função dos clientes que o usuário vai adminisrar
@author Fernando da cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Tratamento realizados no post do Model da tabela de documentos
/*/
//-----------------------------------

Function A802SELEMP()
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
       cQuery += " where a.usu_id = 'c"+SCodUsr()+"' and g.mnu_id = 'A'"

       cQuery := ChangeQuery(cQuery)

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
             MsgAlert(STR0144)
             lAbreTela := .F.
             Return
       Endif

    If nCount == 1
       cEmpPai := aEmpresas[1,1]
       scEmpPai := aEmpresas[1,1]
       _cEmpPai := cEmpPai
       cVarEmp := aEmpresas[1,1]
       cDescEmp:=  aEmpresasDesc[1]
       lAbreTela := .T.
       Return
    Endif

       DEFINE MSDIALOG oDlgEmp TITLE STR0145 FROM 0,0 TO 200,200 PIXEL

       oPanelB:= TPanel():Create(oDlgEmp,01,01,"",,,,,,10,15)
       oPanelB:Align := 4 //CONTROL_ALIGN_BOTTOM

       oPanelAllClient  := TPanel():Create(oDlgEmp,01,102,"",,,,,,100,100)
       oPanelAllClient:Align := 5 //CONTROL_ALIGN_ALLCLIENT

       oListEmp:= TListBox():New(10,10,{|u|If(Pcount()>0,nList:=u,nList)} ,aEmpresasDesc,100,100,,oPanelAllClient,,,,.T.,,{||A802SETEMP()})
       oListEmp:Select(1)
       oListEmp:Align := 5 //CONTROL_ALIGN_ALLCLIENT

       oTButtonAbrir := TButton():New( 01,01,STR0146,oPanelB,{||A802SETEMP()},40,10,,,,.T.,,,,,,)
       oTButtonSair  := TButton():New( 01,42,STR0147,oPanelB,{||A802CANEMP()},40,10,,,,.T.,,,,,,)

       ACTIVATE MSDIALOG oDlgEmp CENTERED

Return


//---------------------------------
/*/{Protheus.doc} A802CANEMP
Função A802CANEMP cancela a seleção dos clientes.
@author Fernando da Cruz Pinheiro
@version P11
@since 02/01/2014
/*/
//---------------------------------
static function A802CANEMP()
	lAbreTela := .F.
	oDlgEmp:End()
return

//---------------------------------
/*/{Protheus.doc} A802SETEMP
Função A802SETEMP seleciona 1 cliente para criar a programação
@author Fernando da Cruz Pinheiro
@version P11
@since 02/01/2014
/*/
//---------------------------------
Static Function A802SETEMP()
	local nIndex

        nIndex := oListEmp:GetPos()
        cEmpPai := aEmpresas[nIndex,1] 
        scEmpPai := aEmpresas[nIndex,1] 
        _cEmpPai := aEmpresas[nIndex,1]
        cVarEmp := aEmpresas[nIndex,1]
        cDescEmp := aEmpresasDesc[nIndex]
        lAbreTela := .T.
        oDlgEmp:End()
return

Function A802GetcEmpPai()
    Local cAux := scEmpPai
	if ((cAux == '') .Or. (cAux == Nil) .Or. Empty(cAux))
  		cAux := cEmpPai
	endif  
    scEmpPai := ''
Return cAux

//---------------------------------
/*/{Protheus.doc} A802VALPAR
Função A802VALPAR verifica se os parametros  no banco de dados esta cadastrado.
@author Fernando da Cruz Pinheiro
@version P11
@since 02/01/2014
/*/
//---------------------------------
static function A802VALPAR() 
	local cQuery := ''
	Local cAlias := GetNextAlias()
	Local cAlias2 := GetNextAlias()

	cQuery := " select param_id, param_valor from tab_parametro where param_desc = 'UTILIZA_SUB_OPERACAO_CESV' "
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)

	if alltrim((cAlias)->param_id) <> ''
		if alltrim((cAlias)->param_valor) <> 'S'
			Msgstop(STR0148)
			return .F.
		endif
	else
		Msgstop(STR0149)
		return .F.
	endif

    cQuery := "select param_id, param_valor from tab_parametro where param_desc = 'UTILIZA_AGENDAMENTO_WEB'"
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias2,.F.,.T.)

	if alltrim((cAlias2)->param_id) <> ''
		if alltrim((cAlias2)->param_valor) <> 'S'
			Msgstop(STR0150)
			return .F.
		endif
	else
		Msgstop(STR0151)
		return .F.
	endif

return .T.

//---------------------------------
/*/{Protheus.doc} A802VACES
Função A802VACES verifica se o usuario tem acesso para fazer agendamento das programações.
@author Fernando da Cruz Pinheiro
@version P11
@since 02/01/2014
/*/
//---------------------------------
function A802VACES()
	local cQuery := ''
	Local cAlias := GetNextAlias()

	cQuery :=  " select cli_id_principal, mnu_id, mod_id, usu_id, cli_id_acesso_info from vw_portal_permissao_acesso where usu_id = 'c" + StrTran(SCodUsr(),'ECPF','',1,1) + "' and mnu_id = 'A'"


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




/*
function A802LIB()
	Local  cAliasCAN := GetNextAlias()
	Local  cAlias := GetNextAlias()
	Local  cAlias2 := GetNextAlias()
	Local regAtual := 0
	Private lCancelou := .F.
	Private cProg_ID := STransType((cAliasTMP)->TMP_PRG_ID,'C')

	if alltrim(cEmpPai) = '999999'
		 cQuery := " SELECT convert(varchar(50),dt_liberacao) as dt_liberacao FROM TAB_programacao WHERE prog_id = " + cProg_ID
	    dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias2, .F., .T.)
	    IF AllTrim((cAlias2)->dt_liberacao) = ''
			cQuery := " SELECT cesv_id FROM TAB_programacao WHERE prog_id = " + cProg_ID
		    dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
		    IF AllTrim((cAlias)->cesv_id) = ''
		    	regAtual := oBrowse:at()
		    	PRAC809()
		    	if lCancelou = .T.
		    		return
		    	endif
				CAR_TABTMP()
				oBrowse:refresh()
			else
				alert(STR0235)
			endif
			oBrowse:goto(regAtual, .T.)
		else
			alert(STR0246)
		endif
	else
			alert(STR0140)
	end
return
*/

function A802LIB()
	Local  cAlias2 := GetNextAlias()
	Local regAtual := 0
	Private lCancelou := .F.
	Private cProg_ID := STransType((cAliasTMP)->TMP_PRG_ID,'C')
	Private cViag_id := (cAliasTMP)->TMP_VIAGEM
	
	if !VAL0006ValidaProgramacaoCancelada((cAliasTMP)->TMP_PRG_ID)
	   	Help(,,'HELP',,'A programação encontra-se cancelada e não pode ser Liberada/Estornada.',1,0)		
		return .F.	
	endif	

	if alltrim(cEmpPai) = SGetTerm()
		cQuery := " SELECT convert(varchar(50),dt_liberacao) as dt_liberacao FROM TAB_programacao WHERE prog_id = " + cProg_ID
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias2, .F., .T.)

		regAtual := oBrowse:at()
		PRAC809()
		CAR_TABTMP(.T.)
		oBrowse:refresh()
		oBrowse:goto(regAtual, .T.)
	else
		alert(STR0140)
	end
return 

function A802EV()
	local cProg_ID := STransType((cAliasTMP)->TMP_PRG_ID,'C')
	local cModal_ID := cTipomodal
	local cModal_DS := cDescModal
	local cOp_DS := STransType((cAliasTMP)->TMP_OPE_DS,'C')
	local cSub_DS := STransType((cAliasTMP)->TMP_SUB_DS,'C')
	local l_Val := .T.
	Local regAtual := 0
	Local lResult := .F.
	Private lCancelou := .F.
	
	if !VAL0006ValidaProgramacaoCancelada((cAliasTMP)->TMP_PRG_ID)
	   	Help(,,'HELP',,'A programação encontra-se cancelada e não pode ter os eventos alterados.',1,0)		
		return .F.	
	endif	

   if alltrim(cEmpPai) = SGetTerm()
		regAtual := oBrowse:at()
		lResult := PRAA803(cProg_ID, cModal_ID, cModal_DS, cOp_DS, cSub_DS, l_Val)

		if lCancelou = .T.
			return
		endif

		If lResult
			MsgInfo("O evento foi alterado com sucesso.")
		EndIf

		CAR_TABTMP(.T.)
		oBrowse:refresh()
		oBrowse:goto(regAtual, .T.)
	else
		alert(STR0140)
	endif
return



/*/{Protheus.doc} A802VERPEP
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs A funcao A802VERPEP verifica se é possivel alterar a programação conforme o valor do campo da tabela.
/*/

function A802VERPEP(oModel)
	Local lRet := .T.
	Local cQuery := ''
	Local cAlias := GetNextAlias()

	If oModel:GetOperation() != MODEL_OPERATION_INSERT
		CAR_TABTMP()
	EndIf
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE

		if ((cAliasTMP)->TMP_STATUS <> 0) .and. (cEmpPai <> SGetTerm())
			lRet := .F.
			Help(,,'HELP',,'Usuário não permitido para efetuar a alteração da programação.',1,0)
			return lRet
		endif

		if !VAL0006ValidaProgramacaoCancelada((cAliasTMP)->TMP_PRG_ID)
	   		Help(,,'HELP',,'Não é permitida alterar a programação pois está cancelada.',1,0)		
			lRet := .F.				 
		else			
			cQuery := " SELECT cesv_id FROM TAB_programacao WHERE prog_id = " + stranstype((cAliasTMP)->TMP_PRG_ID,'C')
	       dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
	       IF AllTrim((cAlias)->cesv_id) != ''
	            Help(,,'HELP',,STR0235,1,0)
	            lRet := .F.
	         endif
		endif
	EndIf

return lRet


/*/{Protheus.doc} ModelDef
ModelDef MVC
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Contrução do Modelo de Dados
/*/
Static Function ModelDef()
   Local oModel  	  := Nil
   Local oStrTABTMP := FWFormModelStruct():New()
   Local oStrTABREB := FWFormModelStruct():New()
   Local oStrTABDOC := FWFormModelStruct():New()
   Local oStrTABANE := FWFormModelStruct():New()
   Local oStrTABCNT := FWFormModelStruct():New()
   Local oStrTABITC := FWFormModelStruct():New()
   Local oStrTABITD := FWFormModelStruct():New()
   
   Default cTipomodal := ""

	/*****STRUCT*****/
   //TABELA PRINCIPAL
   oStrTABTMP:AddTable(cAliasTMP, {'TMP_PRG_ID'},STR0001)
   oStrTABTMP:AddIndex(1,'01','TMP_PRG_ID','Indice 1','','',.T.)

   oStrTABTMP:AddField(STR0001    ,STR0001   ,'TMP_PRG_ID'          ,'C'  ,10 ,0,Nil                    ,{||.T.}          ,Nil,.F.       ,,.T.,.T.,.F.)
   oStrTABTMP:AddField(STR0001    ,STR0001   ,'TMP_STR_PG'          ,'C'  ,10 ,0,Nil                    ,{||.T.}          ,Nil,.F.       ,,.T.,.T.,.F.)
   oStrTABTMP:AddField(STR0155    ,STR0155   ,'TMP_MODAL'           ,'C'  ,11 ,0,Nil                    ,{||.F.}          ,Nil,.F.       ,{||cDescModal},.T.,.T.,.F.)
   oStrTABTMP:AddField(STR0156    ,STR0156   ,'TMP_OPE_ID'          ,'C',10 ,0,{||VAL_OPERACAO()}     ,{||WHEN_LIBERA()},Nil,.T.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0157    ,STR0157   ,'TMP_OPE_DS'         ,'C',30 ,0,Nil              		     ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0158 	  ,STR0158   ,'TMP_SUB_ID'         ,'C',10 ,0,{||StaticCall(PRAA802,VAL_SUB_ID)}		 ,{||WHEN_LIBERA()},Nil,.T.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0159    ,STR0159   ,'TMP_SUB_DS'         ,'C',30 ,0,Nil               		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0160    ,STR0160   ,'TMP_QUANT'          ,'N',6 ,0,{||.T./*VAL_QUANT()*/}           ,{||WHEN_LIBERA()},Nil,.T.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0161    ,STR0161   ,'TMP_PJC_ID'         ,'N',5  ,0,Nil               		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0162    ,STR0162   ,'TMP_DC_ID'  		  ,'C',10 ,0,Nil  						 ,{||.T.}            ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0163    ,STR0163   ,'TMP_DC_D'           ,'C',50 ,0,Nil              		     ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0164    ,STR0164   ,'TMP_DT_INE'         ,'C',10 ,0,IIF(cTipoModal != 'F',{||VAL_DT_JAIN()},nil)       ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0165    ,STR0165   ,'TMP_DT_FIE'         ,'C',10 ,0,IIF(cTipoModal != 'F',{||VAL_DT_JANELA()},nil)     ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0166    ,STR0166   ,'TMP_DT_INI'          ,'D',10 ,0,Nil               	     ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0167    ,STR0167   ,'TMP_DT_FIM'          ,'C',50 ,0,Nil               		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0168    ,STR0168   ,'TMP_DT_AGE'          ,'C',50 ,0,Nil               		 ,{||.T.}          ,Nil,.T.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField('Data prevista','Data prevista','TMP_DT_PRE' ,'D',10,0,IIF(cTipoModal != 'F',{||VAL_DT_PRE()},nil),{||WHEN_LIBERA()}         ,Nil,.T.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0169    ,STR0169   ,'TMP_HR_PRE'          ,'C',5,0,IIF(cTipoModal != 'F',{||VAL_HR_PRE()},nil) ,{||WHEN_LIBERA()}         ,Nil,.T.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0170    ,STR0170   ,'TMP_PESO'            ,'N',13,2,Nil               		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0171    ,STR0171   ,'TMP_CUBICO'          ,'N',8,2,Nil               		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0172    ,STR0172   ,'TMP_VEI_ID'          ,'C',11,0,{||VAL_VEI_ID()}		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0173    ,STR0173   ,'TMP_TRA_ID'          ,'C',10 ,0,{||.T.}		 ,{||.T.},Nil,.F.       ,{||GetCodTr("trp")},.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0173    ,STR0173   ,'TMP_TRA_CG'          ,'C',21 ,0,{||VAL_TRA_ID()}		 ,{||WHEN_ALTER()},Nil,.F.       ,{||GetTrCgc()},.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0174    ,STR0174   ,'TMP_TRA_DS'         ,'C',50 ,0,Nil              			 ,{||.T.}          ,Nil,.F.       ,{||GetDsTr()},.F.,.F.,.F.)
   oStrTABTMP:AddField(cCodPes    ,cCodPes   ,'TMP_PES_ID'         ,'C',50 ,0,{||.T.}		 ,{||.T.},Nil,.F.       ,,.F.,.F.,.T.)
   oStrTABTMP:AddField(cCodPes    ,cCodPes   ,'TMP_PES_CG'         ,'C',21 ,0,{||VAL_PES_ID()}		 ,{||WHEN_ALTER()},Nil,.F.       ,,.F.,.F.,.T.)
   oStrTABTMP:AddField(cNomPes    ,cNomPes   ,'TMP_PES_DS'         ,'C',50 ,0,Nil              			 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0247    ,STR0247   ,'TMP_CRE_ID'		  ,'C',6 ,0, nil                         ,{||WHEN_ALTER()},Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0248	  ,STR0248   ,'TMP_CRE_DS'		  ,'C',50 ,0, nil                         ,{||WHEN_ALTER()},Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0238	  ,STR0238   ,'TMP_CLI_ID'		  ,'C',6 ,0,  {||.T.}       ,{||.t.},Nil,.T.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0238	  ,STR0238   ,'TMP_CLI_CG'		  ,'C',21 ,0,  {||VAL_CLIENTE('PRAA802')}       ,{||.t.},Nil,.T.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0244	  ,STR0244   ,'TMP_ORI_DS'		  ,'C',50 ,0,Nil              			 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0240	  ,STR0240   ,'TMP_CL_CGC'		  ,'C',20 ,0,Nil              			 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0176    ,STR0176   ,'TMP_EDIT_P'         ,'N',1 ,0,Nil             			 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0177    ,STR0177   ,'TMP_COD_M'          ,'C',1 ,0,Nil               			 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0178    ,STR0178   ,'TMP_PA_BLQ'         ,'C',1 ,0,Nil              			 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0179    ,STR0179   ,'TMP_EVE_ID'         ,'C',10 ,0,nil            			 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0180    ,STR0180   ,'TMP_EVE_DS'         ,'C',25 ,0,nil             			 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0015    ,STR0015   ,'TMP_DT_EVE'         ,'D',10 ,0,Nil              			 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0008    ,STR0008   ,'TMP_HR_EVE'         ,'C',5  ,0,Nil              		     ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0181    ,STR0181   ,'TMP_PA_ID'          ,'N',5  ,0,Nil              			 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0182    ,STR0182   ,'TMP_PAJ_ID'          ,'N',5  ,0,nil  					 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0183    ,STR0183   ,'TMP_AGDT_I'          ,'C',30  ,0,Nil              		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0184    ,STR0184   ,'TMP_AGHR_I'          ,'C',30  ,0,Nil              		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0185    ,STR0185   ,'TMP_AGDT_F'          ,'C',30  ,0,Nil              		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0186    ,STR0186   ,'TMP_AGHR_F'          ,'C',30  ,0,Nil              		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   //estes campos abaixo é só para mostrar no fwbrowse
   oStrTABTMP:AddField(STR0187    ,STR0187   ,'TMP_DT_ENT'          ,'D',10  ,0,Nil              		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0188    ,STR0188   ,'TMP_HR_ENT'          ,'C',5   ,0,Nil              		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0189    ,STR0189   ,'TMP_STATUS'         ,'N',1    ,0,Nil             		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField(STR0190    ,STR0190   ,'TMP_ATIVO'           ,'N',1   ,0,Nil               	 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField('Observação','Observação','TMP_OBSERV'      ,'M',255 ,0,Nil              		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABTMP:AddField("Viagem ferr.", "Viagem ferroviária", "TMP_VIAGEM", "C",  8, 0, {||A802VALVIG(FwFldGet("TMP_VIAGEM"),cTipomodal)/*bValid*/},{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/, /*{||GetCodViagem()}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)

   oStrTABTMP:AddField("Operador ferr.", "Operador ferroviária", "TMP_CLIFER", "C",  50, 0, nil/*bValid*/,{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/, {||GetDsOpFerr()},/*lkey*/,.F./*lNoUpd*/,/*lVirtual*/,/*cValid*/)
   oStrTABTMP:AddField("Operação ferr.", "Operação ferroviária", "TMP_OPFER" , "C",  30, 0, nil/*bValid*/,{||.T./*bWhen*/},/*aValues*/,.F./*LOBRIGAT*/, {||GetDsOpVg()},/*lkey*/,.F./*lNoUpd*/,/*lVirtual*/,/*cValid*/)

  //oStrTABTMP:AddField('Cliente da carga'    ,'Cliente da carga'   ,'TMP_CLI_ID'           ,'N',1   ,0,Nil               		 ,{||.T.}          ,Nil,.F.       ,,.F.,.F.,.F.)

   oStrTABTMP:AddTrigger('TMP_VIAGEM','TMP_TRA_ID',,{||A802ATUTR(FwFldGet("TMP_VIAGEM"),FwFldGet("TMP_TRA_ID"),"trp")})
   oStrTABTMP:AddTrigger('TMP_VIAGEM','TMP_TRA_CG',,{||A802ATUTR(FwFldGet("TMP_VIAGEM"),FwFldGet("TMP_TRA_ID"),"cli_cgc")})
   oStrTABTMP:AddTrigger('TMP_VIAGEM','TMP_TRA_DS',,{||A802ATUTR(FwFldGet("TMP_VIAGEM"),FwFldGet("TMP_TRA_ID"),"cli_nome")})
   oStrTABTMP:AddTrigger('TMP_VIAGEM','TMP_CLIFER',,{||A802ATUTR(FwFldGet("TMP_VIAGEM"),FwFldGet("TMP_TRA_ID"),"cli_Fer_nome")})
   oStrTABTMP:AddTrigger('TMP_VIAGEM','TMP_OPFER' ,,{||A802ATUTR(FwFldGet("TMP_VIAGEM"),FwFldGet("TMP_TRA_ID"),"cli_Oper_nome")})
   if cTipomodal != 'F'
	  oStrTABTMP:AddTrigger('TMP_DT_FIE','TMP_DT_INE',/*{||IIF(lConsultou = .T., .T.,.F.)}*/,{||A802ATU()})
   	  oStrTABTMP:AddTrigger('TMP_DT_FIE','TMP_DT_FIE',/*{||IIF(lConsultou = .T., .T.,.F.)}*/,{||A802ATU2()})
   endif

   //FWMemoVirtual( oStrTABTMP, { { 'TMP_OBSERV' ,alltrim((cAliTABPRO)->observacao), cAliasTMP } , { 'ZA0_CDSYP2' ,'ZA0_MMSYP2' , 'ZZ1'} } )

   //CONTAINER
   oStrTABCNT:AddTable(cAliTMPP, {'CNT_PRG_ID+CNT_PCNT_I'},"Container")
   oStrTABCNT:AddIndex(1,'01',  'CNT_PRG_ID+CNT_PCNT_I','index 1','','',.T.)
   oStrTABCNT:AddField(STR0191   ,STR0191    ,'CNT_PRG_ID'     ,'C',10,0    ,Nil             ,{||.T.}                ,Nil,.F.       ,,.T.,.T.,.F.)
   oStrTABCNT:AddField(STR0192   ,STR0192    ,'CNT_PCNT_I'     ,'C',10,0    ,Nil             ,{||.T.}                ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABCNT:AddField(STR0193   ,STR0193    ,'CNT_CNT_ID'     ,'C',11,0    ,{||VAL_CNT()}  ,{||PRAA802CNT()}                 ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABCNT:AddField(STR0194   ,STR0194    ,'CNT_TIS_TA'     ,'C',2,0     ,Nil             ,{||.T.}                ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABCNT:AddField(STR0195   ,STR0195    ,'CNT_TISO_I'     ,'C',4 ,0    ,{||VAL_TISO()} ,{||A802W_TISO_CNT()}    ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABCNT:AddField("Contêiner cheio","Contêiner cheio",'CNT_CNTCHE' ,'C',1 ,0,{||VAL_CNT_CHE()}        ,{||DOC_CNT_SAID()}          		  ,{"N=Não","S=Sim"},.F.       ,{||"N"},.F.,.F.,.F.)
   
   
   oStrTABCNT:AddField(STR0196   ,STR0196    ,'CNT_QTD_CN'     ,'C',10,0    ,{||VAL_TISO()} ,{||A802W_QUANT_CNT()}   ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABCNT:AddField(STR0197   ,STR0197    ,'CNT_RES_ID'     ,'C',10,0    ,nil             ,{||.T.}                ,Nil,.F.       ,{|oModel|A802PREPST('PRAA802CNT','CNT_RES_ID',oModel)},.F.,.F.,.F.)
   oStrTABCNT:AddField(STR0197   ,STR0197    ,'CNT_RES_NU'  ,'C',30,0        ,{||VAL_BOOK_NU('PRAA802CNT')}      ,{||.T.}  ,Nil,.F.       ,{|oModel|A802PREPST('PRAA802CNT','CNT_RES_NU',oModel)},.F.,.F.,.F.)
   oStrTABCNT:AddField('Cód. documento' ,'Cód. documento'   ,'CNT_DP_ID'   ,'C',10,0         ,nil								      ,{||.T.}  ,Nil,.F.       ,{|oModel|A802PREPST('PRAA802CNT','CNT_DP_ID',oModel)},.F.,.F.,.F.)
   oStrTABCNT:AddField(STR0060   ,STR0060        	,'CNT_TPO_ES','C',1 ,0  ,{||VALCNTTPES()}             ,{||WHEN_DOC()}  		 ,{'E=ENTRADA','S=SAIDA'}        ,.F.       ,{|oModel|A802PREPST('PRAA802CNT','CNT_TPO_ES',oModel)},.F.,.F.,.F.)
   oStrTABCNT:AddField('Documento'      ,'Documento'        ,'CNT_DP_DS'   ,'C',30,0         ,{||VAL_DOC_ID('PRAA802CNT')}      ,{||.T.}  ,Nil,.F.       ,{|oModel|A802PREPST('PRAA802CNT','CNT_DP_DS',oModel)},.F.,.F.,.F.)
   
   
   If lTemDepot 
       oStrTABCNT:AddField('Operação Depot',    'Operação Depot'   , 'CNT_DEPOT' , 'C', 1 , 0  ,{||A802Clean('PRAA802CNT')},                            {||.T.}  ,                      {"N=Não","S=Sim"}        ,.F.       ,{||"N"},.F.,.F.,.F.)
	   oStrTABCNT:AddField('Cód. Armador'      ,'Cód. Armador'   , 'CNT_ARMADO'  , 'C', 10, 0  ,{||A802VLDARMAD('PRAA802CNT'),A802ARMDESC()},           {||A802ISDEPOT('PRAA802CNT')}   ,Nil                     ,.F.       ,{|oModel|A802PREPST('PRAA802CNT','CNT_ARMADO',oModel)},.F.,.F.,.F.)
	   oStrTABCNT:AddField('Nome Armador'      ,'Nome Armador'   , 'CNT_ARM_DS'  , 'C', 30, 0  ,{||.T.}                            ,                    {||.T.}                         ,Nil                     ,.F.       ,{|oModel|A802PREPST('PRAA802CNT','CNT_ARMADO',oModel)},.F.,.F.,.F.)
	   oStrTABCNT:AddField('Cod. Programação', 'Cod. Programação', 'CNT_PROGRA'  , 'C', 30, 0  ,{||A802PROGRAM('PRAA802CNT')},                          {||A802ISDEPOT('PRAA802CNT')}   ,Nil                     ,.F.       ,{|oModel|A802PREPST('PRAA802CNT','CNT_PROGRA',oModel)},.F.,.F.,.F.)
   EndIf

   // REBOQUES
   if cTipomodal == 'V'
      oStrTABREB:AddTable(cAliTMPReb, {'REB_PRG_ID+REB_REB_ID'},STR0088)
      oStrTABREB:AddIndex(1,'01', 'REB_PRG_ID+REB_REB_ID','Indice 1','','',.T.)
      oStrTABREB:AddField(STR0001,STR0001,'REB_PRG_ID','C',10 ,0,Nil               ,{||.T.}         ,Nil,.F.       ,,.T.,.T.,.F.)
      oStrTABREB:AddField(STR0059,STR0059,'REB_REB_ID','C',10 ,0,{||VAL_REB_ID()},{||.T.}           ,Nil,.F.       ,,.F.,.F.,.F.)
   EndIF
	SEL_AR_ANO()
   // DOCUMENTOS
   oStrTABDOC:AddTable(cAliTMPDoc, {'DOC_PRG_ID+DOC_DOC_ID'},STR0089)
   oStrTABDOC:AddIndex(1,'01', 'DOC_PRG_ID+DOC_DOC_ID','Indice 1','','',.T.)
   oStrTABDOC:AddField(STR0001            ,STR0001        		,'DOC_PRG_ID','C',10 ,0  ,Nil                             ,{||.T.}         				 ,Nil        ,.F.       ,,.T.,.T.,.F.)
   oStrTABDOC:AddField(STR0001            ,STR0001       	   ,'DOC_DP_ID','C',10 ,0  ,Nil                              ,{||.T.}         				 ,Nil        ,.F.       ,,.F.,.F.,.F.)
   oStrTABDOC:AddField(STR0060            ,STR0060        		,'DOC_TPO_ES','C',1 ,0  ,{||VAL_TPO_ES()}                 ,{||WHEN_DOC()}  				 ,{'E=ENTRADA','S=SAIDA'}        ,.F.       ,{|oModel|A802PREPST('PRAA802DOC','DOC_TPO_ES',oModel)},.F.,.F.,.F.)   
   oStrTABDOC:AddField(STR0198            ,STR0198   		   ,'DOC_DOC_ID','C',50 ,0  ,Nil                             ,{||.T.}         				 ,Nil        ,.F.       ,,.F.,.F.,.F.)
   oStrTABDOC:AddField(STR0062        	    ,STR0062       		,'DOC_TPO_DC','C',10 ,0  ,{||VAL_TPO_DC()}                ,{||WHEN_DOC()}         		 ,Nil        ,.F.		   ,{|oModel|A802PREPST('PRAA802DOC','DOC_TPO_DC',oModel)},.F.,.F.,.F.)
   oStrTABDOC:AddField(STR0063		       ,STR0063             ,'DOC_ANO_DC','C',4  ,0  ,{||VAL_ANO()}                   ,{||WHEN_DOC()}         		 ,a_ANO_DC   ,.F.       ,FwBuildFeature( STRUCT_FEATURE_INIPAD, str(YEAR(DATE())) ),.F.,.F.,.F.)
   oStrTABDOC:AddField(STR0064            ,STR0064             ,'DOC_NUM_DC','C',30 ,0  ,{||VAL_DOC_NUM()}               ,{||WHEN_DOC()}         		 ,Nil        ,.F.		   ,,.F.,.F.,.F.)
   oStrTABDOC:AddField(STR0065            ,STR0065             ,'DOC_SER_DC','C',3  ,0  ,{||VAL_NUM_SER()}               ,{||WHEN_SER()}  				 ,Nil        ,.F.       ,,.F.,.F.,.F.)
   oStrTABDOC:AddField(STR0066            ,STR0066             ,'DOC_PRC_DC','C',3  ,0  ,Nil                             ,{||WHEN_PROC()} 				 ,Nil        ,.F.       ,{|oModel|A802PREPST('PRAA802DOC','DOC_PRC_DC',oModel)},.F.,.F.,.F.)
   
   oStrTABDOC:AddField('Cód. Reserva'     ,'Cód. Reserva'      ,'DOC_RES_ID','C',10 ,0  ,nil                         ,{||WHEN_DOC()}         		 ,Nil        ,.F.       ,{|oModel|A802PREPST('PRAA802DOC','DOC_RES_ID',oModel)},.F.,.F.,.F.)
   oStrTABDOC:AddField('Reserva'          ,'Reserva'           ,'DOC_RES_NU','C',30 ,0  ,{||VAL_BOOK_NU('PRAA802DOC')},{||VAL_BOOK_NU('PRAA802DOC'),.T.}         			 ,Nil        ,.F.       ,{|oModel|A802PREPST('PRAA802DOC','DOC_RES_NU',oModel)},.F.,.F.,.F.)   
   oStrTABDOC:AddField('CFOP'             ,'CFOP'              ,'DOC_CFOP'  ,'C',5  ,0  ,{||VAL_CFOP()}    				,{||.T.}         				 ,Nil        ,.F.       ,{|oModel|A802PREPST('PRAA802DOC','DOC_CFOP',oModel)},.F.,.F.,.F.)
   oStrTABDOC:AddField('Descrição do CFOP','Descrição do CFOP' ,'DOC_CFOP_D','C',100  ,0  ,nil              ,{||.T.}         				 ,Nil        ,.F.       ,{|oModel|A802PREPST('PRAA802DOC','DOC_CFOP_D',oModel)},.F.,.F.,.F.)
   oStrTABDOC:AddField('Beneficiário (CNPJ/ CPF)','Beneficiário (CNPJ/ CPF)' ,'DOC_BEN_ID'   ,'C',6  ,0  ,{||.T.}  ,{||WHEN_BEN()}  ,nil        ,.F.        ,{|oModel|A802PREPST('PRAA802DOC','DOC_BEN_ID',oModel)},.F.,.F.,.F.)
   oStrTABDOC:AddField('Beneficiário (CNPJ/ CPF)','Beneficiário (CNPJ/ CPF)' ,'DOC_BEN_CG'   ,'C',21  ,0  ,{||VAL_CLIENTE('PRAA802DOC')}  ,{||WHEN_BEN()}  ,nil        ,.F.        ,{|oModel|A802PREPST('PRAA802DOC','DOC_BEN_ID',oModel)},.F.,.F.,.F.)
   oStrTABDOC:AddField('Beneficiario'     ,'Beneficiario'      ,'DOC_BEN'   ,'C',50  ,0  ,nil                             ,{||.F.} 						 ,nil        ,.F.        ,{|oModel|A802PREPST('PRAA802DOC','DOC_BEN',oModel)},.F.,.F.,.F.)


   // ANEXOS
   oStrTABANE:AddTable(cAliTMPAne,{'ANE_PRG_ID+ANE_ANE_ID'},"Arquivo")
   oStrTABANE:AddIndex(1,'01', 'ANE_PRG_ID+ANE_ANE_ID','Indice 1','','',.T.)
   oStrTABANE:AddField(STR0001,STR0001,'ANE_PRG_ID','C',10 ,0,Nil               ,{||.T.}         ,Nil,.F.       ,,.T.,.T.,.F.)
   oStrTABANE:AddField(STR0067,STR0067,'ANE_ANE_ID','C',10 ,0,Nil               ,{||.T.}         ,Nil,.T.       ,,.F.,.F.,.F.)
   oStrTABANE:AddField(STR0068,STR0068,'ANE_ARQUIV','C',256,0,{|oModelANE|STRVAL0001StringMenorIgual(oModelANE)},{||.T.}         ,Nil,.T.       ,,.F.,.F.,.F.)
   oStrTABANE:AddField(STR0069,STR0069,'ANE_OBSERV','C',50 ,0,Nil               ,{||.T.}         ,Nil,.F.       ,,.F.,.F.,.F.)

   oStrTABITC:AddTable(cAliTMPITCAR, {'ITC_PRG_ID+ITC_PIC_ID'},"Arquivo")
   oStrTABITC:AddIndex(1,'01', 'ITC_PRG_ID+ITC_PIC_ID','Indice 1','','',.T.)
   oStrTABITC:AddField('Código'         ,'Código'            ,'ITC_PIC_ID'  ,'C',10 ,0        ,Nil             				 ,{||.T.}             ,Nil,.F.       ,,.T.,.T.,.F.)
   oStrTABITC:AddField('Programação'    ,'Programação'       ,'ITC_PRG_ID'  ,'C',10 ,0        ,Nil             			    ,{||.T.}             ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABITC:AddField('Cód. Documento' ,'Cód. documento'    ,'ITC_DP_ID'   ,'C',10,0         ,nil								 ,{||.T.}             ,nil,.F.       ,{|oModel|A802PREPST('PRAA802ITC','ITC_DP_ID',oModel)},.F.,.F.,.F.)
   oStrTABITC:AddField('Documento'      ,'Documento'         ,'ITC_DP_DS'   ,'C',30,0         ,{||VAL_DOC_ID('PRAA802ITC')} ,{||.T.}             ,nil,.F.       ,{|oModel|A802PREPST('PRAA802ITC','ITC_DP_DS',oModel)},.F.,.F.,.F.)
   oStrTABITC:AddField('Cód. reserva'    ,'Cód. reserva'     ,'ITC_RES_ID'  ,'C',10,0        ,nil                          ,{||WHEN_DOC_RES()}  ,Nil,.F.       ,{|oModel|A802PREPST('PRAA802ITC','ITC_RES_ID',oModel)},.F.,.F.,.F.)
   oStrTABITC:AddField('Reserva'         ,'Reserva'          ,'ITC_RES_NU'  ,'C',30,0        ,{||VAL_BOOK_NU('PRAA802ITC')} ,{||.T.}            ,Nil,.F.       ,{|oModel|A802PREPST('PRAA802ITC','ITC_RES_NU',oModel)},.F.,.F.,.F.)
   oStrTABITC:AddField('Lote'            ,'Lote'             ,'ITC_LOT_ID'  ,'C',12 ,0       ,{||VAL_LOT_ID()}            	 ,{||.T.}             ,Nil,.F.       ,{|oModel|A802PREPST('PRAA802ITC','ITC_LOT_ID',oModel)},.F.,.F.,.F.)
   oStrTABITC:AddField('Item'            ,'Item'             ,'ITC_LOT_IT'  ,'C',10 ,0       ,{||VAL_LOT_IT()}   			 ,{||WHEN_IT()}       ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABITC:AddField('Descr. do item'  ,'Descr. do item'   ,'ITC_LIT_DS'  ,'C',30 ,0       ,nil  			 				 ,{||.T.}             ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABITC:AddField('Quantidade'      ,'Quantidade'       ,'ITC_QTD_VO'  ,'C',10 ,0     ,{||VAL_QTD_VOL()}           	 ,{||WHEN_QTD_M3()}             ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABITC:AddField('Metros cúbicos'  ,'Metros cúbicos'   ,'ITC_M3'      ,'N',8 ,2     ,Nil           					 ,{||WHEN_QTD_M3()}             ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABITC:AddField('Embalagem'       ,'Embalagem'        ,'ITC_EMB'     ,'C',50 ,0     ,Nil           					 ,{||.T.}             ,Nil,.F.       ,,.F.,.F.,.F.)


   oStrTABITD:AddTable(cAliTMPITDES, {'ITD_PRG_ID+ITD_PID_ID'},"Arquivo")
   oStrTABITD:AddIndex(1,'01', 'ITD_PRG_ID+ITD_PID_ID','Indice 1','','',.T.)
   oStrTABITD:AddField('Programação'    ,'Programação'      ,'ITD_PRG_ID'  ,'C',10 ,0        ,Nil                               ,{||.T.}         ,nil,.F.       ,,.T.,.T.,.F.)
   oStrTABITD:AddField('Código'         ,'Código'           ,'ITD_PID_ID'  ,'C',10,0        ,Nil              				     ,{||.T.}          ,nil,.F.       ,,.F.,.F.,.F.)
   oStrTABITD:AddField('Cód. documento' ,'Cód. documento'   ,'ITD_DP_ID'   ,'C',10,0         ,nil								      ,{||.T.}         ,nil,.F.       ,{|oModel|A802PREPST('PRAA802ITD','ITD_DP_ID',oModel)},.F.,.F.,.F.)
   oStrTABITD:AddField('Documento'      ,'Documento'        ,'ITD_DP_DS'   ,'C',30,0         ,{||VAL_DOC_ID('PRAA802ITD')}      ,{||.T.}         ,nil,.F.       ,{|oModel|A802PREPST('PRAA802ITD','ITD_DP_DS',oModel)},.F.,.F.,.F.)
   oStrTABITD:AddField('Cód. espécie'   ,'Cód. especie'     ,'ITD_ESP_ID'  ,'C',2,0          ,{||VAL_ESP_ID()}                  ,{||.T.}         ,nil,.F.       ,,.F.,.F.,.F.)
   oStrTABITD:AddField('Espécie'        ,'Espécie'          ,'ITD_ESP_DS'  ,'C',50,0        ,Nil              					  ,{||.T.}         ,nil,.F.       ,,.F.,.F.,.F.)
   oStrTABITD:AddField('Volume'         ,'Volume'           ,'ITD_QTD_VO'  ,'C',30,0        ,nil              					  ,{||.T.}         ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABITD:AddField('Metros cúbicos' ,'Metros cúbicos'   ,'ITD_M3'      ,'N',8,2        ,Nil              					  ,{||.T.}         ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABITD:AddField('Peso'           ,'Peso'             ,'ITD_PESO'    ,'N',13,2       ,nil   			 					  ,{||.T.}         ,Nil,.F.       ,,.F.,.F.,.F.)
   oStrTABITD:AddField('Cód. família'   ,'Cód. família'     ,'ITD_FAM_ID'  ,'C',7,0         ,{||VAL_FAM_ID()} 					  ,{||.T.}         ,nil,.F.       ,{|oModel|A802PREPST('PRAA802ITD','ITD_FAM_ID',oModel)},.F.,.F.,.F.)
   oStrTABITD:AddField('Família'        ,'Família'          ,'ITD_FAM_DS'  ,'C',50,0        ,Nil             					  ,{||.T.}         ,nil,.F.       ,{|oModel|A802PREPST('PRAA802ITD','ITD_FAM_DS',oModel)},.F.,.F.,.F.)
   oStrTABITD:AddField('Descrição'      ,'Descrição'        ,'ITD_DESC'    ,'C',100,0       ,Nil              					  ,{||.T.}         ,nil,.F.        ,,.F.,.F.,.F.)

   /*****MODEL*****/
   //TABELA PRINCIPAL
   oModel := MPFormModel():New('PRAA802',,{|oModel| A802VAOK(oModel)})

   oModel:SetDescription(STR0090)
   oModel:AddFields('PRAA802', Nil, oStrTABTMP,,,)

	 // REBOQUES
   if cTipomodal == 'V'
      oModel:AddGrid( 'PRAA802REB','PRAA802', oStrTABREB, , , , , { |oObj, lCopia| PRAA802LD( oObj, lCopia, cAliTMPReb )}/*BLoad*/ )
      oModel:SetRelation('PRAA802REB',{{'REB_PRG_ID', 'TMP_PRG_ID'}}, 'REB_PRG_ID+REB_REB_ID')
      oModel:GetModel('PRAA802REB'):SetUniqueLine({'REB_REB_ID'})
      oModel:GetModel('PRAA802REB'):SetDescription(STR0088)
      oModel:GetModel('PRAA802REB'):SetOptional(.T.)
   EndIf

	//DOCUMENTOS
     
   
   oModel:AddGrid( 'PRAA802DOC','PRAA802', oStrTABDOC,/*{|oModel|A802PERDEL()}*/,{|oModelDOC|PST_TABDOC()},/*{|oModelDOC|testee2()}*/, ,{ |oObj, lCopia| PRAA802LD( oObj, lCopia, cAliTMPDoc )}/*BLoad*/ )
   oModel:SetRelation('PRAA802DOC',{{'DOC_PRG_ID', 'TMP_PRG_ID'}}, 'DOC_PRG_ID+DOC_DOC_ID')
   oModel:GetModel('PRAA802DOC'):SetUniqueLine({'DOC_TPO_ES','DOC_TPO_DC','DOC_ANO_DC','DOC_SER_DC','DOC_NUM_DC'})
   oModel:GetModel('PRAA802DOC'):SetDescription(STR0089)
   oModel:GetModel('PRAA802DOC'):SetOptional(.T.)

	//container
   
   oModel:AddGrid( 'PRAA802CNT','PRAA802', oStrTABCNT,{|oModel|A802PREVLD(FWModelActive(),'PRAA802CNT')},{||A802CNTPST()},,, { |oObj, lCopia| PRAA802LD( oObj, lCopia, cAliTMPP )}/*BLoad*/ )
   oModel:SetRelation('PRAA802CNT',{{'CNT_PRG_ID', 'TMP_PRG_ID'}}, 'CNT_PRG_ID+CNT_PCNT_I')   
   oModel:GetModel('PRAA802CNT'):SetDescription("Containers")
   oModel:GetModel('PRAA802CNT'):SetOptional(.T.)

   //ITENS DE DESCARGA
   
   oModel:AddGrid( 'PRAA802ITD','PRAA802', oStrTABITD,{|oModelDOC|A802ITDPER(oModelDOC)},{|oModelDOC|A802ITDPST(oModelDOC)},/*{||alert('teste1')}*/,/*{||alert('teste2')}*/, { |oObj, lCopia| PRAA802LD( oObj, lCopia, cAliTMPITDES )}/*BLoad*/ )
   oModel:SetRelation('PRAA802ITD',{{'ITD_PRG_ID','TMP_PRG_ID'}}, 'ITD_PRG_ID+ITD_PID_ID')
   oModel:GetModel('PRAA802ITD'):SetDescription("Item de descarga")
   oModel:GetModel('PRAA802ITD'):SetOptional(.T.)

   //ITENS CARGA
   
   oModel:AddGrid( 'PRAA802ITC','PRAA802', oStrTABITC,{|oModelDOC|A802ITCPER(oModelDOC)},{|oModelDOC|A802ITCPST(oModelDOC)}, , ,{ |oObj, lCopia| PRAA802LD( oObj, lCopia, cAliTMPITCAR )}/*BLoad*/ )
   oModel:SetRelation('PRAA802ITC',{{'ITC_PRG_ID', 'TMP_PRG_ID'}}, 'ITC_PRG_ID+ITC_PIC_ID')
   oModel:GetModel('PRAA802ITC'):SetDescription("Item de carga")
   oModel:GetModel('PRAA802ITC'):SetOptional(.T.)

   //ANEXOS
   
   oModel:AddGrid( 'PRAA802ANE','PRAA802', oStrTABANE ,,{|oModelANE|PST_TABANE(oModelANE)},,, { |oObj, lCopia| PRAA802LD( oObj, lCopia, cAliTMPAne )}/*BLoad*/ )
   oModel:SetRelation('PRAA802ANE',{{'ANE_PRG_ID', 'TMP_PRG_ID'}}, 'ANE_PRG_ID+ANE_ANE_ID')
   oModel:GetModel('PRAA802ANE'):SetDescription("Arquivos")
   oModel:GetModel('PRAA802ANE'):SetOptional(.T.)

   oModel:SetPrimaryKey({'TMP_PRG_ID'})
   
   oModel:InstallEvent("_A802EVENT",, _A802EVENT():New())
   
   oModel:SetActivate({|oModel|A802LOAD(oModel)})

   oModel:SetVldActivate({|oModel| A802VERPEP(oModel)})

Return oModel

/*/{Protheus.doc} ViewDef
ViewDef MVC
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Contrução da Interface
/*/
Static Function ViewDef()
   Local oModel := FWLoadModel('PRAA802')
   Local oStrTABTMP := FWFormViewStruct():New()
   Local oStrTABREB := FWFormViewStruct():New()
   Local oStrTABDOC := FWFormViewStruct():New()
   Local oStrTABANE := FWFormViewStruct():New()
   Local oStrTABCNT := FWFormViewStruct():New()
   Local oStrTABITC := FWFormViewStruct():New()
   Local oStrTABITD := FWFormViewStruct():New()
   Local oView      := Nil
   Local nPos := 0
   Local i
   Local xRet

   //PRAA802REC()
   SEL_AR_POR()
   SEL_AR_NAT()
   SEL_AR_OPE()
   //SEL_AR_TES()
   SEL_AR_ANO()
   SEL_AR_PRO()
   //carrega o combobox representando os clientes que o usuario tem acesso, que vai ser o beneficiario
   CAR_BEN()

   oStrTABTMP:AddGroup('GrpOperacao',STR0157,'',2)
   oStrTABTMP:AddGroup('GrpAgenda',STR0168,'',2)
   oStrTABTMP:AddGroup('GrpTransporte',STR0224,'',2)

   oStrTABTMP:AddField('TMP_MODAL'   ,'01' ,STR0155     ,STR0155     ,Nil,'GET',"@"                         ,Nil,Nil     ,.F.,Nil,'GrpOperacao',Nil,Nil,Nil,.F.,Nil,.F.)
   oStrTABTMP:AddField('TMP_EVE_DS'  ,'02',STR0180      ,STR0180     ,Nil,'GET',"@"                         ,Nil,Nil      ,.F.,Nil,'GrpOperacao',Nil     ,Nil,Nil,.F.,Nil,.T.)
   If cTipomodal == "F"
		oStrTABTMP:AddField("TMP_VIAGEM"  ,'03',"Viagem ferr.", "Viagem ferroviária",/*aHelp*/,"C",/*PIC*/,/*BPIC*/,"SARVIA",/*LCANCHANGE*/,/*CFOLDER*/,'GrpOperacao'/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.F./*LINSERTLINE*/)

	   oStrTABTMP:AddField('TMP_CLIFER'  ,'04','Operador ferr.','Operador ferr.'   ,Nil,'GET',"@" ,Nil,Nil,.F.,Nil,'GrpOperacao',Nil ,Nil,Nil,.F.,Nil,.F.)
	   oStrTABTMP:AddField('TMP_OPFER'   ,'05','Operação ferr.','Operação ferr.'   ,Nil,'GET',"@" ,Nil,Nil,.F.,Nil,'GrpOperacao',Nil ,Nil,Nil,.F.,Nil,.T.)
		nPos := 3
   EndIf
   oStrTABTMP:AddField('TMP_OPE_ID'  ,StrZero(Val('03')+nPos,2),STR0156      ,STR0156     ,Nil,'GET',"9999999999"               ,Nil,'SARAOP' ,.T.,Nil,'GrpOperacao',nil,Nil,Nil,.F.,Nil,.F.)
   oStrTABTMP:AddField('TMP_OPE_DS'  ,StrZero(Val('04')+nPos,2),STR0157      ,STR0157     ,Nil,'GET',"@"                         ,Nil,Nil      ,.F.,Nil,'GrpOperacao',nil,Nil,Nil,.F.,Nil,.T.)
   oStrTABTMP:AddField('TMP_SUB_ID'  ,StrZero(Val('05')+nPos,2),STR0158      ,STR0158     ,Nil,'GET',"9999999999"               ,Nil,'SARASO' ,.T.,Nil,'GrpOperacao',Nil,Nil,Nil,.F.,Nil,.F.)
   oStrTABTMP:AddField('TMP_SUB_DS'  ,StrZero(Val('06')+nPos,2),STR0159      ,STR0159     ,Nil,'GET',"@"                         ,Nil,Nil      ,.F.,Nil,'GrpOperacao',Nil ,Nil,Nil,.F.,Nil,.T.)
   oStrTABTMP:AddField('TMP_DC_D'    ,StrZero(Val('07')+nPos,2),STR0163      ,STR0163     ,Nil,'GET',"@"                         ,Nil,Nil      ,.F.,Nil,'GrpOperacao',Nil ,Nil,Nil,.F.,Nil,.F.)
   oStrTABTMP:AddField('TMP_QUANT'   ,StrZero(Val('08')+nPos,2),STR0160      ,STR0160     ,Nil,'GET',"999999"                         ,Nil,Nil      ,.T.,Nil,'GrpOperacao',Nil ,Nil,Nil,.F.,Nil,.F.)
   oStrTABTMP:AddField('TMP_DT_INE'  ,StrZero(Val('09')+nPos,2),STR0164      ,STR0164     ,Nil,'GET',"99/99/9999"               ,Nil,nil      ,IIF(cTipoModal != 'F',.T.,.F.),Nil,'GrpAgenda',Nil ,Nil,Nil,.F.,Nil,.F.)
   oStrTABTMP:AddField('TMP_DT_FIE'  ,StrZero(Val('10')+nPos,2),STR0165     ,STR0165     ,Nil,'GET',"99/99/9999"              ,Nil,'SARAAG',.T.,Nil,'GrpAgenda',Nil ,Nil,Nil,.F.,Nil,.T.)
   oStrTABTMP:AddField('TMP_DT_AGE'  ,StrZero(Val('11')+nPos,2),STR0168     ,STR0168     ,Nil,'GET',"@"                         ,Nil,Nil      ,.F.,Nil,'GrpAgenda',Nil ,Nil,Nil,.F.,Nil,.T.)
   oStrTABTMP:AddField('TMP_DT_PRE'  ,StrZero(Val('12')+nPos,2),'Data prevista' ,'Data prevista' ,Nil,'GET',"@"                     ,Nil,Nil      ,IIF(cTipoModal != 'F',.T.,.F.),Nil,'GrpAgenda',Nil ,Nil,Nil,.F.,Nil,.F.)
   oStrTABTMP:AddField('TMP_HR_PRE'  ,StrZero(Val('13')+nPos,2),'Hora prevista' ,'Hora prevista' ,Nil,'GET',"99:99"                     ,Nil,Nil  ,IIF(cTipoModal != 'F',.T.,.F.),Nil,'GrpAgenda',Nil ,Nil,Nil,.F.,Nil,.T.)
   oStrTABTMP:AddField('TMP_PESO'    ,StrZero(Val('14')+nPos,2),STR0226     ,STR0226     ,Nil,'GET',"9999999999.99"   ,Nil,Nil   ,.T.,Nil,'GrpAgenda',Nil ,Nil,Nil,.F.,Nil,.F.)
   oStrTABTMP:AddField('TMP_CUBICO'  ,StrZero(Val('15')+nPos,2),STR0227     ,STR0227     ,Nil,'GET',"999999.99"  ,Nil,Nil  ,.T.,Nil,'GrpAgenda',Nil ,Nil,Nil,.F.,Nil,.T.)
   oStrTABTMP:AddField('TMP_CLI_CG'  ,StrZero(Val('16')+nPos,2),STR0238	   ,STR0238      ,Nil,'GET',"@R 99.999.999/9999-99",{||S_PICPES( FwFldGet("TMP_CLI_CG")) },'SARACL',.T.,Nil,'GrpAgenda',Nil,Nil,Nil,.F.,Nil,.F.)
   oStrTABTMP:AddField('TMP_ORI_DS'  ,StrZero(Val('17')+nPos,2),STR0244      ,STR0244	   ,Nil,'GET',"@"                           ,Nil,Nil ,.F.,Nil,'GrpAgenda',Nil,Nil,Nil,.F.,Nil,.F.)
   oStrTABTMP:AddField('TMP_OBSERV'  ,StrZero(Val('18')+nPos,2),'Observação' ,'Observação',Nil,'GET',"@!"                           ,Nil,Nil ,.T.,Nil,'GrpAgenda',Nil,Nil,Nil,.F.,Nil,.F.)
   //oStrTABTMP:AddField('TMP_CL_CGC'  ,StrZero(Val('08',STR0240      ,STR0240     ,Nil,'GET',"@"                          ,Nil,Nil ,.F.,Nil,'GrpAgenda',Nil,Nil,Nil,.F.,Nil,.F.)
   oStrTABTMP:AddField('TMP_VEI_ID'  ,StrZero(Val('19')+nPos,2),'Identificação Veículo','Identificação Veículo',Nil,'GET',If(cTipomodal != "F","@!","@!AAA9999999"),Nil,'SARAVE',.T.,Nil,'GrpTransporte',Nil,Nil,Nil,.F.,Nil,.T.)
   oStrTABTMP:AddField('TMP_TRA_CG'  ,StrZero(Val('20')+nPos,2),STR0286 	    ,STR0286 	   ,Nil,'GET',"@R 99.999.999/9999-99",{||S_PICPES( FwFldGet("TMP_TRA_CG")) },'SAROPE',cTipoModal != "F",Nil,'GrpTransporte',Nil,Nil,Nil,.F.,Nil,.F.)
   oStrTABTMP:AddField('TMP_TRA_DS'  ,StrZero(Val('21')+nPos,2),STR0174      ,STR0174     ,Nil,'GET',"@"                         ,Nil,Nil     ,.F.,Nil,'GrpTransporte',Nil,Nil,Nil,.F.,Nil,.T.)
   oStrTABTMP:AddField('TMP_PES_CG'  ,StrZero(Val('22')+nPos,2),cCodPes      ,cCdPes2     ,Nil,'GET',"@R 999.999.999-99" ,Nil,'SARAPE',.T.,Nil,'GrpTransporte',Nil     ,Nil,Nil,.F.,Nil,.F.)
   oStrTABTMP:AddField('TMP_PES_DS'  ,StrZero(Val('23')+nPos,2),cNomPes      ,cNmPes2     ,Nil,'GET',"@"                         ,Nil,Nil      ,.F.,Nil,'GrpTransporte',Nil     ,Nil,Nil,.F.,Nil,.F.)


   //oStrTABTMP:AddField('teste'        ,'20',''            ,''          ,Nil,'',""                         ,Nil,'SARAAG' ,.T.,Nil,'GrpTransporte',Nil     ,Nil,Nil,.F.,Nil,.T.)

   //REBOQUES
   if cTipomodal == 'V'
      oStrTABREB:AddField('REB_REB_ID' ,'01',STR0059,STR0059,Nil,'GET',"@!"                     ,Nil,'SARARB',.T.,Nil,Nil,Nil     ,Nil,Nil,.F.,Nil,.F.)
   EndIf

   // DOCUMENTOS
   oStrTABDOC:AddField('DOC_RES_NU','01','Reserva'        ,'Reserva'       ,Nil,'GET',"@!"                    ,Nil,'SARABD'          ,.T.,Nil,Nil,nil,Nil,nil,.F.,Nil,.F.)
   oStrTABDOC:AddField('DOC_TPO_ES','02',STR0231        ,STR0231       ,Nil,'GET',"@!"                         ,Nil,Nil     ,.T.,Nil,Nil,{'E=ENTRADA','S=SAIDA'},Nil,nil,.F.,Nil,.F.)
   oStrTABDOC:AddField('DOC_TPO_DC','03',STR0232        ,STR0232       ,Nil,'GET',"@!"                        ,Nil,'SARATD' ,.T.,Nil,Nil,nil     ,Nil,nil,.F.,Nil,.F.)
   oStrTABDOC:AddField('DOC_ANO_DC','04',STR0063	      ,STR0063        ,Nil,'GET',"@"                         ,Nil,Nil      ,.T.,Nil,Nil,a_ANO_DC,Nil,Nil,.T.,Nil,.F.)
   oStrTABDOC:AddField('DOC_NUM_DC','05',STR0233        ,STR0233       ,Nil,'GET',"@!"                        ,nil,'SARADC' ,.T.,Nil,Nil,Nil     ,Nil,Nil,.F.,Nil,.F.)
   oStrTABDOC:AddField('DOC_SER_DC','06',STR0065        ,STR0065       ,Nil,'GET',"999"                       ,Nil,Nil     ,.T.,Nil,Nil,Nil     ,Nil,Nil,.F.,Nil,.F.)
   oStrTABDOC:AddField('DOC_PRC_DC','07',STR0066   	  ,STR0066   		 ,Nil,'GET',"@"                         ,{||PICVAR_DOC()},Nil ,.T.,Nil,Nil,a_PRC_DC,Nil,nil,.F.,Nil,.F.)
   oStrTABDOC:AddField('DOC_CFOP'  ,'08','CFOP'         ,'CFOP'        ,Nil,'GET',"9.999"                    ,Nil,'SARACF'          ,.T.,Nil,Nil,nil,Nil,nil,.F.,Nil,.F.)
   oStrTABDOC:AddField('DOC_CFOP_D','09','Descrição do CFOP'   ,'Descrição do CFOP'        ,Nil,'GET',"@"                  ,Nil,nil           ,.F.,Nil,Nil,nil,Nil,nil,.F.,Nil,.F.)
   //TODO copiar formação praa808a
   oStrTABDOC:AddField('DOC_BEN_CG','10','Beneficiário (CNPJ/ CPF)','Beneficiário (CNPJ/ CPF)'  ,Nil,'GET',"@R 99.999.999/9999-99",{||S_PICPES( FwFldGet("DOC_BEN_CG"),.F.) },'SARACL',.T.,Nil,Nil,nil,nil,nil,.F.,Nil,.F.)
   oStrTABDOC:AddField('DOC_BEN'   ,'11','Beneficiario' ,'Beneficiario'  ,Nil,'GET',"@"                      ,Nil,Nil     ,.F.,Nil,Nil,Nil   ,nil,nil,.F.,Nil,.F.)

   //container
   //oStrTABCNT:AddField('CNT_RES_ID','01' ,'Cód. Reserva'      ,'Cód. Reserva'         ,Nil,'GET',"@!"          ,Nil,'SARABK'     ,.T.,Nil,Nil,Nil     ,Nil,Nil,.F.,Nil,.F.)
   oStrTABCNT:AddField('CNT_RES_NU','01' ,STR0197      ,STR0197       ,Nil,'GET',"@!"                        ,Nil,'SARABK'     ,.T.,Nil,Nil,Nil     ,Nil,Nil,.F.,Nil,.F.)
   oStrTABCNT:AddField('CNT_TPO_ES','02' ,STR0231      ,STR0231       ,Nil,'GET',"@!"                         ,Nil,Nil     ,.T.,Nil,Nil,{'E=ENTRADA','S=SAIDA'},Nil,nil,.F.,Nil,.F.)
   oStrTABCNT:AddField('CNT_DP_DS' ,'03' ,'Documento'  ,'Documento'   ,Nil,'GET',"@"                         ,Nil,'SARDCN'     ,.T.,Nil,Nil,Nil     ,Nil,Nil,.F.,Nil,.F.)
   oStrTABCNT:AddField('CNT_CNT_ID','04' ,STR0193   	  ,STR0193   		,Nil,'GET',"@!"                  ,Nil,'SARCNT'     ,.T.,Nil,Nil,Nil     ,Nil,Nil,.F.,Nil,.F.)
   oStrTABCNT:AddField('CNT_TISO_I','05' ,STR0195      ,STR0195      ,Nil,'GET',"@!"                         ,Nil,'SARISO'     ,.T.,Nil,Nil,Nil     ,Nil,Nil,.F.,Nil,.F.)
   oStrTABCNT:AddField('CNT_CNTCHE','06' ,"Container cheio","Container cheio",Nil,'GET',"@!"                 ,Nil,     ,.T.,Nil,Nil,{"N=Não","S=Sim"},Nil,Nil,.F.,Nil,.F.)
   oStrTABCNT:AddField('CNT_QTD_CN','07' ,STR0196      ,STR0196  	    ,Nil,'GET',"@"                       ,Nil,Nil     ,.T.,Nil,Nil,Nil     ,Nil,Nil,.F.,Nil,.F.)
   
   //DEPOT
   If lTemDepot 
	   oStrTABCNT:AddField('CNT_DEPOT',   '08' ,"Operação Depot",    "Operação Depot",    Nil,'GET',"@!"   ,Nil,     ,.T.,     Nil,     Nil,                  {"N=Não","S=Sim"},Nil,Nil,.F.,Nil,.F.)
	   oStrTABCNT:AddField('CNT_ARMADO',  '09',"Cód. Armador"       ,"Cód. Armador"     ,Nil,'GET',"@!"   ,Nil,     'SARARM'    ,.T.,     Nil,                   Nil,             Nil,Nil,Nil,.F.,Nil,.F.)
	   oStrTABCNT:AddField('CNT_ARM_DS'  ,'10',"Nome Armador"       ,"Nome Armador"     ,Nil,'GET',"@"                         ,Nil,Nil      ,.F.,Nil,'GrpOperacao',Nil ,Nil,Nil,.F.,Nil,.T.)
	   oStrTABCNT:AddField('CNT_PROGRA',  '11' ,"Cod. Programação",  "Cod. Programação", Nil,'GET',"@!"   ,Nil,     ,.T.,     Nil,     Nil,                   Nil,             Nil,Nil,.F.,Nil,.F.)
   EndIf

   // ANEXOS
   oStrTABANE:AddField('ANE_ANE_ID','01',STR0067,STR0067,Nil,'GET',"@",Nil,Nil     ,.F.,Nil,Nil,Nil     ,Nil,Nil,.F.,Nil,.F.)
   oStrTABANE:AddField('ANE_ARQUIV','02',STR0068,STR0068,Nil,'GET',"@",Nil,'SARAAR',.T.,Nil,Nil,Nil     ,Nil,Nil,.F.,Nil,.F.)

   //ITENS
   oStrTABITC:AddField('ITC_DP_DS', '03'   ,'Documento'   	      ,'Documento'   		 ,Nil,'GET',"@!"                     ,Nil,'SADEIC'     ,.T.,Nil,Nil,nil          ,Nil,Nil,.F.,Nil,.F.)
   //oStrTABITC:AddField('ITC_RES_ID','01'   ,'Cód. do Reserva'     ,'Cód. da Reserva'    ,Nil,'GET',"@!"      				  ,Nil,'SARABI'     ,.T.,Nil,Nil,Nil          ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITC:AddField('ITC_RES_NU','01'   ,'Reserva'             ,'Reserva'            ,Nil,'GET',"@!"      				  ,Nil,'SARABI'     ,.T.,Nil,Nil,Nil          ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITC:AddField('ITC_LOT_ID','05'   ,'Lote'                ,'Lote'               ,Nil,'GET',"@!"      				  ,Nil,'SARALT'       ,.T.,Nil,Nil,Nil          ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITC:AddField('ITC_LOT_IT','06'   ,'Item do lote'        ,'Item do lote'       ,Nil,'GET',"9999"			  	      ,Nil,'SARALI'   ,.T.,Nil,Nil,Nil     		 ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITC:AddField('ITC_LIT_DS','07'   ,'Item       '         ,'Item'               ,Nil,'GET'  ,"@!"			  	      ,Nil,nil       ,.F.,Nil,Nil,Nil     		 ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITC:AddField('ITC_EMB'   ,'08'   ,'Embalagem'           ,'Embalagem'          ,Nil,'GET',"@!" 	  					  ,Nil,Nil       ,.F.,Nil,Nil,Nil     		 ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITC:AddField('ITC_QTD_VO','09'   ,'Quantidade'          ,'Quantidade'         ,Nil,'GET',"9999999"                ,Nil,Nil       ,.T.,Nil,Nil,Nil     	 ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITC:AddField('ITC_M3'    ,'10'   ,'Metros cúbicos'       ,'Metros cúbicos'      ,Nil,'GET',"999999.99" 	  ,Nil,Nil       ,.T.,Nil,Nil,Nil     		 ,Nil,Nil,.F.,Nil,.F.)



   oStrTABITD:AddField('ITD_DP_DS'  ,'01'   ,'Documento'   	      ,'Documento'   		 ,Nil,'GET',"@!"                    ,Nil,'SARADE'   ,.T.,Nil,Nil,nil          ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITD:AddField('ITD_FAM_ID' ,'02'   ,'Cód. da família'    ,'Cód. da família'      ,Nil,'GET',"9999999"             ,Nil,'SARAFA'  	,.T.,Nil,Nil,Nil         ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITD:AddField('ITD_FAM_DS' ,'03'   ,'Família'             ,'Família'  	        ,Nil,'GET',"@"                     ,Nil,nil        ,.F.,Nil,Nil,Nil          ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITD:AddField('ITD_ESP_ID' ,'04'   ,'Cód. da espécie'    ,'Código da espécie'  ,Nil,'GET',"@!"                    ,Nil,'SARAES'  ,.T.,Nil,Nil,Nil         ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITD:AddField('ITD_ESP_DS' ,'05'   ,'Espécie'             ,'Espécie'  	        ,Nil,'GET',"@"                     ,Nil,nil       ,.F.,Nil,Nil,Nil          ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITD:AddField('ITD_QTD_VO' ,'06'   ,'Volume'              ,'Volume'               ,Nil,'GET',"9999999"            ,Nil,Nil        ,.T.,Nil,Nil,Nil        ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITD:AddField('ITD_M3'     ,'07'   ,'Metros cúbicos'       ,'Metros cúbicos'      ,Nil,'GET',"999999.99"    ,Nil,Nil       ,.T.,Nil,Nil,Nil     	 ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITD:AddField('ITD_PESO'   ,'08'   ,'Peso'                ,'Peso'               ,Nil,'GET',"9999999999.99"     ,Nil,Nil       ,.T.,Nil,Nil,Nil     	 ,Nil,Nil,.F.,Nil,.F.)
   oStrTABITD:AddField('ITD_DESC'   ,'09'   ,'Descrição'          ,'Descrição'         ,Nil,'GET',"@!"      				     ,Nil,Nil      ,.T.,Nil,Nil,Nil    		 ,Nil,Nil,.F.,Nil,.F.)


   /*****VIEW*****/
   //CRIAÇÃO
   oView := FWFormView():New()
   oView:SetModel(oModel)
//   oView:SetUseCursor(.F.)
   oView:CreateHorizontalBox( 'SUPERIOR' , 65,,,,)
   oView:CreateHorizontalBox( 'INFERIOR' , 35,,,,)
   oView:CreateFolder("FOLDER","INFERIOR")

   //TABELA PRINCIPAL
   oView:AddField('PRAA802' , oStrTABTMP)
   oView:SetOwnerView('PRAA802', 'SUPERIOR')

	//REBOQUES
   if cTipomodal == 'V'
      oView:AddGrid('PRAA802REB', oStrTABREB)
      oView:addSheet("FOLDER","F_REBOQUES",STR0088)
      oView:CreateVerticalBox("F_REBOQUES" , 100/*92 - Mudar tamanho*/ , , , "FOLDER" , "F_REBOQUES")
      oView:SetOwnerView("PRAA802REB","F_REBOQUES")
   EndIf

   //DOCUMENTOS
   oView:AddGrid('PRAA802DOC', oStrTABDOC)
   oView:addSheet("FOLDER","F_DOCUMENT",STR0089)
   oView:CreateVerticalBox("F_DOCUMENT" , 100 , , , "FOLDER" , "F_DOCUMENT")
   oView:SetOwnerView("PRAA802DOC","F_DOCUMENT")

	//CONTAINER
	oView:AddGrid('PRAA802CNT', oStrTABCNT)
    oView:addSheet("FOLDER","F_container",'Container')
    oView:CreateVerticalBox("F_container" , 100, , , "FOLDER" , "F_container")
    oView:SetOwnerView("PRAA802CNT","F_container")

    If oModel:GetOperation() == MODEL_OPERATION_VIEW
    	If AllTrim(GetSParam('PLANEJAMENTO_OPERACIONAL_DESCARGA_CARGA','N','N')) == 'S'
			//ITENS DE CARGA
		    oView:AddGrid('PRAA802ITC', oStrTABITC)
		    oView:addSheet("FOLDER","F_ITENS_C",'Planejamento de Carga')
		    oView:CreateVerticalBox("F_ITENS_C" , 100 , , , "FOLDER" , "F_ITENS_C")
		    oView:SetOwnerView("PRAA802ITC","F_ITENS_C")

			//ITENS DE DESCARGA
		    oView:AddGrid('PRAA802ITD', oStrTABITD)
		    oView:addSheet("FOLDER","F_ITENS_D",'Planejamento de Descarga')
		    oView:CreateVerticalBox("F_ITENS_D" , 100 , , , "FOLDER" , "F_ITENS_D")
		    oView:SetOwnerView("PRAA802ITD","F_ITENS_D")
    	EndIf
    Else
		 //ITENS DE CARGA
	    oView:AddGrid('PRAA802ITC', oStrTABITC)
	    oView:addSheet("FOLDER","F_ITENS_C",'Carreg. C. Solta')
	    oView:CreateVerticalBox("F_ITENS_C" , 100 , , , "FOLDER" , "F_ITENS_C")
	    oView:SetOwnerView("PRAA802ITC","F_ITENS_C")

    	//ITENS DE DESCARGA
	    oView:AddGrid('PRAA802ITD', oStrTABITD)
	    oView:addSheet("FOLDER","F_ITENS_D",'Recebim. C. Solta')
	    oView:CreateVerticalBox("F_ITENS_D" , 100 , , , "FOLDER" , "F_ITENS_D")
	    oView:SetOwnerView("PRAA802ITD","F_ITENS_D")
    EndIf


   //ANEXOS
   oView:AddGrid('PRAA802ANE', oStrTABANE)
   oView:addSheet("FOLDER","F_ANEXO","Arquivos")
   oView:CreateVerticalBox("F_ANEXO" , 100, , , "FOLDER" , "F_ANEXO")
   oView:SetOwnerView("PRAA802ANE","F_ANEXO")

   oView:AddIncrementField( 'PRAA802ANE', 'ANE_ANE_ID' )
//   oView:SetCloseOnOk({||.T.})
   //oView:AddOtherObject("PAINEL_OBSERVACAO", {|oPanel| BTN_ABRARQ(oPanel)})
   //oView:SetOwnerView("PAINEL_OBSERVACAO",'PAINEL_OBSERVACAO')
	   if ExistBlock('PRAA802AAR')
		xRet := ExecBlock('PRAA802AAR')
		if ValType(xRet) = 'A'
			for i := 1 to Len(xRet)
//				AAdd(aRotina, xRet[i])
				oView:AddUserButton(xRet[i][1],xRet[i][2],xRet[i][3])
			next
		endif
	endif
Return oView

static function VAL_NUM_SER()
	A802DELREGS()
return .T.

static function WHEN_IT()
	Local oModel    := FWModelActive()
	Local oModelITC := omodel:getmodel('PRAA802ITC')
	Local lResult := .F.

	if alltrim(oModelITC:getvalue('ITC_LOT_ID')) <> ''
		lresult := .T.
	endif

return lResult

static function WHEN_QTD_M3()
	Local oModel    := FWModelActive()
	Local oModelITC := omodel:getmodel('PRAA802ITC')
	Local lResult := .F.

	if alltrim(oModelITC:getvalue('ITC_LOT_IT')) <> ''
		lresult := .T.
	endif

return lResult

Static Function DOC_CNT_SAID()
	Local lRet := .T.
	Local nI
	Local oModel := FwModelActive()
	Local oModelCNT := oModel:GetModel('PRAA802CNT')
	Local oModelDOC := omodel:getmodel('PRAA802DOC')

	For nI := 1 To oModelDOC:Length()
		oModelDOC:GoLine(nI)
		If !omodeldoc:IsDeleted()
			if alltrim(omodeldoc:getvalue('DOC_DOC_ID')) = ''
				resultado :=  pst_tabd2()
				if substr(resultado,1,5) = 'ERROR'
					//if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = 'E'
						lRet := .T.
						Exit
					//EndIf
				else
					if oModelCNT:getvalue('CNT_DP_DS') == AllTrim(resultado) 
						lRet := .F. // Desabilita o campo
						Exit
					EndIF
				endif
			else
				if AllTrim(oModelCNT:getvalue('CNT_DP_DS')) == AllTrim(oModelDOC:GetValue('DOC_DOC_ID')) 
					lRet := .F. // Desabilita o camporeturn .F. // Desabilita o campo
					Exit
				endif
			EndIf
		EndIf
	Next nI



Return lRet


static function WHEN_DOC()
	Local oModel    := FWModelActive()
	Local oModelITD := omodel:getmodel('PRAA802ITD')
	Local oModelITC := omodel:getmodel('PRAA802ITC')
	Local oModelDOC := omodel:getmodel('PRAA802DOC')
	Local lResult := .T.
	Local nI := 0
	
	For nI := 1 To oModelITD:Length()
			oModelITD:GoLine(nI)
			If !(oModelITD:IsDeleted()) .and. alltrim(oModelITD:getvalue('ITD_DP_DS')) <> '';
				.and. alltrim(oModelITD:getvalue('ITD_DP_DS')) = alltrim(oModelDOC:getvalue('DOC_DOC_ID'))
				alert('Operação negada. Existe item de descarga pertinente a este documento.')
				return .F.
			endif

			If !(oModelITC:IsDeleted()) .and. alltrim(oModelITC:getvalue('ITC_DP_DS')) <> '';
				.and. alltrim(oModelITC:getvalue('ITC_DP_DS')) = alltrim(oModelDOC:getvalue('DOC_DOC_ID'))
				alert('Operação negada. Existe item  de carga pertinente a este documento.')
				return .F.
			endif
	next nI
return lResult

static function A802GETLINE(cModel)
	Local oModel    := FWModelActive()
	Local oModelGEN := omodel:getmodel(cModel)
	Local nI := 0

	nI := oModelGEN:Length()

	while nI > 0
//		oModelGEN:GoLine(nI)
		if cModel = 'PRAA802DOC'
			If !(oModelGEN:IsDeleted(nI)) .and. (alltrim(oModelGEN:getvalue('DOC_DOC_ID',nI)) <> '')
			   	return nI
			endif
		elseif cModel = 'PRAA802CNT' .or. cModel = 'PRAA802ITD' .or. cModel = 'PRAA802ITC'
			If !(oModelGEN:IsDeleted(nI))
			   	return nI
			endif
		endif
		nI := nI - 1
	enddo
return nI

static function A802PREPST(cModel,cCampo,oMod)
	Local oModel := oMod
	Local oModelGEN
	Local AUX := ''
	Local bError := errorBlock({|e|erro(e)})

	BEGIN SEQUENCE

	if oModel != NIL
		oModelGEN := omodel
		if oModelGEN:Length() >= 1
		     if cModel = 'PRAA802DOC'
		     	 if A802GETLINE(cModel) > 0
					oModelGEN:GoLine(A802GETLINE(cModel))
					if cCampo = 'DOC_TPO_ES'
						AUX := alltrim(oModelGEN:getvalue('DOC_TPO_ES'))
					elseif cCampo = 'DOC_TPO_DC'
						AUX := alltrim(oModelGEN:getvalue('DOC_TPO_DC'))
					elseif cCampo = 'DOC_PRC_DC'
						AUX := alltrim(oModelGEN:getvalue('DOC_PRC_DC'))
					elseif cCampo = 'DOC_RES_ID'
						AUX := alltrim(oModelGEN:getvalue('DOC_RES_ID'))
					elseif cCampo = 'DOC_RES_NU'
						AUX := alltrim(oModelGEN:getvalue('DOC_RES_NU'))
					elseif cCampo = 'DOC_CFOP_D'
						AUX := alltrim(oModelGEN:getvalue('DOC_CFOP_D'))
					elseif cCampo = 'DOC_CFOP'
						AUX := alltrim(oModelGEN:getvalue('DOC_CFOP'))
					elseif cCampo = 'DOC_BEN_ID'
						AUX := alltrim(oModelGEN:getvalue('DOC_BEN_ID'))
					elseif cCampo = 'DOC_BEN_CG'
						AUX := alltrim(oModelGEN:getvalue('DOC_BEN_CG'))
					elseif cCampo = 'DOC_BEN'
						AUX := alltrim(oModelGEN:getvalue('DOC_BEN'))
					endif
			    endif
			  elseif cModel = 'PRAA802CNT'
			  	if A802GETLINE(cModel) > 0
					oModelGEN:GoLine(A802GETLINE(cModel))
			  	   if cCampo = 'CNT_RES_ID'
						AUX := alltrim(oModelGEN:getvalue('CNT_RES_ID'))
					elseif cCampo = 'CNT_RES_NU'
						AUX := alltrim(oModelGEN:getvalue('CNT_RES_NU'))
					elseif cCampo = 'CNT_DP_ID'
						AUX := alltrim(oModelGEN:getvalue('CNT_DP_ID'))
					elseif cCampo = 'CNT_DP_DS'
						AUX := alltrim(oModelGEN:getvalue('CNT_DP_DS'))
					elseif cCampo = 'CNT_TPO_ES'
						AUX := alltrim(oModelGEN:getvalue('CNT_TPO_ES'))
					endif
			    endif
			  elseif cModel = 'PRAA802ITD'
			  	if A802GETLINE(cModel) > 0
					oModelGEN:GoLine(A802GETLINE(cModel))
				   if cCampo = 'ITD_DP_ID'
						AUX := alltrim(oModelGEN:getvalue('ITD_DP_ID'))
			  	   elseif cCampo = 'ITD_DP_DS'
						AUX := alltrim(oModelGEN:getvalue('ITD_DP_DS'))
					elseif cCampo = 'ITD_FAM_ID'
						AUX := alltrim(oModelGEN:getvalue('ITD_FAM_ID'))
					elseif cCampo = 'ITD_FAM_DS'
						AUX := alltrim(oModelGEN:getvalue('ITD_FAM_DS'))
					endif
			     endif
			  elseif cModel = 'PRAA802ITC'
			  	 if A802GETLINE(cModel) > 0
					oModelGEN:GoLine(A802GETLINE(cModel))
				   if cCampo = 'ITC_RES_NU'
						AUX := alltrim(oModelGEN:getvalue('ITC_RES_NU'))
			  	   elseif cCampo = 'ITC_RES_ID'
						AUX := alltrim(oModelGEN:getvalue('ITC_RES_ID'))
					elseif cCampo = 'ITC_DP_ID'
						AUX := alltrim(oModelGEN:getvalue('ITC_DP_ID'))
					elseif cCampo = 'ITC_DP_DS'
						AUX := alltrim(oModelGEN:getvalue('ITC_DP_DS'))
					elseif cCampo = 'ITC_LOT_ID'
						AUX := alltrim(oModelGEN:getvalue('ITC_LOT_ID'))
					endif
			     endif
		     endif
		endif
//		oView:GetViewObj(cModel)[3]:EvalWhen()
	endif
	END SEQUENCE
	ErrorBlock(bError)
return AUX


static function VAL_QTD_VOL()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oView     := FWViewActive()
	Local oModelITC := omodel:getmodel('PRAA802ITC')
	Local calias := GetNextalias()
	Local nI := 0
	Local nQuant := 0
	Local nM3 := 0
	Local nQuantProg := 0
	Local nM3Prog := 0
	Local nPreveM3 := 0
	Local cLote := ''
	Local cItem := ''
	Local nLineAtu := 0
	//Local aSaveLines := FWSaveRows()

	if alltrim(oModelITC:getvalue('ITC_QTD_VO')) <> ''
	   		cQuery := " select convert(varchar(16),a.latu_item) as num_item, "
			cQuery += "				       convert(varchar(16),a.loclo_qt) as qtde, "
			cQuery += "				       a.esp_id + " + "' - '" + " + c.esp_descricao as embalagem, "
			cQuery += "				      convert(varchar(16),a.loclo_m3_saldo) as m3, "
			cQuery += "				       a.latu_descricao        "
			cQuery += "				from vw_inventario_armazem a "
			cQuery += "				  inner join tab_clientes b "
			cQuery += "				    on a.ben_id = b.cli_id "
			cQuery += "				  inner join tab_especie c "
			cQuery += "				    on c.esp_id = a.esp_id   "
			cQuery += "				where loclo_qt > 0 "
	   		cQuery += " 				and a.latu_lote = '" + alltrim(oModelITC:getvalue('ITC_LOT_ID')) + "'"
	   		cQuery += " 				and a.latu_item = '" + alltrim(oModelITC:getvalue('ITC_LOT_IT')) + "'"

	   		nLineAtu := oView:GetViewObj('PRAA802ITC')[3]:getLineAt()
	   		nVolAtu := val(alltrim(oModelITC:getvalue('ITC_QTD_VO')))
	   		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
			if alltrim((cAlias)->num_item) <> ''
				cLote := alltrim(oModelITC:getvalue('ITC_LOT_ID'))
				cItem := alltrim(oModelITC:getvalue('ITC_LOT_IT'))
				For nI := 1 To oModelITC:Length()
					oModelITC:GoLine(nI)
					If !(oModelITC:IsDeleted());
					   .and. (cLote = alltrim(oModelITC:getvalue('ITC_LOT_ID')) );
					   .and. (cItem = alltrim(oModelITC:getvalue('ITC_LOT_IT')) );
					   .and. oView:GetViewObj('PRAA802ITC')[3]:getLineAt() !=  nI
					   nM3 += oModelITC:getvalue('ITC_M3')
					   nM3Prog += oModelITC:getvalue('ITC_M3')
					   nQuant += val(alltrim(oModelITC:getvalue('ITC_QTD_VO')))
					   nQuantProg += val(alltrim(oModelITC:getvalue('ITC_QTD_VO')))
					elseif(!(oModelITC:IsDeleted()) .and. oView:GetViewObj('PRAA802ITC')[3]:getLineAt() !=  nI)
					   nQuantProg += val(alltrim(oModelITC:getvalue('ITC_QTD_VO')))
					   nM3Prog += oModelITC:getvalue('ITC_M3')
					endif
				next nI
				//FWRestRows( aSaveLine )
				oModelITC:GoLine(nLineAtu)
				if nVolAtu > val(alltrim((cAlias)->qtde)) - nQuant
					oModel:SetErrorMessage('PRAA802ITC','ITC_QTD_VO','','','3000','Quantidade de itens de carregamento de c. solta indisponível.',;
								'Quantidade disponível: ' + alltrim(str(val(alltrim((cAlias)->qtde)) - nQuant)) + chr(13)+chr(10),nil,nil)
					return .f.
				endif

				nPreveM3 := (nVolAtu * val(alltrim((cAlias)->m3))) / val(alltrim((cAlias)->qtde))
				oModelITC:loadvalue('ITC_M3',nPreveM3)

			else
				lresult := .F.
			endif
	endif

//	oView:GetViewObj('PRAA802ITC')[3]:EvalWhen()

return lResult

static function VAL_LOT_IT()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oView     := FWViewActive()
	Local oModelITC := oModel:getmodel('PRAA802ITC')
	Local oModelTMP := oModel:getmodel('PRAA802')
	Local calias := GetNextalias()
	Local calias3 := GetNextalias()
	Local nI := 0
	Local nQuant := 0
	Local nM3 := 0
	Local nQuantProg := 0
	Local nM3Prog := 0
	Local cLote := ''
	Local cItem := ''
	Local nPreveQtd := 0

	if alltrim(oModelITC:getvalue('ITC_LOT_IT')) <> ''
		   
	   		cQuery := " select convert(varchar(16),a.latu_item) as num_item, "
			cQuery += "				       convert(varchar(16),a.loclo_qt) as qtde, "
			cQuery += "				       a.esp_id + " + "' - '" + " + c.esp_descricao as embalagem, "
			cQuery += "				      convert(varchar(16),a.loclo_m3_saldo) as m3, "
			cQuery += "				       a.latu_descricao        "
			cQuery += "				from vw_inventario_armazem a "
			cQuery += "				  inner join tab_clientes b "
			cQuery += "				    on a.ben_id = b.cli_id "
			cQuery += "				  inner join tab_especie c "
			cQuery += "				    on c.esp_id = a.esp_id   "
			cQuery += "				where loclo_qt > 0 "
	   		cQuery += " 				and a.latu_lote = '" + alltrim(oModelITC:getvalue('ITC_LOT_ID')) + "'"
	   		cQuery += " 				and a.latu_item = '" + alltrim(oModelITC:getvalue('ITC_LOT_IT')) + "'"
	   		cQuery += "          and a.esp_id not in ('CC','OE')  "
	   		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

			if alltrim((cAlias)->num_item) <> ''
				oModelITC:loadvalue('ITC_LOT_IT',alltrim((cAlias)->num_item))
				oModelITC:loadvalue('ITC_LIT_DS',alltrim((cAlias)->latu_descricao))
				cLote := alltrim(oModelITC:getvalue('ITC_LOT_ID'))
				cItem := alltrim(oModelITC:getvalue('ITC_LOT_IT'))
				For nI := 1 To oModelITC:Length()
					oModelITC:GoLine(nI)
					If !(oModelITC:IsDeleted());
					   .and. (cLote = alltrim(oModelITC:getvalue('ITC_LOT_ID')) );
					   .and. (cItem = alltrim(oModelITC:getvalue('ITC_LOT_IT')) );
					   .and. oView:GetViewObj('PRAA802ITC')[3]:getLineAt() !=  nI

					   nQuant += val(alltrim(oModelITC:getvalue('ITC_QTD_VO')))
					   nM3 += oModelITC:getvalue('ITC_M3')
					   nQuantProg += val(alltrim(oModelITC:getvalue('ITC_QTD_VO')))
					   nM3Prog += oModelITC:getvalue('ITC_M3')
					elseif .Not. oModelITC:IsDeleted() .and. oView:GetViewObj('PRAA802ITC')[3]:getLineAt() !=  nI
					   nQuantProg += val(alltrim(oModelITC:getvalue('ITC_QTD_VO')))
					   nM3Prog += oModelITC:getvalue('ITC_M3')
					endif
				next nI

				cQuery +=     " select convert(varchar(15),sum(loclo_qt)) as qtde, convert(varchar(15),sum(loclo_m3_saldo)) as m3 "+;
								"	from vw_inventario_armazem "+;
								"	where latu_lote = '" + cLote + "'"+;
								"	group by latu_lote,latu_item	"

				dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias3, .F., .T.)

				if oModelTMP:getvalue('TMP_PESO') = 0 .and. oModelTMP:getvalue('TMP_CUBICO') = 0
						if val(alltrim((cAlias3)->m3)) - nM3  > 0
							oModelITC:loadvalue('ITC_M3',val(alltrim((cAlias3)->m3)) - nM3 )
						else
							oModelITC:loadvalue('ITC_M3',0)
						endif

				else
					if val(alltrim((cAlias3)->m3)) - nM3 > oModelTMP:getvalue('TMP_CUBICO')  - nM3Prog
						oModelITC:loadvalue('ITC_M3',oModelTMP:getvalue('TMP_CUBICO')  - nM3Prog)
					else
						oModelITC:loadvalue('ITC_M3',val(alltrim((cAlias3)->m3)) - nM3)
					endif
				endif

				nPreveQtd :=  ((oModelITC:getvalue('ITC_M3') * val(alltrim((cAlias3)->qtde))) / val(alltrim((cAlias3)->m3)))

				if nPreveQtd - nQuant > 0
					oModelITC:loadvalue('ITC_QTD_VO',alltrim(str(CEILING(nPreveQtd))))
				else
					oModelITC:loadvalue('ITC_QTD_VO','')
				endif

				oModelITC:loadvalue('ITC_EMB',alltrim((cAlias)->embalagem))
			else
				lresult := .F.
			endif
	else
		oModelITC:loadvalue('ITC_LIT_DS','')
		oModelITC:loadvalue('ITC_QTD_VO','')
		oModelITC:loadvalue('ITC_EMB','')
		oModelITC:loadvalue('ITC_M3',0)
	endif

return lResult



static function VAL_LOT_ID()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelITC := oModel:getmodel('PRAA802ITC')
	Local oModelTMP := oModel:getmodel('PRAA802')
	Local calias := GetNextalias()
	Local cQuery := ''


	if alltrim(oModelITC:getvalue('ITC_LOT_ID')) <> ''
		if alltrim(oModelITC:getvalue('ITC_RES_NU')) <> ''
				cQuery := "			select distinct 							"
				cQuery += "			       a.latu_lote as num_lote,       "
				cQuery += "			       a.late_conhec as doc_lote,       "
				cQuery += "			       a.dent_format as doc_entrada,    "
				cQuery += "			       b.cli_id, "
				cQuery += "			       b.cli_nome, "
				cQuery += "			       c.res_id "
				cQuery += "			from vw_inventario_armazem a "
				cQuery += "			  inner join tab_clientes b "
				cQuery += "			    on a.ben_id = b.cli_id "
				cQuery += "			  inner join tab_reserva_doc_cnt c "
				cQuery += "			    on c.dent_id = a.dent_id "
				cQuery += "			where loclo_qt > 0   "
				cQuery += "			and b.cli_id = '" + alltrim(oModelTMP:getvalue('TMP_CLI_ID')) + "'"
				cQuery += "			and c.res_id = " +  alltrim(oModelITC:getvalue('ITC_RES_ID'))
				cQuery += "          and a.latu_lote = '" + alltrim(oModelITC:getvalue('ITC_LOT_ID')) + "'"
				cQuery += "          and a.esp_id not in ('CC','OE')  "

	    else
	    		if 	Empty(oModelTMP:getvalue('TMP_CLI_ID'))
	    			//alert('Operação negada. Preencha o cliente de carga para pesquisar o lote.')
	    			oModel:SetErrorMessage('PRAA802ITC','ITC_LT_ID','','','3001','Operação negada.','Preencha o cliente de carga para pesquisar o lote.',nil,nil)
	    			return .F.
	    		endif
	    		cQuery := "			select distinct
				cQuery += "					       a.latu_lote as num_lote,   "
				cQuery += "					       a.late_conhec as doc_lote,  "
				cQuery += "					       a.dent_format as doc_entrada, "
				cQuery += "					       b.cli_id, "
				cQuery += "					       b.cli_nome "
				cQuery += "					from vw_inventario_armazem a "
				cQuery += "					  inner join tab_clientes b "
				cQuery += "					    on a.ben_id = b.cli_id "
				cQuery += "                   where loclo_qt > 0 "
				//cQuery += "			and b.cli_id = '" + alltrim(oModelTMP:getvalue('TMP_CLI_ID')) + "'"
				cQuery += "          and a.latu_lote = '" + alltrim(oModelITC:getvalue('ITC_LOT_ID')) + "'"
				cQuery += "          and a.esp_id not in ('CC','OE')  "
		endif

		if alltrim(oModelITC:getvalue('ITC_DP_DS')) <> ''
					cQuery += "		and exists (select 1  "
					cQuery += "		            from tab_di_item c "
					cQuery += "		            where c.latu_lote = a.latu_lote "
					cQuery += "		            and c.latu_item = a.latu_item "
					cQuery += "		            and c.dsai_id = '" + alltrim(oModelITC:getvalue('ITC_DP_DS')) + "')"
		endif

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		if alltrim((cAlias)->num_lote) <> ''
			 oModelITC:loadvalue('ITC_LOT_ID',alltrim((cAlias)->num_lote))
			 oModelITC:loadvalue('ITC_LOT_IT','')
			 oModelITC:loadvalue('ITC_LIT_DS','')
			 oModelITC:loadvalue('ITC_QTD_VO','')
			 oModelITC:loadvalue('ITC_EMB','')
			 oModelITC:loadvalue('ITC_M3',0)
		else
			lresult := .F.
		endif
	else
		oModelITC:loadvalue('ITC_LOT_ID','')
		oModelITC:loadvalue('ITC_LOT_IT','')
		oModelITC:loadvalue('ITC_LIT_DS','')
		oModelITC:loadvalue('ITC_QTD_VO','')
		oModelITC:loadvalue('ITC_EMB','')
		oModelITC:loadvalue('ITC_M3',0)
	endif

return lResult

static function WHEN_DOC_RES()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelDOC := omodel:getmodel('PRAA802DOC')
	Local oModelITC := omodel:getmodel('PRAA802ITC')
	Local nI := 0

	if alltrim(oModelITC:getvalue('ITC_DP_DS')) <> ''
		For nI := 1 To oModelDOC:Length()
		    oModelDOC:GoLine(nI)
		    If .Not. oModelDOC:IsDeleted()
		       if alltrim(oModelITC:getvalue('ITC_DP_DS')) = alltrim(oModelDOC:getvalue('DOC_DOC_ID'))
			    	if alltrim(oModelDOC:getvalue('DOC_RES_ID')) <> ''
			    		lResult := .F.
			    	endif
		    	endif
		    endif
		next nI
	endif
return lResult

static function WHEN_CNT_ITC()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelDOC := omodel:getmodel('PRAA802DOC')

	if alltrim(oModelDOC:getvalue('ITC_DP_DS')) <> ''
		lResult := .F.
	endif

return lResult


static function A802ITDPST(oModelDOC)
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:getmodel('PRAA802')
	Local oModelITD := oModel:getmodel('PRAA802ITD')
	Local nI := 0
	Local nqtd := 0
	Local nPeso := 0

	if !Empty(oModelTMP:getvalue('TMP_OPE_ID')).And. Val(oModelTMP:getvalue('TMP_OPE_ID')) != 1
		if alltrim(oModelITD:GetValue('ITD_ESP_ID')) <> '' .or. alltrim(oModelITD:GetValue('ITD_FAM_ID')) <> ''
			if alltrim(oModelITD:GetValue('ITD_DP_DS')) = ''
				    	oModel:SetErrorMessage('PRAA802ITD','ITD_DP_DS','','','3002','O campo Documento não foi preenchido.','Insira o documento no grid de Recebim. c. solta',nil,nil)
				    	return .F.
			endif
		endif

		if alltrim(oModelITD:GetValue('ITD_DP_DS')) <> '' .or. alltrim(oModelITD:GetValue('ITD_FAM_ID')) <> ''
			if alltrim(oModelITD:GetValue('ITD_ESP_ID')) = ''
				    	oModel:SetErrorMessage('PRAA802ITD','ITD_ESP_ID','','','3003','O campo Cód. espécie não foi preenchido.','Insira o Cód. espécie no grid de Recebim. c. solta',nil,nil)
				    	return .F.
			endif
		endif

		if alltrim(oModelITD:GetValue('ITD_DP_DS')) <> '' .or. alltrim(oModelITD:GetValue('ITD_ESP_ID')) <> ''
			if alltrim(oModelITD:GetValue('ITD_QTD_VO')) = ''
				    	oModel:SetErrorMessage('PRAA802ITD','ITD_QTD_VO','','','3004','O campo Volume não foi preenchido.','Insira o Volume no grid de Recebim. c. solta',nil,nil)
				    	return .F.
			endif

			if oModelITD:GetValue('ITD_M3') = 0
			    	oModel:SetErrorMessage('PRAA802ITD','ITD_M3','','','3005','O campo Metros cúbico não foi preenchido.','Insira o Metros cúbico no grid de Recebim. c. solta',nil,nil)
			    	return .F.
			endif
		endif



		if alltrim(SGetParam('PLANEJAMENTO_OPERACIONAL_DESCARGA_CARGA')) = 'S' .and. ( oModelTMP:getvalue('TMP_PESO') <> 0 .or. 	oModelTMP:getvalue('TMP_CUBICO') <> 0 )
			if !Empty(oModelTMP:getvalue('TMP_OPE_ID')).And. Val(oModelTMP:getvalue('TMP_OPE_ID')) = 2

							For nI := 1 To oModelITD:Length()
								oModelITD:GoLine(nI)
								if oModelITD:IsDeleted() = .F.
									nqtd  += oModelITD:GetValue('ITD_M3')
									nPeso += oModelITD:GetValue('ITD_PESO')
								endif
							Next nI

						   //verifica se o volume do agendamento esta => ao irformado nos itens de carga
				 			if nqtd > oModelTMP:getvalue('TMP_CUBICO')
				 				oModel:SetErrorMessage('PRAA802ITD','ITD_M3','','','3006','Metragem cúbica maior que o estabelecido na programação.' ,'Metragem cúbica dos itens de descarga: ' + alltrim(str(nqtd)) + chr(13)+chr(10) + 'Metragem cúbica da programação: ' + alltrim(str(oModelTMP:getvalue('TMP_CUBICO'))) + '.',nil,nil)
								Return .F.
				 			endif

				 			if nPeso > oModelTMP:getvalue('TMP_PESO')
				 				oModel:SetErrorMessage('PRAA802ITD','ITD_PESO','','','3007','Peso maior que o estabelecido na programação.' ,'Peso dos itens de descarga: ' + alltrim(str(nPeso)) + ' kg.'+  chr(13)+chr(10) + 'Peso da programação: ' + alltrim(str(oModelTMP:getvalue('TMP_PESO'))) + ' kg.',nil,nil)
								Return .F.
				 			endif
			endif
		endif
	endif
return lResult


static function A802ITCPST(oModelDOC)
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:getmodel('PRAA802')
	Local oModelITC := oModel:getmodel('PRAA802ITC')
	Local cLoteval := ''
	Local cItemval := ''
	Local cItemDes := ''
	Local nVolCarga := 0
	Local nqtdVolCarga := 0
	Local nop := oModel:getoperation()
	Local cQuery := ''
	Local cAlias2 := getnextalias()
	Local nI := 0
	Local nVolArmazem := 0
	Local nqtd := 0
	Local nQtdArmazem := 0
	Local cAlias10 := getnextalias()

	if !Empty(oModelTMP:getvalue('TMP_OPE_ID')).And. Val(oModelTMP:getvalue('TMP_OPE_ID')) != 2
		if alltrim(oModelITC:getvalue('ITC_DP_DS')) <> '' .or. alltrim(oModelITC:getvalue('ITC_RES_NU')) <> ''  .or. alltrim(oModelITC:getvalue('ITC_LOT_ID')) <> ''
			if alltrim(oModelITC:getvalue('ITC_QTD_VO')) = ''
					oModel:SetErrorMessage('PRAA802ITC', 'ITC_QTD_VO',,,,'O campo Quantidade não preenchido.' )
					Return .F.
			endif

			if oModelITC:getvalue('ITC_M3') = 0
					oModel:SetErrorMessage('PRAA802ITC', 'ITC_M3',,,,'O campo Metros cúbicos não preenchido.' )
					Return .F.
			endif
		endif


		//if alltrim(SGetParam('PLANEJAMENTO_OPERACIONAL_DESCARGA_CARGA')) = 'S'
		if alltrim(SGetParam('PLANEJAMENTO_OPERACIONAL_DESCARGA_CARGA')) = 'S' .and. (oModelTMP:getvalue('TMP_PESO') <> 0 .or. 	oModelTMP:getvalue('TMP_CUBICO') <> 0 )
			cLoteval := alltrim(oModelITC:getvalue('ITC_LOT_ID'))
			cItemval := alltrim(oModelITC:getvalue('ITC_LOT_IT'))
			cItemDes := alltrim(oModelITC:getvalue('ITC_LIT_DS'))
			if !Empty(oModelTMP:getvalue('TMP_OPE_ID')).And. Val(oModelTMP:getvalue('TMP_OPE_ID')) = 1 .and. cLoteval <> '' .and. cItemval <> ''

							For nI := 1 To oModelITC:Length()
								oModelITC:GoLine(nI)
								if oModelITC:IsDeleted() = .F.  .and. alltrim(oModelITC:getvalue('ITC_LOT_ID')) = cLoteval .and. cItemval = alltrim(oModelITC:getvalue('ITC_LOT_IT'))
									nVolCarga += oModelITC:GetValue('ITC_M3')
									nqtdVolCarga += val(alltrim(oModelITC:GetValue('ITC_QTD_VO')))
									nqtd += oModelITC:GetValue('ITC_M3')
								elseif oModelITC:IsDeleted() = .F.
									nqtd += oModelITC:GetValue('ITC_M3')
								endif
							Next nI

						   //verifica se o volume do agendamento esta igual ou maior ao irformado nos itens de carga
				 			if nqtd > oModelTMP:getvalue('TMP_CUBICO')
				 				oModel:SetErrorMessage('PRAA802ITC','ITC_M3','','','3008','Volume maior que o estabelecido na programação.' ,'Volume dos itens de carga: ' + alltrim(str(nqtd)) + chr(13)+chr(10) + 'Volume da programação: ' + alltrim(str(oModelTMP:getvalue('TMP_CUBICO'))) + '.',nil,nil)
								Return .F.
				 			endif

				 			//verifica se o volume informado nos itens de carga esta disponivel no armazem
				 			cQuery := " select latu_lote, loclo_m3_saldo, loclo_qt from 	vw_inventario_armazem where latu_lote = '" +alltrim(oModelITC:GetValue('ITC_LOT_ID'))+ "' and latu_item = " + alltrim(oModelITC:GetValue('ITC_LOT_IT'))
						   DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias10,.F.,.T.)
						   if alltrim((cAlias10)->latu_lote) <> ''
						   		nVolArmazem := (cAlias10)->loclo_m3_saldo
						   		nQtdArmazem := (cAlias10)->loclo_qt
						   endif

				 			cQuery := " select  isnull(sum(pic_m3),0) as pic_m3, isnull(sum(pic_qt_volumes),0) as pic_qt_volumes from tab_programacao_itens_carga "
						   cQuery +=  " where lote_id = '" + alltrim(oModelITC:GetValue('ITC_LOT_ID')) + "' and lote_item = " + oModelITC:GetValue('ITC_LOT_IT')
				 			if nop = 4
				 				cQuery += " and prog_id <> " + alltrim(omodelTMP:getvalue('TMP_PRG_ID'))
				 			endif
				 			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias2,.F.,.T.)

				 			if (nVolArmazem - (cAlias2)->pic_m3) < nVolCarga
				 				oModel:SetErrorMessage('PRAA802ITC','ITC_M3','','','3009','O volume (metros cúbicos) do lote ' + cLoteval + ' e item ' + cItemDes + '  está indisponível armazém.' ,'Volume disponível no estoque: ' + alltrim(str(nVolArmazem - (cAlias2)->pic_m3)) + '.' + chr(13)+chr(10) + "Volume total informado na programação: " + alltrim(str(nVolCarga)),nil,nil)
								Return .F.
				 			endif


				 			if (nQtdArmazem - (cAlias2)->pic_qt_volumes) < nqtdVolCarga
				 				oModel:SetErrorMessage('PRAA802ITC', 'ITC_QTD_VO','','','3010','O item ' + cItemval + ' do lote ' + cLoteval +  ' está indisponível armazém.','Quantidade disponível no estoque: ' + alltrim(str(nQtdArmazem - (cAlias2)->pic_qt_volumes))+ '.'  + chr(13)+chr(10) + "Quantidade total informada na programção: " +  alltrim(str(nqtdVolCarga)) + '.',nil,nil)
								Return .F.
				 			endif
			endif
		endif
	endif

return lResult

static function A802ITCPER(oModelDOC)
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:GetModel('PRAA802')

	if !Empty(oModelTMP:getvalue('TMP_OPE_ID')).And. Val(oModelTMP:getvalue('TMP_OPE_ID')) = 2 .and.  A802EXIST('PRAA802ITC') = .F.
		alert('Para operação de descarga não é permitido item de carga.')
		Return .F.
	endif

	lResult := A802PREVLD(oModel,'PRAA802ITC')
return lResult


static function A802EXIST(cModelo)
	Local lResult := .F.
	Local oModel    := FWModelActive()
	Local oModelITD := omodel:getmodel('PRAA802ITD')
	Local oModelITC := omodel:getmodel('PRAA802ITC')
	Local nI := 0

	if cModelo = 'PRAA802ITD'
		For nI := 1 To oModelITD:Length()
				oModelITD:GoLine(nI)
				If  .not. oModelITD:IsDeleted() .and. ( alltrim(oModelITD:getvalue('ITD_DP_DS')) != '' ;
				    .or. alltrim(oModelITD:getvalue('ITD_QTD_VO')) != '' )
					return .T.
				endif
		next nI
	endif


	if cModelo = 'PRAA802ITC'
		For nI := 1 To oModelITC:Length()
				oModelITC:GoLine(nI)
				If  .not. oModelITC:IsDeleted() .and. ( alltrim(oModelITC:getvalue('ITC_DP_DS')) != '' ;
				    .or. alltrim(oModelITC:getvalue('ITC_QTD_VO')) != '' .or. alltrim(oModelITC:getvalue('ITC_LOT_ID')) != '' )
					return .T.
				endif
		next nI
	endif

return lResult
static function A802ITDPER(oModelDOC)
	Local oModel     := FWModelActive()
	Local oModelTMP  := oModel:getmodel('PRAA802')
	Local lResult := .T.

 	If(!Empty(oModelTMP:getvalue('TMP_OPE_ID')) .And. (Val(oModelTMP:getvalue('TMP_OPE_ID')) == 1 ) .and.  (A802EXIST('PRAA802ITD') == .F.))
		alert('Para operação de carga não é permitido item de descarga.')
		return .F.
	EndIf
	
	If(alltrim(SGetParam('PLANEJAMENTO_OPERACIONAL_DESCARGA_CARGA')) = 'S')
		if oModelTMP:getvalue('TMP_PESO') <> 0 .or. 	oModelTMP:getvalue('TMP_CUBICO') <> 0
			if(oModelTMP:getvalue('TMP_PESO') == 0)
				alert('Antes de adicionar um item, o campo Peso deve ser preenchido.')
				return .F.
			elseif(oModelTMP:getvalue('TMP_CUBICO') == 0)
				alert('Antes de adicionar um item, o campo Metragem cúbica deve ser preenchido.')
				return .F.
			endif
		endif
	endif
	lResult := A802PREVLD(oModel,'PRAA802ITD')
return lResult


static function VAL_DOC_ID(cModel)
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelGEN := nil
	Local oModelDOC := oModel:getmodel('PRAA802DOC')
	Local oModelITC := oModel:getmodel('PRAA802ITC')
	Local oModelTMP := oModel:getmodel('PRAA802')
	Local cAlias := GetNextAlias()
	Local nI := 0
	Local existe := .F.
	Local resultado := ''
	Private cdigito := ''

	if cModel = 'PRAA802ITC'
		oModelGEN := oModel:getmodel('PRAA802ITC')
		if alltrim(oModelGEN:getvalue('ITC_DP_DS')) <> ''

			if alltrim(oModelITC:getvalue('ITC_RES_ID')) = ''
				if alltrim(omodelTMP:getvalue('TMP_CLI_ID')) = ''
			   	   oModel:SetErrorMessage('PRAA802ITC','ITC_DP_DS','','','3011', "Operação negada.","Informe o cliente de carga para pesquisar o documento de carga.",nil)
			   	   return .F.
			    endif

			   cSql :=  		  "     select distinct a.dsai_id, "
			   cSql +=		  	  "	       d.cli_id, "
				cSql +=		  "		       d.cli_nome  "
				cSql +=		  "		from tab_di_item a "
				cSql +=		  "  inner join vw_inventario_armazem b "
				cSql +=		  "	    on b.latu_lote = a.latu_lote and "
				cSql +=		  "	       b.latu_item = a.latu_item "
				cSql +=		  "	  inner join tab_doc_saida c "
				cSql +=		  "	    on c.dsai_id = a.dsai_id "
				cSql +=		  "	  inner join tab_clientes d "
				cSql +=		  "	    on d.cli_id = c.ben_id  "
			    //cSql +=         " where d.cli_id = '" +alltrim(oModelTMP:getvalue('TMP_CLI_ID')) + "'"
			    cSql +=         " where   a.dsai_id = '" +alltrim(oModelITC:getvalue('ITC_DP_DS'))+ "'"
		   else
				cSql := "		   		select distinct a.dsai_id,           "
				cSql += "				       c.res_id	"
				cSql += "				from tab_di_item a "
				cSql += "				  inner join vw_inventario_armazem b "
				cSql += "				    on b.latu_lote = a.latu_lote and "
				cSql += "				       b.latu_item = a.latu_item "
				cSql += "				  inner join tab_reserva_doc_cnt c "
				cSql += "				    on c.dent_id = b.dent_id "
				cSql += "				where res_id = " + alltrim(oModelITC:getvalue('ITC_RES_ID'))
				cSql +=         " and   a.dsai_id = '" +alltrim(oModelITC:getvalue('ITC_DP_DS'))+ "'"
		   endif

			dbUseArea(.T., 'TOPCONN', TCGenQry(,,cSql),cAlias, .F., .T.)

			///////////////////////////////////////////////////////////////////////////////
			/////////////////Incio verifiacao se o documento esta na gride de documento///
			//////////////////////////////////////////////////////////////////////////////
			if alltrim((cAlias)->dsai_id) <> ''
				For nI := 1 To oModelDOC:Length()
	                  oModelDOC:GoLine(nI)
	                  if (alltrim(omodeldoc:getvalue('DOC_DOC_ID')) = '' )
	                  	If .Not. oModelDOC:IsDeleted() .and. AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) <> ''
						      	   /*if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = ''
						          		oModel:SetErrorMessage('PRAA802ITC','ITC_DP_ID','','','3012', "Na grid 'Documentos', o campo 'Tipo e/s' dos documentos deve ser preenchido",nil,nil)
						          		return .F.
						          else*/
						          if AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) = ''
						          		oModel:SetErrorMessage('PRAA802ITC','ITC_DP_ID','','','3013', "No grid de Documentos o campo 'Nr. doc.' dos documentos deve ser preenchido",nil,nil)
						          		return .F.
						          elseif AllTrim(oModelDOC:GetValue('DOC_ANO_DC')) = ''
						          		oModel:SetErrorMessage('PRAA802ITC','ITC_DP_ID','','','3014', "No grid de Documentos o campo 'Ano' dos documentos deve ser preenchido",nil,nil)
						          		return .F.
						          else
						          		if AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) = ''
						          			oModel:SetErrorMessage('PRAA802ITC','ITC_DP_ID','','','3015',"No grid Documentos o campo 'Tp. doc.' dos documentos deve ser preenchido",nil,nil)
							          		return .F.
							          endif
						          endif

							   	   resultado :=  pst_tabd2()
							      if substr(resultado,1,5) = 'ERROR'
							      	  if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = 'E'
								   	  	  oModel:SetErrorMessage('PRAA802ITC','ITC_DP_ID','','','3016','No grid de documentos, ocorreu um erro no documento de entrada de tipo ' + AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) + ' e de Número ' + AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) + '.' + chr(13)  + 'Erro: ' + substr(resultado,6,len(resultado)),nil,nil)
								   	  else
								   	      oModel:SetErrorMessage('PRAA802ITC','ITC_DP_ID','','','3017','No grid de documentos, ocorreu um erro no documento de saida de tipo ' + AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) + ' e de Número ' + AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) + '.' + chr(13)  + 'Erro: ' + substr(resultado,6,len(resultado)),nil,nil)
								   	  endif
								   	  return .F.
								   else
					                 //if alltrim(oModelGEN:getvalue('ITC_DP_DS')) = alltrim((cAlias)->dsai_id)
					                 if AllTrim(resultado) = alltrim((cAlias)->dsai_id)
			                        	 	//oModelGEN:loadvalue('ITC_RES_ID',AllTrim(oModelDOC:GetValue('DOC_RES_ID')))
											//oModelGEN:loadvalue('ITC_RES_NU',AllTrim(oModelDOC:GetValue('DOC_RES_NU')))
					                   	existe := .T.
					                 EndIF
							      endif
						   endif
	                  else
	                     If .Not. oModelDOC:IsDeleted()
	                        if alltrim((cAlias)->dsai_id) = AllTrim(oModelDOC:GetValue('DOC_DOC_ID'))
	                        	 	existe := .T.
	                        	 	//oModelGEN:loadvalue('ITC_RES_ID',AllTrim(oModelDOC:GetValue('DOC_RES_ID')))
									//oModelGEN:loadvalue('ITC_RES_NU',AllTrim(oModelDOC:GetValue('DOC_RES_NU')))
	                        endif
	                     EndIf
	                 EndIf
		         Next nI
	         endif

	         //////////////////////////////////////////////////////////////////////////////
	         ///// Final da verificacao se o documento esta na grid de documentos/////////
			  //////////////////////////////////////////////////////////////////////////////

			if .not. existe
					//oModel:SetErrorMessage('PRAA802ITC','ITC_DP_DS','','','3000','O documento ' + alltrim((cAlias)->dsai_id) + ' não informado no grid de Documentos.' ,'Insira o documento ' + alltrim((cAlias)->dsai_id)  + ' no grid de documentos.',nil,nil)
					Alert('O documento ' + alltrim((cAlias)->dsai_id) + ' não informado no grid de Documentos.')
					oModelGEN:loadvalue('ITC_DP_DS','')
					oModelGEN:loadvalue('ITC_DP_ID','')
					return .T.
			endif

			if alltrim((cAlias)->dsai_id) <> ''
				if alltrim((cAlias)->dsai_id) != alltrim(oModelGEN:getvalue('ITC_DP_DS'))
					oModelGEN:loadvalue('ITC_LOT_ID','')
					oModelGEN:loadvalue('ITC_LOT_IT','')
					oModelGEN:loadvalue('ITC_LIT_DS','')
					oModelGEN:loadvalue('ITC_QTD_VO','')
					oModelGEN:loadvalue('ITC_M3',0)
				endif

				oModelGEN:loadvalue('ITC_DP_DS',alltrim((cAlias)->dsai_id))
			else
				lResult := .F.
			endif

		else
			oModelGEN:loadvalue('ITC_DP_DS','')
			oModelGEN:loadvalue('ITC_DP_ID','')
		endif

   elseif cModel = 'PRAA802CNT'
		oModelGEN := omodel:getmodel('PRAA802CNT')
		if alltrim(oModelGEN:getvalue('CNT_DP_DS')) <> ''
			
		 if alltrim(FwFldGet("TMP_OPE_ID")) == '2' //Descarga   	
			if alltrim(oModelGEN:getvalue('CNT_RES_ID')) = ''
				if alltrim(omodelTMP:getvalue('TMP_CLI_ID')) = ''
			   	   oModel:SetErrorMessage('PRAA802CNT','CNT_DP_DS','','','3018', "Operação negada.","Informe o cliente de carga para pesquisar o documento de carga.",nil)
			   	   return .F.
			    endif

			   cSql :=  		  "     select distinct a.dsai_id, "
			   cSql +=		  	  "	       d.cli_id, "
				cSql +=		  "		       d.cli_nome  "
				cSql +=		  "		from tab_di_item a "
				cSql +=		  "  inner join vw_inventario_armazem b "
				cSql +=		  "	    on b.latu_lote = a.latu_lote and "
				cSql +=		  "	       b.latu_item = a.latu_item "
				cSql +=		  "	  inner join tab_doc_saida c "
				cSql +=		  "	    on c.dsai_id = a.dsai_id "
				cSql +=		  "	  inner join tab_clientes d "
				cSql +=		  "	    on d.cli_id = c.ben_id  "
			    cSql +=         " where d.cli_id = '" +alltrim(oModelTMP:getvalue('TMP_CLI_ID')) + "'"
			    cSql +=         " and   a.dsai_id = '" +alltrim(oModelGEN:getvalue('CNT_DP_DS'))+ "'"
		   else
				cSql := "		   		select distinct a.dsai_id,           "
				cSql += "				       c.res_id	"
				cSql += "				from tab_di_item a "
				cSql += "				  inner join vw_inventario_armazem b "
				cSql += "				    on b.latu_lote = a.latu_lote and "
				cSql += "				       b.latu_item = a.latu_item "
				cSql += "				  inner join tab_reserva_doc_cnt c "
				cSql += "				    on c.dent_id = b.dent_id "
				cSql += "				where res_id = " + alltrim(oModelGEN:getvalue('CNT_RES_ID'))
				cSql +=         " and   a.dsai_id = '" + alltrim(oModelGEN:getvalue('CNT_DP_DS'))+ "'"
		   endif
		 else
			if alltrim(oModelGEN:getvalue('CNT_RES_ID')) = ''
			cSql := " select  distinct isnull(e.dsai_id,'') as dsai_id         "+;
			"from tab_reserva_doc_cnt a "+; 
			"inner join rel_dent_cnt b "+; 
			"  on b.dent_id = a.dent_id "+; 
			"inner join tab_di_item c "+;  
			"  on c.latu_lote = b.lote_id "+;    
			"inner join tab_doc_saida e "+; 
			"  on e.dsai_id = c.dsai_id "+;  
			"where " +;   		   		
			" e.dsai_id = '" + alltrim(oModelGEN:getvalue('CNT_DP_DS'))+ "'"					
			else
					 
			cSql := " select  distinct isnull(e.dsai_id,'') as dsai_id         "+;
			"from tab_reserva_doc_cnt a "+; 
			"inner join rel_dent_cnt b "+; 
			"  on b.dent_id = a.dent_id "+; 
			"inner join tab_di_item c "+;  
			"  on c.latu_lote = b.lote_id "+;    
			"inner join tab_doc_saida e "+; 
			"  on e.dsai_id = c.dsai_id "+;  
			"where a.res_id  = " + alltrim(oModelGEN:getvalue('CNT_RES_ID')) +;   		   		
			" and  e.dsai_id = '" + alltrim(oModelGEN:getvalue('CNT_DP_DS'))+ "'"		
			endif	
   		 endif

			dbUseArea(.T., 'TOPCONN', TCGenQry(,,cSql),cAlias, .F., .T.)

			///////////////////////////////////////////////////////////////////////////////
			/////////////////Incio verifiacao se o documento esta na gride de documento///
			//////////////////////////////////////////////////////////////////////////////
			if alltrim((cAlias)->dsai_id) <> '' .Or. !Empty(oModelGEN:getvalue('CNT_DP_DS'))
				For nI := 1 To oModelDOC:Length()
		                  oModelDOC:GoLine(nI)
		                  if (alltrim(omodeldoc:getvalue('DOC_DOC_ID')) = '' )
		                  	If .Not. oModelDOC:IsDeleted() .and. AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) <> ''
							      	   /*if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = ''
							          		oModel:SetErrorMessage('PRAA802ITC','ITC_DP_ID','','','3000', "Na grid 'Documentos', o campo 'Tipo e/s' dos documentos deve ser preenchido",nil,nil)
							          		return .F.
							          else*/
							          if AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) = ''
							          		oModel:SetErrorMessage('PRAA802CNT','CNT_DP_DS','','','3019', "No grid de Documentos o campo 'Nr. doc.' dos documentos deve ser preenchido",nil,nil)
							          		return .F.
							          elseif AllTrim(oModelDOC:GetValue('DOC_ANO_DC')) = ''
							          		oModel:SetErrorMessage('PRAA802CNT','CNT_DP_DS','','','3020', "No grid de Documentos o campo 'Ano' dos documentos deve ser preenchido",nil,nil)
							          		return .F.
							          else
							          		if AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) = ''
							          			oModel:SetErrorMessage('PRAA802CNT','CNT_DP_DS','','','3021',"No grid Documentos o campo 'Tp. doc.' dos documentos deve ser preenchido",nil,nil)
								          		return .F.
								          endif
							          endif

								   	   resultado :=  pst_tabd2()
								      if substr(resultado,1,5) = 'ERROR'
								      	  if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = 'E'
									   	  	  oModel:SetErrorMessage('PRAA802CNT','CNT_DP_DS','','','3022','No grid de documentos, ocorreu um erro no documento de entrada de tipo ' + AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) + ' e de Número ' + AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) + '.' + chr(13)+chr(10)   + 'Erro: ' + substr(resultado,6,len(resultado)),nil,nil)
									   	  else
									   	      oModel:SetErrorMessage('PRAA802CNT','CNT_DP_DS','','','3023','No grid de documentos, ocorreu um erro no documento de saida de tipo ' + AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) + ' e de Número ' + AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) + '.' + chr(13)+chr(10)  + 'Erro: ' + substr(resultado,6,len(resultado)),nil,nil)
									   	  endif
									   	  return .F.
									   else
						                 //if alltrim(oModelGEN:getvalue('ITC_DP_DS')) = alltrim((cAlias)->dsai_id)
						                 if AllTrim(resultado) = alltrim((cAlias)->dsai_id) .Or. (oModelGEN:getvalue('CNT_DP_DS') == AllTrim(resultado) .And. AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) == 'E')
				                        	 	//oModelGEN:loadvalue('ITC_RES_ID',AllTrim(oModelDOC:GetValue('DOC_RES_ID')))
												//oModelGEN:loadvalue('ITC_RES_NU',AllTrim(oModelDOC:GetValue('DOC_RES_NU')))
						                   	existe := .T.
						                   	Exit
						                 EndIF
								      endif
							   endif
		                  else
		                     If .Not. oModelDOC:IsDeleted()
		                        if alltrim((cAlias)->dsai_id) == AllTrim(oModelDOC:GetValue('DOC_DOC_ID'));
		                        	.Or. AllTrim(oModelGEN:getvalue('CNT_DP_DS')) == AllTrim(oModelDOC:GetValue('DOC_DOC_ID'))
		                        	 	existe := .T.
		                        	 	Exit
		                        	 	//oModelGEN:loadvalue('ITC_RES_ID',AllTrim(oModelDOC:GetValue('DOC_RES_ID')))
										//oModelGEN:loadvalue('ITC_RES_NU',AllTrim(oModelDOC:GetValue('DOC_RES_NU')))
		                        endif
		                     EndIf
		                 EndIf
		         Next nI
	         endif

	         //////////////////////////////////////////////////////////////////////////////
	         ///// Final da verificacao se o documento esta na grid de documentos/////////
			  //////////////////////////////////////////////////////////////////////////////

			if .not. existe
					//oModel:SetErrorMessage('PRAA802ITC','ITC_DP_DS','','','3000','O documento ' + alltrim((cAlias)->dsai_id) + ' não informado no grid de Documentos.' ,'Insira o documento ' + alltrim((cAlias)->dsai_id)  + ' no grid de documentos.',nil,nil)
					Alert('O documento ' + alltrim(oModelGEN:getvalue('CNT_DP_DS')) + ' não informado no grid de Documentos.')
					oModelGEN:loadvalue('CNT_DP_DS','')
					oModelGEN:loadvalue('CNT_DP_ID','')
					return .T.
			endif

			if alltrim((cAlias)->dsai_id) <> '' .Or. !Empty(oModelGEN:getvalue('CNT_DP_DS'))
				//if alltrim((cAlias)->dsai_id) != alltrim(oModelGEN:getvalue('CNT_DP_DS'))
					If AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) != 'E'
						oModelGEN:loadvalue('CNT_CNT_ID','')
						oModelGEN:loadvalue('CNT_TIS_TA','')
						oModelGEN:loadvalue('CNT_TISO_I','')
						oModelGEN:loadvalue('CNT_QTD_CN','')
					Else
						oModelGEN:loadvalue('CNT_CNTCHE','S')
					EndIf
				//endif

				oModelGEN:loadvalue('CNT_DP_DS',alltrim(oModelGEN:getvalue('CNT_DP_DS')))
				oModelGEN:LoadValue('CNT_DP_ID',AllTrim(omodeldoc:getvalue('DOC_DP_ID')))
			else
				lResult := .F.
			endif

		else
			oModelGEN:loadvalue('CNT_DP_DS','')
			oModelGEN:loadvalue('CNT_DP_ID','')
		endif
		//////////////////////////////////////////////
		////////////////////////////////////////////////

	elseif cModel = 'PRAA802ITD'
		oModelGEN := omodel:getmodel('PRAA802ITD')
		if alltrim(oModelGEN:getvalue('ITD_DP_DS')) <> ''
			   For nI := 1 To oModelDOC:Length()
	                  oModelDOC:GoLine(nI)
	                  if (alltrim(omodeldoc:getvalue('DOC_DOC_ID')) = '' )
	                  	If .Not. oModelDOC:IsDeleted()
						      	   if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = ''
						      	   		oModel:SetErrorMessage('PRAA802ITD',,,,'3024',"No grid 'Documentos', o campo 'Tipo e/s' dos documentos deve ser preenchido")
						          		return .F.
						          elseif AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) = ''
						          		oModel:SetErrorMessage('PRAA802ITD',,,,'3025',"No grid 'Documentos', o campo 'Nr. doc.' dos documentos deve ser preenchido")
						          		return .F.
						          elseif AllTrim(oModelDOC:GetValue('DOC_ANO_DC')) = ''
						          		oModel:SetErrorMessage('PRAA802ITD',,,,'3026',"No grid 'Documentos', o campo 'Ano' dos documentos deve ser preenchido")
						          		return .F.
						          elseif AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) = ''
						          		oModel:SetErrorMessage('PRAA802ITD',,,,'3027',,"No grid 'Documentos', o campo 'Tp. doc.' dos documentos deve ser preenchido")
						          		return .F.
						          endif

							   	   resultado :=  pst_tabd2()
							      if substr(resultado,1,5) = 'ERROR'
							      	  if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = 'E'
							      	  		oModel:SetErrorMessage('PRAA802ITD',,,,'3028','Erro no documento de entrada de tipo ' + AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) + ' e de Número ' + AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) + '.' + chr(13)+chr(10)  + 'Erro: ' + substr(resultado,6,len(resultado)))
								   	  else
								   	  		oModel:SetErrorMessage('PRAA802ITD',,,,'3029','Erro no documento de saida de tipo ' + AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) + ' e de Número ' + AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) + '.' + chr(13)+chr(10)  + 'Erro: ' + substr(resultado,6,len(resultado)))
								   	  endif

								   	  return .F.
								   else
					                 if alltrim(oModelGEN:getvalue('ITD_DP_DS')) = AllTrim(resultado)
					                 		if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = 'S'
					                 			oModel:SetErrorMessage('PRAA802ITD',,,,'3030',"No recebimento, não é possível informar um documento do tipo saída.")
							          			Return .F.
							          		EndIf
					                   	existe := .T.
					                     oModelGEN:loadvalue('ITD_DP_DS',AllTrim(resultado))
					                 EndIF
							      endif

						   endif
	                  else
	                     If .Not. oModelDOC:IsDeleted()
	                        if alltrim(oModelGEN:getvalue('ITD_DP_DS')) = AllTrim(oModelDOC:GetValue('DOC_DOC_ID'))
	                        		if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = 'S'
	                        			oModel:SetErrorMessage('PRAA802ITD',,,,'3000',"No recebimento, não é possível informar um documento do tipo saída.")
					          			Return .F.
					          		EndIf
	                        	 	existe := .T.
	                        	 	oModelGEN:loadvalue('ITD_DP_DS',AllTrim(oModelDOC:GetValue('DOC_DOC_ID')))
	                        	 	oModelGEN:setvalue('ITD_DP_DS',AllTrim(oModelDOC:GetValue('DOC_DOC_ID')))
	                        endif
	                     EndIf
	                 EndIf
	         Next nI

	        if existe = .F.
	        	 oModel:SetErrorMessage('PRAA802ITD',,,,'3000',"O documento deve estar informado na aba 'Documentos'.")
	         	 return .F.
	         endif

		else
			lResult := .T.
			oModelGEN:loadvalue('ITD_DP_ID','')
			oModelGEN:loadvalue('ITD_DP_DS','')
		endif
	endif
//	oView:GetViewObj(cModel)[3]:EvalWhen()
return lResult


static function VAL_FAM_ID()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelITD := oModel:GetModel('PRAA802ITD')
	Local cAlias := GetNextAlias()
	Local cQuery := ''

	if alltrim(oModelITD:getvalue('ITD_FAM_ID')) <> ''

		cQuery := " select fam_id, fam_desc_gen from tab_familias where fam_id = '" + alltrim(oModelITD:getvalue('ITD_FAM_ID')) + "'"
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		if alltrim((cAlias)->fam_id) <> ''
			oModelITD:loadvalue('ITD_FAM_DS',alltrim((cAlias)->fam_desc_gen))
		else
			lResult := .F.
			oModelITD:loadvalue('ITD_FAM_DS','')
		endif
	else
		oModelITD:loadvalue('ITD_FAM_DS','')
	endif
//	oView:GetViewObj('PRAA802ITD')[3]:EvalWhen()
return lResult

static function VAL_ESP_ID()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelITD := oModel:GetModel('PRAA802ITD')
	Local cAlias := GetNextAlias()
	Local cQuery := ''

	if alltrim(oModelITD:getvalue('ITD_ESP_ID')) <> ''

		cQuery := " select esp_id, esp_descricao from tab_especie where esp_id = '" + alltrim(oModelITD:getvalue('ITD_ESP_ID')) + "'"
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		if alltrim((cAlias)->esp_id) <> ''
			oModelITD:loadvalue('ITD_ESP_DS',alltrim((cAlias)->esp_descricao))
			oModelITD:loadvalue('ITD_ESP_ID',alltrim((cAlias)->esp_id))
		else
			lResult := .F.
			oModelITD:loadvalue('ITD_ESP_DS','')
			oModelITD:loadvalue('ITD_ESP_ID','')
		endif
	else
		oModelITD:loadvalue('ITD_ESP_DS','')
		oModelITD:loadvalue('ITD_ESP_ID','')
	endif
//	oView:GetViewObj('PRAA802ITD')[3]:EvalWhen()
return lResult




static function VAL_CNT_ID(cModel)
  Local lResult := .T.
  Local oModel    := FWModelActive()
  Local oModelGEN := nil
  Local oModelCNT := oModel:GetModel('PRAA802CNT')
  Local nI := 0
  Local existe := .F.
  Local nJ := 0  
  Private cdigito := ''

  if cModel = 'PRAA802ITC'
     oModelGEN := omodel:getmodel(cModel)
	 
     if alltrim(oModelGEN:getvalue('ITC_CNT_ID')) <> ''
     
        For nI := 1 To oModelCNT:Length()
	   
           oModelCNT:GoLine(nI)
	   	   
           If (AllTrim(oModelCNT:GetValue('CNT_CNT_ID')) <> '')
           
              If .Not. oModelCNT:IsDeleted()
                 if alltrim(oModelGEN:getvalue('ITC_CNT_ID')) = AllTrim(oModelCNT:GetValue('CNT_CNT_ID'))
                    existe := .T.
                    oModelGEN:loadvalue('ITC_CNT_ID',AllTrim(oModelCNT:GetValue('CNT_CNT_ID')))
                 endif
              EndIf
           
           else
	   	      
              If .Not. oModelCNT:IsDeleted()
	   	         
                 if (len(alltrim(oModelGEN:GetValue('ITC_CNT_ID'))) <> 11 )
                    oModel:SetErrorMessage('PRAA802ITC','ITC_CNT_ID','','','3031', STR0269 + chr(13)+chr(10) + STR0270,STR0271,nil,nil)
                    return .F.
                 endif
           
                 for nJ := 1 to 11
           
                    if nJ <= 4
                     
                       if isdigit(substring(alltrim(oModelGEN:GetValue('ITC_CNT_ID')),nJ,1))
                          oModel:SetErrorMessage('PRAA802ITC','ITC_CNT_ID','','','3032', STR0269 + chr(13)+chr(10) +STR0270,STR0271,nil,nil)
                          return .F.
                       endif
                       
                    endif
           
                    if nJ > 4
                       if isalpha(substring(alltrim(oModelGEN:GetValue('ITC_CNT_ID')),nJ,1))
                          oModel:SetErrorMessage('PRAA802ITC','ITC_CNT_ID','','','3033', STR0270 + chr(13)+chr(10) + STR0270,STR0271,nil,nil)
                          return .F.
                       endif
                    endif
	   			 
                 next nJ
           
                 if A802VALDIG(alltrim(oModelGEN:GetValue('ITC_CNT_ID'))) = .F.
	                oModel:SetErrorMessage('PRAA802CNT','ITC_CNT_ID','','','3000', STR0272,STR0273 + alltrim(cdigito) + chr(13)+chr(10) +;
											    					STR0274+chr(13)+chr(10)+ ;
						                                            STR0275,nil,nil)
						                    return .F.
                 else
                    if alltrim(oModelGEN:getvalue('ITC_CNT_ID')) = AllTrim(oModelCNT:GetValue('CNT_CNT_ID'))
                       existe := .T.
                       oModelGEN:loadvalue('ITC_CNT_ID',AllTrim(oModelCNT:GetValue('CNT_CNT_ID')) )
                    endif
	         endif
	   		  
              endif
	   		  
           endif
		
        next nI

        if existe = .F.
           lResult := .F.
        endif

     else
     
        lResult := .T.
        oModelGEN:loadvalue('ITC_CNT_ID','')
        oModelGEN:loadvalue('ITC_PRG_CN','')
     endif

  endif

return lResult

static function VAL_DENT_ID()
	Local lResult := .F.
	Local oModel    := FWModelActive()
	Local oModelITE := oModel:GetModel('PRAA802ITE')
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local cAlias := GetNextAlias()
	Local cQuery := ''
	Local nI := 0
	Local resultado := ''

	if alltrim(oModelITE:getvalue('ITE_DEN_ID')) <> ''

				cQuery := " select dent_id from rel_dent_programacao where dent_id = '" + alltrim(oModelITE:getvalue('ITE_DEN_ID')) + "'"
				dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

				if alltrim((cAlias)->dent_id) <> ''
					return .T.
				endif


				For nI := 1 To oModelDOC:Length()
	                  oModelDOC:GoLine(nI)
	                  If .Not. oModelDOC:IsDeleted()
	                  	If (AllTrim(oModelDOC:GetValue('DOC_DOC_ID')) <> '')
	                  	   if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = ''
					          		//alert("Na grid 'Documentos', o campo 'Tipo e/s' dos documentos deve ser preenchido")
					          		oModel:SetErrorMessage('PRAA802ITE','DOC_ANO_DC','','','3034', "No grid 'Documentos', o campo 'Tipo e/s' dos documentos deve ser preenchido",'',nil,nil)
					          		return .F.
					          elseif AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) = ''
					          		//alert("Na grid 'Documentos', o campo 'Nr. doc.' dos documentos deve ser preenchido")
					          		oModel:SetErrorMessage('PRAA802ITE','DOC_NUM_DC','','','3035', "No grid 'Documentos', o campo 'Nr. doc.' dos documentos deve ser preenchido",'',nil,nil)
					          		return .F.
					          elseif AllTrim(oModelDOC:GetValue('DOC_ANO_DC')) = ''
					          		//alert("Na grid 'Documentos', o campo 'Ano' dos documentos deve ser preenchido")
					          		oModel:SetErrorMessage('PRAA802ITE','DOC_ANO_DC','','','3036',"No grid 'Documentos', o campo 'Ano' dos documentos deve ser preenchido",'',nil,nil)
					          		return .F.
					          else
					          		if AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) = ''
					          			//alert("Na grid 'Documentos', o campo 'Tp. doc.' dos documentos deve ser preenchido")
						          		oModel:SetErrorMessage('PRAA802ITE','DOC_TPO_DC','','','3037', "No grid 'Documentos', o campo 'Tp. doc.' dos documentos deve ser preenchido",'',nil,nil)
					          		    return .F.
						          endif
					          endif

	                        if alltrim(oModelITE:getvalue('ITE_DEN_ID')) = AllTrim(oModelDOC:GetValue('DOC_DOC_ID'))

	                        	 	lResult := .T.
	                        endif
	                     else
	                     	resultado := pst_tabd2()
		                     if substr(resultado,1,5) != 'ERROR'
		                     	lresult := .T.
		                     endif
	                     EndIf
	                 EndIf
	           Next nI

	else
		lResult := .T.
	endif

	if lResult = .T.
//		oView:GetViewObj('PRAA802ITE')[3]:EvalWhen()
	endif
return lResult

static function WHEN_PROC()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local oModelITC := oModel:GetModel('PRAA802ITC')
	Local oModelITD := oModel:GetModel('PRAA802ITD')
	Local nI := 0
	Local bError := errorBlock({|e|erro(e)})


	BEGIN SEQUENCE
		oModelITD := oModel:GetModel('PRAA802ITD')

		if (alltrim(oModelDOC:getvalue('DOC_TPO_DC')) = 'NF') .or. (alltrim(oModelDOC:getvalue('DOC_TPO_ES')) = 'S')
			lResult := .F.
		else
			For nI := 1 To oModelITD:Length()
				oModelITD:GoLine(nI)
				If .Not. oModelITD:IsDeleted() .and. alltrim(oModelITD:getvalue('ITD_DP_DS')) <> '' .and. alltrim(oModelITD:getvalue('ITD_DP_DS')) = alltrim(oModelDOC:getvalue('DOC_DOC_ID'))
					alert('Operação negada. Existe item de descarga pertinente a este documento.')
					lResult := .F.
				endif

				If .Not. oModelITC:IsDeleted() .and. alltrim(oModelITC:getvalue('ITC_DP_DS')) <> '' .and. alltrim(oModelITC:getvalue('ITC_DP_DS')) = alltrim(oModelDOC:getvalue('DOC_DOC_ID'))
					alert('Operação negada. Existe item  de carga pertinente a este documento.')
					lResult := .F.
				endif
			next nI
		endif

	END SEQUENCE
	ErrorBlock(bError)
return lResult

static function WHEN_TES()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:GetModel('PRAA802')
	Local bError := errorBlock({|e|erro(e)})

	BEGIN SEQUENCE
	if !Empty(oModelTMP:getvalue('TMP_OPE_ID')).And. (Val(oModelTMP:getvalue('TMP_OPE_ID')) = 1 .or. Val(oModelTMP:getvalue('TMP_OPE_ID')) = 2)
		lResult := .F.
	endif
	END SEQUENCE
	ErrorBlock(bError)
return lResult

static function WHEN_SER()
    Local lResult := .F.
	Local oModel    := FWModelActive()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local oModelITC := oModel:GetModel('PRAA802ITC')
	Local oModelITD := oModel:GetModel('PRAA802ITD')
	Local nI := 0
	Local bError := errorBlock({|e|erro(e)})

	BEGIN SEQUENCE

	if alltrim(oModelDOC:getvalue('DOC_TPO_DC')) = 'NF'
		lResult := .T.


		For nI := 1 To oModelITD:Length()
			oModelITD:GoLine(nI)
			If .Not. oModelITD:IsDeleted() .and. alltrim(oModelITD:getvalue('ITD_DP_DS')) <> '' .and. alltrim(oModelITD:getvalue('ITD_DP_DS')) = alltrim(oModelDOC:getvalue('DOC_DOC_ID'))
				alert('Operação negada. Existe item de descarga pertinente a este documento.')
				lResult := .F.
			endif

			If .Not. oModelITC:IsDeleted() .and. alltrim(oModelITC:getvalue('ITC_DP_DS')) <> '' .and. alltrim(oModelITC:getvalue('ITC_DP_DS')) = alltrim(oModelDOC:getvalue('DOC_DOC_ID'))
				alert('Operação negada. Existe item  de carga pertinente a este documento.')
				lResult := .F.
			endif
		next nI
	endif


	END SEQUENCE
	ErrorBlock(bError)
return lResult

static function WHEN_TIPOES()

return .T.
static function WHEN_BEN()
   Local lResult := .F.
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:GetModel('PRAA802DOC')
	Local bError := errorBlock({|e|erro(e)})

	BEGIN SEQUENCE

	if alltrim(oModelTMP:getvalue('DOC_TPO_DC')) = 'NF'
		lResult := .T.
	endif

	END SEQUENCE
	ErrorBlock(bError)

return lResult

static function VAL_ANO()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')

	if (val(alltrim(oModelDOC:getvalue('DOC_ANO_DC'))) < 1500) .or. (val(alltrim(oModelDOC:getvalue('DOC_ANO_DC'))) > YEAR(DATE()) )
		oModel:SetErrorMessage('PRAA802DOC','DOC_ANO_DC','','','3038', 'Ano inválido.','Ano inválido.',nil,nil)
		return .F.
	endif
	A802DELREGS()
	oModelDOC:setvalue('DOC_DOC_ID','')
return lResult

static function A802CANCEL(oModel)
return .T.

static function WHEN_DOC_CFOP()
	Local lResult := .F.
	Local oModel    := FWModelActive()
	Local oModelTMP := nil
	Local bError := errorBlock({|e|erro(e)})

	BEGIN SEQUENCE
	    //if nOp <> 3
			oModelTMP := oModel:GetModel('PRAA802DOC')
		 	//cQuery := " select convert(varchar(50),dt_liberacao) as  dt_liberacao from tab_programacao where prog_id = " + alltrim(oModelTMP:getvalue('TMP_PRG_ID'))
			//dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
			if alltrim(oModelTMP:getvalue('DOC_TPO_DC'))  = 'NF'
					lResult := .T.
			endif
		//endif
    END SEQUENCE
    ErrorBlock(bError)
return lResult



/*/{Protheus.doc} WHEN_LIBERA
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Verifica se pode alterar alguns campos se a programação
/*/
static function WHEN_LIBERA()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local nOp := oModel:getOperation()
	Local oModelTMP := nil
	Local cAlTmp := GetNextAlias()
	Local oView    := FWViewActive()
	Local cQuery := ''
	Local bError := errorBlock({|e|erro(e)})
	Local cOpId
	Local nFolCar := 4
	Local nFolDes := 5

	BEGIN SEQUENCE
		oModelTMP := oModel:GetModel('PRAA802')
		If !Empty(oView) .And. oView:lActivate
			cOpId := Val(AllTrim(oModelTMP:GetValue('TMP_OPE_ID')))
			nOptFolder := oView:aFolders[1][5]:nOption
	
			IF cTipoModal != 'V'
				nFolCar := 3
				nFolDes := 4
			endif
	
		   If cOpId == 1 //Expedição
				oView:aFolders[1][5]:ShowPage(nFolCar)
				oView:aFolders[1][5]:HidePage(nFolDes)
				If nOptFolder == 4 .Or. nOptFolder == 5
					nOptFolder := 1
				EndIf
			ElseIf cOpId == 2 //Recebimento
				oView:aFolders[1][5]:HidePage(nFolCar)
				oView:aFolders[1][5]:ShowPage(nFolDes)
				If nOptFolder == 4 .Or. nOptFolder == 5
					nOptFolder := 1
				EndIf
			ElseIf  cOpId == 3 //Embarque/Desembarque
				oView:aFolders[1][5]:ShowPage(nFolCar)
				oView:aFolders[1][5]:ShowPage(nFolDes)
				If nOptFolder == 4 .Or. nOptFolder == 5
					nOptFolder := 1
				EndIf
			Else
				oView:aFolders[1][5]:HidePage(nFolCar)
				oView:aFolders[1][5]:HidePage(nFolDes)
				If nOptFolder == 4 .Or. nOptFolder == 5
					nOptFolder := 1
				EndIf
			EndIf
	
			If AllTrim(GetSParam('PLANEJAMENTO_OPERACIONAL_DESCARGA_CARGA','N','N')) == 'N'
				oView:aFolders[1][5]:HidePage(nFolCar)
				oView:aFolders[1][5]:HidePage(nFolDes)
			EndIf
			
			oView:aFolders[1][5]:ShowPage(nOptFolder)
		EndIf
	    if nOp <> 3
		 	cQuery := " select convert(varchar(50),dt_liberacao) as  dt_liberacao from tab_programacao where prog_id = " + cValToChar((oModelTMP:getvalue('TMP_PRG_ID')))
			dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlTmp, .F., .T.)
			if alltrim((cAlTmp)->dt_liberacao) <> ''
			    if alltrim(cEmpPai) <> SGetTerm()
					lResult := .F.
				endif
			endif
			(cAlTmp)->(dbCloseArea())
		endif
    END SEQUENCE
    ErrorBlock(bError)
return lResult


static function A802ATU2()
	//oModel:getmodel('PRAA802'):loadvalue('TMP_DT_FIE',alltrim(dtoc(cG_data2)))
return cG_data2

/*/{Protheus.doc} A802ATU
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Atualiza as informações do agendamento. É acionada através da trigger.
/*/
static function A802ATU()
	Local lResult := '  /  /    '
	Local oModel    := FWModelActive()
	Local oView    := FWViewActive()

      lResult := alltrim(cG_Data)
      if triggerErro = .F.
		oModel:getmodel('PRAA802'):loadvalue('TMP_PA_BLQ',alltrim(cG_pa_bloqueado))
		oModel:getmodel('PRAA802'):loadvalue('TMP_DT_AGE' ,cG_Resul_Agen)
		oModel:getmodel('PRAA802'):setvalue('TMP_PAJ_ID' ,val(alltrim(cG_paj_id)))
		oModel:getmodel('PRAA802'):loadvalue('TMP_PA_ID' ,val(alltrim(cG_pa_id)))
		oModel:getmodel('PRAA802'):setvalue('TMP_AGDT_I' ,cG_dt_a_ini)
		oModel:getmodel('PRAA802'):setvalue('TMP_AGHR_I' ,cG_hr_a_ini)
		oModel:getmodel('PRAA802'):setvalue('TMP_AGDT_F' ,cG_dt_a_fim)
		oModel:getmodel('PRAA802'):setvalue('TMP_AGHR_F' ,cG_hr_a_fim)
		oModel:getmodel('PRAA802'):loadvalue('TMP_DT_PRE' ,ctod(cG_dt_a_ini))
		oModel:getmodel('PRAA802'):loadvalue('TMP_HR_PRE' ,':')

		 If !Empty(oView) .And. oView:lActivate
			oView:refresh()
		EndIf
	  endif
	  triggerErro := .F.
return lResult


//-----------------------------------
/*{Protheus.doc}
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Evento when para o campo W_TISO_CNT
*/
//-----------------------------------
static function A802W_TISO_CNT()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelCNT
	Local cAlias2 := GetNextAlias()
	Local cQuery := ''
	Local bError := errorBlock({|e|erro(e)})

	BEGIN SEQUENCE
		oModelCNT := oModel:GetModel('PRAA802CNT')

        lResult := VALTPOPCNT(oModelCNT)
        
		if (alltrim(oModelCNT:GetValue('CNT_CNT_ID')) <> '') .And. lResult
			cQuery := " select cnt_id from tab_container where cnt_id = '" + alltrim(oModelCNT:GetValue('CNT_CNT_ID')) + "'"
			dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias2, .F., .T.)
			if alltrim((cAlias2)->cnt_id) <> ''
			    lResult := .F.
			endif
		endif
		
	END SEQUENCE
	ErrorBlock(bError)

return lResult


//-----------------------------------
/*/{Protheus.doc} A802W_QUANT_CNT
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Evento when para o campo W_QUANT_CNT
/*/
//-----------------------------------
static function A802W_QUANT_CNT()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelCNT
	Local bError := errorBlock({|e|erro(e)})

	BEGIN SEQUENCE
		oModelCNT := oModel:GetModel('PRAA802CNT')
		if (alltrim(oModelCNT:GetValue('CNT_CNT_ID')) <> '')
			lResult := .F.
		endif
	END SEQUENCE
	ErrorBlock(bError)

return lResult

/*/{Protheus.doc} VAL_DT_JAIN
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Valida na data inicial se as datas estão consistentes
/*/
static function VAL_DT_JAIN()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:GetModel('PRAA802')

	if ((alltrim(oModelTMP:getvalue('TMP_DT_FIE')) <>'/  /') .and. (alltrim(oModelTMP:getvalue('TMP_DT_FIE')) <>'')) .and. ((alltrim(oModelTMP:getvalue('TMP_DT_INE')) <>'/  /') .and. (alltrim(oModelTMP:getvalue('TMP_DT_INE')) <>''))
		if (ctod(alltrim(oModelTMP:getvalue('TMP_DT_FIE'))) < ctod(alltrim(oModelTMP:getvalue('TMP_DT_INE')))) .or.  (ctod(alltrim(oModelTMP:getvalue('TMP_DT_INE'))) > ctod(alltrim(oModelTMP:getvalue('TMP_DT_FIE'))))
			lResult := .F.
			oModel:SetErrorMessage('PRAA802','TMP_DT_INE','','','3000', STR0201,STR0202,nil,nil)
		endif
	endif

return lResult

/*/{Protheus.doc} VAL_DT_JANELA
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Valida na data final se as datas estão consistentes
/*/
static function VAL_DT_JANELA()
	Local cViagem := ''
	Local lResult := .T.
	Local oModelTMP
	Local cQuery := ''
	Local cAlias5 := GetNextAlias()
	Local nOp
	Private paadmin_bloqueado := ''
	Private lCancel := .F.
	Private oModel    := FWModelActive()
	Private dData :=  ctod(alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DT_INE')))
	Private dData2 := ctod(alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DT_FIE')))
	Private paj_id := ''
	Private pa_id := ''
	Private cResul_Agen := ''
	Private dt_agen_ini := ''
	Private hr_agen_ini := ''
	Private dt_agen_fim := ''
	Private hr_agen_fim := ''
	Private pa_bloqueado := ''
	Private ldDataVazio := .F.
	Private ldData2Vazio := .F.
	Private cOperacao := ''
	Private cSubOperacao := ''
	Private nQuantidade := 0
	Private cdc_id := ''
	Private cModal_id := cModal

	oModelTMP := oModel:GetModel('PRAA802')
	nOp := oModel:getOperation()
	if nOp <> 3
		cQuery := " select convert(varchar(50),dt_liberacao) as  dt_liberacao from tab_programacao where prog_id = " + alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_PRG_ID'))
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias5, .F., .T.)
		if alltrim((cAlias5)->dt_liberacao) <> ''
			if alltrim(cEmpPai) <> SGetTerm()
				triggerErro := .T.
				return .T.
			endif
		endif
	endif

	if ((alltrim(oModelTMP:getvalue('TMP_DT_FIE')) <>'/  /') .and. (alltrim(oModelTMP:getvalue('TMP_DT_FIE')) <>'')) .and. ((alltrim(oModelTMP:getvalue('TMP_DT_INE')) <>'/  /') .and. (alltrim(oModelTMP:getvalue('TMP_DT_INE')) <>''))
		if (ctod(alltrim(oModelTMP:getvalue('TMP_DT_FIE'))) < ctod(alltrim(oModelTMP:getvalue('TMP_DT_INE')))) .or.  (ctod(alltrim(oModelTMP:getvalue('TMP_DT_INE'))) > ctod(alltrim(oModelTMP:getvalue('TMP_DT_FIE'))))
			lResult := .F.
			oModel:SetErrorMessage('PRAA802','TMP_DT_FIE','','','3000',STR0201,STR0202,nil,nil)
			return .F.
		endif
	endif

	if (cTipoModal == "F")
		cViagem := alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_VIAGEM'))
		if SEmpty(cViagem)
			lResult := .F.
			triggerErro := .T.
			oModel:SetErrorMessage('PRAA802','TMP_VIAGEM','','','3039',"Viagem não informada","",nil,nil)
			return .F.
		endif

	endif

	if chamouConsulta = .T.
		chamouConsulta := .F.
		return .T.
	endif

	if (alltrim(oModelTMP:getvalue('TMP_DT_AGE')) = '') .and. (((alltrim(oModelTMP:getvalue('TMP_DT_FIE')) <>'/  /') .and. (alltrim(oModelTMP:getvalue('TMP_DT_FIE')) <>'')) .and. ((alltrim(oModelTMP:getvalue('TMP_DT_INE')) <>'/  /') .and. (alltrim(oModelTMP:getvalue('TMP_DT_INE')) <>'')))

		    if (alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DC_ID')) <> '' )
				if (alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_SUB_ID')) = '') .or. (oModel:getmodel('PRAA802'):getvalue('TMP_QUANT') = 0 )
					 alert(STR0250)
					 cG_Data := alltrim(oModelTMP:getvalue('TMP_DT_INE'))
					triggerErro := .T.
					return 	.T.
				endif
			else
				if (alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_SUB_ID')) = '')
					alert(STR0251)
					cG_Data := alltrim(oModelTMP:getvalue('TMP_DT_INE'))
					triggerErro := .T.
					return 	.T.
				endif
			endif

			cOperacao     := alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_OPE_ID'))
			//If !Empty(cOperacao)
			//	cOperacao := Val(cOperacao)
			//EndIf
			cSubOperacao := alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_SUB_ID'))
			nQuantidade := oModel:getmodel('PRAA802'):getvalue('TMP_QUANT')

			if alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DC_D')) <> ''
				cdc_id := alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DC_ID'))
			endif

			PRAC808()

			if ((lCancel = .F.) .and. ((nOp <> 1) .or. (nOp <> 5)) )
				cG_pa_bloqueado = pa_bloqueado
				cG_Data := dData
				cG_Data2 := dData2
			 	cG_Resul_Agen := cResul_Agen
				cG_paj_id := paj_id
				cG_pa_id := pa_id
				cG_dt_a_ini := dt_agen_ini
				cG_hr_a_ini := hr_agen_ini
				cG_dt_a_fim := dt_agen_fim
				cG_hr_a_fim := hr_agen_fim
			endif

			if (lCancel = .T.) .and. (ldData2Vazio = .T.)
				oModelTMP:loadvalue('TMP_DT_FIE','/  /')
			else
				oModelTMP:loadvalue('TMP_DT_FIE',alltrim(dtoc(dData2)))
			endif

			if (lCancel = .T.) .and. (ldDataVazio = .T.)
				cG_Data := '/  /'
			else
				cG_Data := alltrim(dtoc(dData))
			endif
	endif

return lResult


static function VAL_DT_PRE()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:GetModel('PRAA802')
	//Local bError := errorBlock({|e|erro()})

	//BEGIN SEQUENCE
	if ( alltrim(dtoc(oModelTMP:getvalue('TMP_DT_PRE'))) <> '/  /')
		if ( alltrim(oModelTMP:getvalue('TMP_DT_AGE')) = '' )
			oModel:SetErrorMessage('PRAA802','TMP_DT_PRE','','','3040',STR0203,STR0204,nil,nil)
			lResult := .F.
		elseif  ( (oModelTMP:getvalue('TMP_DT_PRE') < ctod(alltrim(oModelTMP:getvalue('TMP_AGDT_I'))) )  .or.  (oModelTMP:getvalue('TMP_DT_PRE') >ctod(alltrim(oModelTMP:getvalue('TMP_AGDT_F')))) )
			oModel:SetErrorMessage('PRAA802','TMP_DT_PRE','','','3041','Data fora da agenda.','Defina uma data conforme a agendado.',nil,nil)
			lResult := .F.
		endif
	endif
	//END SEQUENCE

return lResult



static function VAL_HR_PRE()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:GetModel('PRAA802')
	Local nHrPrevisto := 0
	Local nHrInicioAgenda := 0
	Local nHrFimAgenda := 0
	Local nMinutos := 0
	//Local bError := errorBlock({|e|erro()})

	//BEGIN SEQUENCE
	if ( alltrim(oModelTMP:getvalue('TMP_HR_PRE')) <> ':')

		if ( alltrim(oModelTMP:getvalue('TMP_DT_AGE')) = '' )
			oModel:SetErrorMessage('PRAA802','TMP_HR_PRE','','','3000',STR0203,STR0204,nil,nil)
			lResult := .F.
		elseif( alltrim(oModelTMP:getvalue('TMP_HR_PRE')) <> '') .and. ( alltrim(oModelTMP:getvalue('TMP_AGHR_I')) <> '') .and. ( alltrim(oModelTMP:getvalue('TMP_AGHR_F')) <> '')

			nHrPrevisto      := val((substr(alltrim(oModelTMP:getvalue('TMP_HR_PRE')),1,2) + substr(alltrim(oModelTMP:getvalue('TMP_HR_PRE')),4,2)))
			nHrInicioAgenda := val((substr(alltrim(oModelTMP:getvalue('TMP_AGHR_I')),1,2) + substr(alltrim(oModelTMP:getvalue('TMP_AGHR_I')),4,2)))
			nHrFimAgenda     := val((substr(alltrim(oModelTMP:getvalue('TMP_AGHR_F')),1,2) + substr(alltrim(oModelTMP:getvalue('TMP_AGHR_F')),4,2)))

			nMinutos := val(substr(alltrim(oModelTMP:getvalue('TMP_HR_PRE')),3,2))

			if (nHrPrevisto < nHrInicioAgenda) .or. (nHrPrevisto >  nHrFimAgenda) .or. (nHrPrevisto > 2459 ) .or. (nMinutos > 60 )
				lResult := .F.
			endif
		endif

	endif
	//END SEQUENCE

return lResult

static function VAL_QUANT()
	Local lResult := .T.
	Local bError := errorBlock({|e|erro(e)})
	Private cdc_id := ''

   	ErrorBlock(bError)

return lResult

function VAL_OPERANDO(operacao,suboperacao,pajid,quantidade,chamou)
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local nOp := omodel:getOperation()
	Local oModelTMP := oModel:GetModel('PRAA802')
	Local cConDriver := GetNextAlias()
	Local cCon2Driver := GetNextAlias()
	Local cCon4Driver := GetNextAlias()
	Local cQuery := ''
	Local bError := errorBlock({|e|erro(e)})
	Local aStructSA1 := {}
	Local cCampos := nil
	Local quant_driver := 0

	if cdc_id = ''
		return .T.
	endif
	BEGIN SEQUENCE
			  cQuery	 := ''
	          cQuery	 += ' select b.paj_id, b.pjc_quantidade, c.dc_descricao, convert(varchar(800),c.dc_comando_sql) as dc_comando_sql '
              cQuery	 += '   from tab_portal_operacoes a'
              cQuery	 += '  inner join tab_portal_janela_capacidade b'
              cQuery	 += '     on a.pjc_id = b.pjc_id'
              cQuery	 += '  inner join tab_driver_capacidade c'
              cQuery	 += '     on c.dc_id = b.dc_id'
              cQuery	 += "  where a.modal_id = '" + cModal + "'"
              cQuery	 += '    and a.op_id = ' + operacao//alltrim(oModelTMP:GetValue('TMP_OPE_ID'))
              cQuery	 += '    and a.sub_id = ' + suboperacao//alltrim(oModelTMP:GetValue('TMP_SUB_ID'))
              cQuery	 += '    and b.paj_id = ' +  pajid//alltrim(str(oModelTMP:getvalue('TMP_PAJ_ID')))

		 dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cConDriver, .F., .T.)

		 IF AllTrim((cConDriver)->dc_comando_sql) <> ''
		         quant_driver := (cConDriver)->pjc_quantidade
         	    cQuery := alltrim((cConDriver)->dc_comando_sql)

         	    cQuery := strtran(UPPER(cQuery),':DC_ID',cdc_id)
         	    cQuery := strtran(UPPER(cQuery),':PAJ_ID',pajid)

         	    dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cCon2Driver, .F., .T.)
         	    DbSelectArea(cCon2Driver)


				aStructSA1 := DbStruct()

				cCampos := aStructSA1[1][1]

         	  if (cCon2Driver)->(EOF())
         	 	if chamou = 'P'
	            	 oModel:SetErrorMessage('PRAA802','TMP_QUANT',,,'3042',STR0254 + cQuery, STR0255 ,nil,nil)
	            else
	            	 alert(STR0254 + cQuery + chr(13)+chr(10) + STR0255 )
	            endif

	            return .F.
         	 end

         	subtracao := (cConDriver)->pjc_quantidade - (cCon2Driver)->&cCampos

         	if nOP = 4
         		cQuery := ' select convert(char(6),prog_id) as prog_id from tab_prog_janela where prog_id = ' + alltrim(oModelTMP:getvalue('TMP_PRG_ID')) + ' and paj_id = ' + pajid + ' and dc_id = ' + cdc_id
	         	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cCon4Driver, .F., .T.)
	         	DbSelectArea(cCon4Driver)
         	endif

         	if (nOp = 4) .and.(alltrim((cCon4Driver)->prog_id) <> '')
	         		subtracao += (cAliasTMP)->TMP_QUANT
         	endif

            if 	( quantidade > subtracao )
            	if chamou = 'P'
            		oModel:SetErrorMessage('PRAA802','TMP_QUANT',,,'3043',STR0256, STR0257+ alltrim(str(((cConDriver)->pjc_quantidade - (cCon2Driver)->&cCampos))) ,nil,nil)
            	else
            	    alert(STR0256 + Chr(13) + STR0257 + alltrim(str(((cConDriver)->pjc_quantidade - (cCon2Driver)->&cCampos))) )
            	endif

            	return .F.
            else
             	lResult := .T.
            endif
		 else
		 	lResult := .T.
         EndIf
         (cConDriver)->(DbCloseArea())
   	END SEQUENCE
   	ErrorBlock(bError)

return lResult

static function WHEN_QUANT()
	Local lResult := .T.
	Local oModel    := nil
	Local oView    := nil
	Local bError := errorBlock({|e|erro(e)})

	BEGIN SEQUENCE
		oModel    := FWModelActive()
		oView    := FWViewActive()
	END SEQUENCE
	ErrorBlock(bError)

return lResult

//static function VAL_QTD_CNT()A802CNTPST
static function A802CNTPST()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelCNT
	Local oModelTMP
	Local cAlias := GetNextAlias()
	Local bError := errorBlock({|e|erro(e)})
	Local nI := 0

	BEGIN SEQUENCE
		oModelCNT := oModel:GetModel('PRAA802CNT')
		oModelTMP := oModel:GetModel('PRAA802')

		if alltrim(oModelCNT:getvalue('CNT_CNT_ID')) <> ''
			if alltrim(oModelCNT:getvalue('CNT_TISO_I')) = ''
				oModel:SetErrorMessage('PRAA802CNT','',,,'3044','Tipo iso não informado.', 'Informe um tipo iso.',nil,nil)
			    return .F.
		    endif

			 cQuery := " select tiso_id from tab_tipo_iso where tiso_id = '" +alltrim(oModelCNT:getvalue('CNT_TISO_I'))+ "'"
		    DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)

		    if alltrim((cAlias)->tiso_id) = ''
		     	oModel:SetErrorMessage('PRAA802CNT','',,,'3045','Tipo iso inválido.', 'Informe um tipo iso válido.',nil,nil)
		    	return .F.
		    endif
		endif
		
		if alltrim(FwFldGet("TMP_OPE_ID")) == '2'
			For nI := 1 To oModelCNT:Length()
				oModelCNT:GoLine( nI)
				if .not. oModelCNT:IsDeleted() .And. (AllTrim(oModelCNT:GetValue('CNT_RES_NU')) != '') .And. (VAL0003ReservaPossuiPreCadastro(AllTrim(oModelCNT:GetValue('CNT_RES_NU'))))
	 				if !VAL0004PossuiRelReserva((AllTrim(oModelCNT:GetValue('CNT_RES_NU'))), AllTrim(oModelCNT:GetValue('CNT_DP_DS')), AllTrim(oModelCNT:GetValue('CNT_CNT_ID')))  
						oModel:SetErrorMessage('PRAA802CNT','CNT_RES_NU','','','3046', 'O container ' + AllTrim(oModelCNT:GetValue('CNT_CNT_ID')) + ' não possui relacionamento com a reserva selecionada.','',nil,nil)
						return .F.
					endif	 	
				endif 								
			Next nI
		endif
						
	END SEQUENCE
	ErrorBlock(bError)
return lResult

static function VAL_CNT_CHE()
  Local lResult := .T.
  Local oModel  := FWModelActive()
  Local oModelTMP
  Local oModelCNT
  
  oModelCNT := oModel:GetModel('PRAA802CNT')
  oModelTMP := oModel:GetModel('PRAA802')
  
  if (cSubOpCntCheio == '')
  	StaticCall(PRAA802,VAL_SUB_ID)      
  endif
  
  if AllTrim(oModelCNT:GetValue('CNT_CNTCHE')) == 'S'
  	if !(cSubOpCntCheio == '1')
  		oModel:SetErrorMessage('PRAA802CNT','CNT_CNTCHE','','','3047','Operação negada.','Sub operação '+alltrim(oModelTMP:getvalue('TMP_SUB_DS'))+' não permite a operação com contêineres cheios.',nil,nil)
        	lResult := .F.
  	endif 
  else
  	if !(cSubOpCntVazio == '1')
  		oModel:SetErrorMessage('PRAA802CNT','CNT_CNTCHE','','','3048','Operação negada.','Sub operação '+alltrim(oModelTMP:getvalue('TMP_SUB_DS'))+' não permite a operação com contêineres vazios.',nil,nil)
        	lResult := .F.
  	endif 	
  endif 
  
  cSubOpCntCheio  := ''
  cSubOpCntVazio  := ''
  cSubOpMercSolta := ''

return lResult

static function VAL_TISO()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelCNT
	Local oModelTMP
	Local cAlias := GetNextAlias()
	Local cAlias2 := GetNextAlias()
	Local cAliasISO := GetNextAlias()
	Local nI := 0
	Local cTiso := ''
	Local cQuery := ''
	Local nQuant := 0

	oModelCNT := oModel:GetModel('PRAA802CNT')
	oModelTMP := oModel:GetModel('PRAA802')

	if(alltrim(oModelCNT:GetValue('CNT_TISO_I')) <> '')
			cQuery := " select tiso_id from tab_tipo_iso where tiso_id = '" +alltrim(oModelCNT:GetValue('CNT_TISO_I'))+ "'"
	     	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias2,.F.,.T.)

	     	if alltrim((cAlias2)->tiso_id) = ''
	     		oModel:SetErrorMessage('PRAA802CNT','CNT_TISO_I',,,'3049','Tipo iso inválido.', 'Informe um tipo iso válido.',nil,nil)
	     		oModelCNT:LoadValue('CNT_TISO_I','')
	     		lResult := .F.
	     	endif
	 endif

	  if lResult .And. !Empty(oModelTMP:getvalue('TMP_OPE_ID')).And. Val(oModelTMP:getvalue('TMP_OPE_ID')) = 4
		   if(alltrim(oModelCNT:GetValue('CNT_TISO_I')) <> '')
		   		if alltrim(oModelCNT:GetValue('CNT_QTD_CN')) <> ''
			   		cTiso := alltrim(oModelCNT:GetValue('CNT_TISO_I'))

			   		For nI := 1 To oModelCNT:Length()
						 	 oModelCNT:GoLine( nI)
						     if oModelCNT:IsDeleted() = .F.
						         if alltrim(oModelCNT:GetValue('CNT_TISO_I')) = cTiso
						         	nQuant := nQuant + val(alltrim(oModelCNT:GetValue('CNT_QTD_CN')))
						         endif
							  endif
					Next nI

					cQuery := " select count(tiso_id) as total from vw_inventario_container where tiso_id = '" +cTiso+ "'"
			     	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasISO,.F.,.T.)

			     	if val(alltrim(oModelCNT:GetValue('CNT_QTD_CN'))) > (cAliasISO)->total
			     		oModel:SetErrorMessage('PRAA802CNT','CNT_TISO_I',,,'3050','A quantidade máxima de containers no inventário do tipo iso ' +ctiso+ ' é de ' + alltrim(str((cAliasISO)->total)), 'Informe um container com outro tipo iso.',nil,nil)
		     			lResult := .F.
			     	endif
			     	
			     	if lResult 

			       	cQuery := " select tiso_tamanho from tab_tipo_iso where tiso_id = '" + alltrim(oModelCNT:GetValue('CNT_TISO_I')) + "'"
						cQuery := ChangeQuery(cQuery)
						DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
	
						if alltrim((cAlias)->tiso_tamanho) <> ''
							oModelCNT:loadvalue('CNT_TIS_TA',(cAlias)->tiso_tamanho)
						else
							lResult := .F.
							oModelCNT:loadvalue('CNT_TIS_TA','')
						endif
						(cAlias)->(dbCloseArea())
					endif	
			   endif
			else
				oModelCNT:loadvalue('CNT_TIS_TA','')
		    endif
	  ElseIf lResult .And. !Empty(oModelTMP:getvalue('TMP_OPE_ID'))
			cQuery := " select tiso_tamanho from tab_tipo_iso where tiso_id = '" + alltrim(oModelCNT:GetValue('CNT_TISO_I')) + "'"
			cQuery := ChangeQuery(cQuery)
			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)
			if alltrim((cAlias)->tiso_tamanho) <> ''
				oModelCNT:loadvalue('CNT_TIS_TA',(cAlias)->tiso_tamanho)
			else
//				lResult := .F.
				oModelCNT:loadvalue('CNT_TIS_TA','')
			endif
			(cAlias)->(dbCloseArea())
	  endif

return lResult

/*/{Protheus.doc} VAL_RES_ID
Valida o campo res_id
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Valida o campo res_id
/*/
static function VAL_RES_ID()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelCNT
	Local cAlias := GetNextAlias()
	Local bError := errorBlock({|e|erro(e)})

	BEGIN SEQUENCE
		   oModelCNT := oModel:GetModel('PRAA802CNT')

		   if (alltrim(oModelCNT:GetValue('CNT_RES_ID')) <> '0')
				cQuery := "       select a.res_numero from tab_reserva a "
			if (cEmpPai != SGetTerm())
				cQuery += "     inner join vw_portal_permissao_acesso b on a.cli_id = b.cli_id_principal "
                cQuery += " where b.usu_id = 'c" + SCodUsr() + "' and a.res_id = " + alltrim(oModelCNT:getvalue('CNT_RES_ID'))
			else
            	cQuery += " where a.res_id = " + alltrim(oModelCNT:getvalue('CNT_RES_ID'))
			endif

				cQuery := ChangeQuery(cQuery)

				DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)

				if alltrim((cAlias)->res_numero) = ''
					lResult := .F.
				endif
		   endif
	END SEQUENCE
	ErrorBlock(bError)
return lResult



static function VAL_BOOK_NU(cModelo)
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelGEN
	Local oModelTMP
	Local cAlias := GetNextAlias()
	Local oView    := FWViewActive()
	Local bError := errorBlock({|e|erro(e)})
	Local cAlias10 := getnextalias()
	Local cSql := ''
	Local cSQLIn := ''
	Local nX
	Local aSQLIn := {}
	BEGIN SEQUENCE
		oModelGEN := oModel:GetModel(cModelo)
		oModelTMP := oModel:GetModel('PRAA802')
		
		if cModelo = 'PRAA802DOC' 
			if (alltrim(FwFldGet("TMP_OPE_ID")) == '1')
    			oModelGEN:setvalue('DOC_TPO_ES', 'S')
    		elseif (alltrim(FwFldGet("TMP_OPE_ID")) == '2')
    			oModelGEN:setvalue('DOC_TPO_ES', 'E')      	
    		endif
    	    
    	   if !Empty(oView) .And. oView:lActivate
   				oview:Refresh('PRAA802DOC')
   			endIf   			
   		endif
    	  	
		
		if cModelo = 'PRAA802CNT'
		   if alltrim(omodelGEN:getvalue('CNT_RES_NU')) = ''
		        omodelGEN:loadvalue('CNT_TPO_ES','')
		   		omodelGEN:loadvalue('CNT_RES_ID','')
		   		omodelGEN:loadvalue('CNT_CNT_ID','')
		   		omodelGEN:loadvalue('CNT_TISO_I','')
		   		omodelGEN:loadvalue('CNT_TIS_TA','')
		   		omodelGEN:loadvalue('CNT_QTD_CN','')
		   		omodelGEN:loadvalue('CNT_DP_DS','')
		   		omodelGEN:loadvalue('CNT_DP_ID','')
		   		If lTemDepot 
			   		omodelGEN:loadvalue('CNT_DEPOT','')
			   		omodelGEN:loadvalue('CNT_ARMADO','')
			   		omodelGEN:loadvalue('CNT_ARM_DS','')
			   		omodelGEN:loadvalue('CNT_PROGRA','')
		   		EndIf
				return .T.
			endif
		elseif cModelo = 'PRAA802DOC'
		    if alltrim(omodelGEN:getvalue('DOC_RES_NU')) = ''
		    	omodelGEN:loadvalue('DOC_RES_ID','')
		    	omodelGEN:loadvalue('DOC_DOC_ID','')
		    	omodelGEN:loadvalue('DOC_TPO_DC','')
		    	omodelGEN:loadvalue('DOC_ANO_DC','')
		    	omodelGEN:loadvalue('DOC_NUM_DC','')
		    	omodelGEN:loadvalue('DOC_SER_DC','')
		    	omodelGEN:loadvalue('DOC_PRC_DC','')
		    	omodelGEN:loadvalue('DOC_RES_ID','')
		    	omodelGEN:loadvalue('DOC_RES_NU','')
		    	omodelGEN:loadvalue('DOC_CFOP','')
		    	omodelGEN:loadvalue('DOC_CFOP_D','')
		    	omodelGEN:loadvalue('DOC_BEN_ID','')
		    	omodelGEN:loadvalue('DOC_BEN_CG','')
		    	omodelGEN:loadvalue('DOC_BEN','')
				return .T.
			endif
		elseif cModelo = 'PRAA802ITC'
		    if alltrim(omodelGEN:getvalue('ITC_RES_NU')) = ''

		    	if alltrim(oModelGEN:getvalue('ITC_DP_DS')) <> ''
			    	cSql := " select distinct a.dsai_id, "
				    cSql += "		       d.cli_id, "
					cSql += "		       d.cli_nome "
					cSql += "		from tab_di_item a "
					cSql += "		  inner join vw_inventario_armazem b "
					cSql += "		    on b.latu_lote = a.latu_lote and "
					cSql += "		       b.latu_item = a.latu_item "
					cSql += "		  inner join tab_doc_saida c "
					cSql += "		    on c.dsai_id = a.dsai_id "
					cSql += "		  inner join tab_clientes d "
					cSql += "		    on d.cli_id = c.ben_id  "
				    cSql += " where d.cli_id = '" + alltrim(omodelTMP:getvalue('TMP_CLI_ID'))+ "'"
				    DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),cAlias10,.F.,.T.)

					if alltrim((cAlias10)->dsai_id) = ''
						oModelGEN:loadvalue('ITC_DP_ID','')
						oModelGEN:loadvalue('ITC_DP_DS','')
						oModelGEN:loadvalue('ITC_LOT_ID','')
						oModelGEN:loadvalue('ITC_LOT_IT','')
						oModelGEN:loadvalue('ITC_QTD_VO','')
						oModelGEN:loadvalue('ITC_M3',0)
					endif
				endif

		    	omodelGEN:loadvalue('ITC_RES_ID','')
				return .T.
			 endif
		 endif

			cSql := "   select convert(varchar(6),a.res_id) as res_id, "+;
				    "   a.res_numero "+;				
					"	from tab_reserva a "+;
					"	  left join tab_viagem b "+;
					"	    on a.vgm_id = b.vgm_id "+;
					"   where 1=1 "+;
			        "	and a.res_dt_fechamento is null and a.res_dt_cancelamento is null "

			if cModelo = 'PRAA802CNT'
			   
				cSql += " and a.res_numero = '" +alltrim(omodelGEN:getvalue('CNT_RES_NU'))+ "'"
				
				aSQLIn := SMGrdtoArr(omodel:getmodel('PRAA802DOC'),'DOC_RES_NU')
				For nX := 1 To Len(aSQLIn)
					cSQLIn += "'" + alltrim(aSQLIn[nX]) + "',"
				Next nX
				IF !SEmpty(cSQLIn)
					cSQLIn := SubStr(cSQLIn, 0, len(cSQLIn) - 1)
					//cSql += " and a.res_numero IN ("+cSQLIn+")"
				endif
			elseif cModelo = 'PRAA802DOC'
			    
				cSql += " and a.res_numero = '" +alltrim(omodelGEN:getvalue('DOC_RES_NU'))+ "'"
				
			elseif cModelo = 'PRAA802ITC'
			    
				cSql += " and a.res_numero = '" +alltrim(omodelGEN:getvalue('ITC_RES_NU'))+ "'"
				
				aSQLIn := SMGrdtoArr(omodel:getmodel('PRAA802DOC'),'DOC_RES_NU')
				For nX := 1 To Len(aSQLIn)
					cSQLIn += "'" + alltrim(aSQLIn[nX]) + "',"
				Next nX
				IF !SEmpty(cSQLIn)
					cSQLIn := SubStr(cSQLIn, 0, len(cSQLIn) - 1)
					cSql += " and a.res_numero IN ("+cSQLIn+")"
				endif
			endif

			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),cAlias,.F.,.T.)
			dbselectarea(cAlias)

			if alltrim((cAlias)->res_numero) <> ''
			   if cModelo = 'PRAA802CNT'
					oModelGEN:loadvalue('CNT_RES_ID',alltrim((cAlias)->res_id))
					omodelGEN:loadvalue('CNT_TPO_ES','')
				   	omodelGEN:loadvalue('CNT_CNT_ID','')
				   	omodelGEN:loadvalue('CNT_TISO_I','')
				   	omodelGEN:loadvalue('CNT_TIS_TA','')
				   	omodelGEN:loadvalue('CNT_QTD_CN','')
				   	omodelGEN:loadvalue('CNT_DP_DS','')
				   	omodelGEN:loadvalue('CNT_DP_ID','')
				   	If lTemDepot 
					   	omodelGEN:loadvalue('CNT_DEPOT','')
					   	omodelGEN:loadvalue('CNT_ARMADO','')
					   	omodelGEN:loadvalue('CNT_ARM_DS','')
					   	omodelGEN:loadvalue('CNT_PROGRA','')
				   	EndIf
				elseif cModelo = 'PRAA802DOC'
					oModelGEN:loadvalue('DOC_RES_ID',alltrim((cAlias)->res_id))
				elseif cModelo = 'PRAA802ITC'
					oModelGEN:loadvalue('ITC_RES_ID',alltrim((cAlias)->res_id))
					if alltrim(oModelGEN:getvalue('ITC_DP_DS')) <> ''
						oModelGEN:loadvalue('ITC_DP_ID','')
						oModelGEN:loadvalue('ITC_DP_DS','')
					endif
				endif

				lResult := .T.
			else
				if cModelo = 'PRAA802CNT'
					oModelGEN:loadvalue('CNT_RES_ID','')
				elseif cModelo = 'PRAA802DOC'
					oModelGEN:loadvalue('DOC_RES_ID','')
				elseif cModelo = 'PRAA802ITC'
					oModelGEN:loadvalue('ITC_RES_ID','')
				endif
				lResult := .F.
			endif
	 END SEQUENCE
	 ErrorBlock(bError)
//	 oView:GetViewObj(cModelo)[3]:EvalWhen()

return lResult


static function VAL_CFOP()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelDOC    := omodel:getmodel('PRAA802DOC')
	Local cAlias := GetNextAlias()
	Local bError := errorBlock({|e|erro(e)})
	Local cSql := ''

	BEGIN SEQUENCE
	cSql := "	select a.cfop_id, "+;
			 "	       a.cfop_descricao "+;
			 "	from tab_cfop a       "+;
			"	  inner join rel_cfop_doc b "+;
			"	    on b.cfop_id = a.cfop_id "

	if alltrim(omodelDOC:getvalue('DOC_CFOP')) <> '.' .and. alltrim(omodelDOC:getvalue('DOC_CFOP')) <> ''
		if alltrim(omodelDOC:getvalue('DOC_TPO_DC')) <> ''
	   		cSql += "	where b.doc_id = '" + alltrim(omodelDOC:getvalue('DOC_TPO_DC'))+"'"
	   		cSql += " and a.cfop_id = '" +alltrim(omodelDOC:getvalue('DOC_CFOP'))+ "'"
	   		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cSql),cAlias,.F.,.T.)
			dbselectarea(cAlias)
			if alltrim((cAlias)->cfop_descricao) <> ''
				omodelDOC:loadvalue('DOC_CFOP_D',alltrim((cAlias)->cfop_descricao))
				lResult := .T.
			else
				lResult := .F.
			endif
	   	else
	   		oModel:SetErrorMessage('PRAA802DOC','DOC_CFOP','','','3051','Tipo do documento não preenchido.','Informe o tipo do documento.',nil,nil)
	   		omodelDOC:loadvalue('DOC_CFOP_D','')
	   		omodelDOC:loadvalue('DOC_CFOP','')
	   		lResult := .F.
		endif
	else
		omodelDOC:loadvalue('DOC_CFOP_D','')
		omodelDOC:loadvalue('DOC_CFOP','')
		lResult := .T.
	endif

	END SEQUENCE
	ErrorBlock(bError)
//	oView:GetViewObj('PRAA802DOC')[3]:EvalWhen()

return lResult

/*/{Protheus.doc} A802VAOK
Evento de Post do Model

@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Tratamento realizados no post do Model
/*/
Static Function A802VAOK(oModel)
	Local oModelTMP := oModel:GetModel('PRAA802')
	Local oModelREB := oModel:GetModel('PRAA802REB')
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local oModelCNT := oModel:GetModel('PRAA802CNT')
	Local oModelITC := oModel:GetModel('PRAA802ITC')
	Local oModelITD := oModel:GetModel('PRAA802ITD')
	Local nOp       := oModel:getOperation()
	Local cAliasDv := GetNextAlias()
	Local cAliasVF := GetNextAlias()
	Local nI := 0
	Local nJ := 0
	Local cQuery := ''
	Local nQuant := 0
	Local cTipoDriver := ''
	Local nqtd := 0
	Local nPeso := 0
	Local nTotVi := 0
	Local nTotProg := 0
	Local aCnt := {}
    Local cIdVeic := AllTrim(oModelTMP:GetValue('TMP_VEI_ID'))

	Private cdc_id := ''

	IF ((nOp == 3) .or. (nOp == 4))//inclusão //Alteração
		
		lResult := A802VeiBloqueado(cIdVeic)

		IF (lResult == .F.)
			oModel:SetErrorMessage('PRAA802', 'TMP_VEI_ID',,,,VEICULO_BLOQUEADO_MSG)

			return lResult
		ENDIF
		
		//Valida a viagem e o modal ferroviário
		If !A802VALVIG(FwFldGet("TMP_VIAGEM"),cTipomodal, .F.)
			Return .F.
		EndIf
		
		If lTemDepot
			IF !(A802VLDARMAD('PRAA802CNT'))
			   oModel:SetErrorMessage('PRAA802',,,,'3065' ,'É necessário informar o Armador!', nil, nil)			
			   Return .F.
			EndIf
			
			IF !(A802VLDARMAD('PRAA802CNT'))
			   oModel:SetErrorMessage('PRAA802',,,,'3065' ,'O Armador informado é inválido para esta programação!', nil, nil)			
			   Return .F.
			EndIf
		
		    If (AllTrim(oModelCNT:GetValue('CNT_DEPOT'))=='S')
				IF !A802PROGRAM('PRAA802CNT') .And. (AllTrim(oModelCNT:GetValue('CNT_TPO_ES'))=='E' .Or. AllTrim(oModelCNT:GetValue('CNT_TPO_ES'))=='ENTRADA')
				   oModel:SetErrorMessage('PRAA802',,,,'3065' ,'Programação de entrada do DEPOT inválida para o armador selecionado.', nil, nil)			
				   Return .F.
				EndIf
				
				IF !A802PROGRAM('PRAA802CNT') .And. (AllTrim(oModelCNT:GetValue('CNT_TPO_ES'))=='S' .Or. AllTrim(oModelCNT:GetValue('CNT_TPO_ES'))=='SAIDA')
				   oModel:SetErrorMessage('PRAA802',,,,'3065' ,'Programação de saída do DEPOT inválida para o armador selecionado.', nil, nil)			
				   Return .F.
				EndIf
				
				IF (A802Obriga('PRAA802CNT') .And. (Empty(oModelCNT:GetValue('CNT_PROGRA'))))
				   oModel:SetErrorMessage('PRAA802',,,,'3065' ,'É necessário informar o número da programação!', nil, nil)
				   Return .F.
				EndIf
			EndIf
        EndIf
		if cTipoModal == 'F'
			cQuery := " select count(prog_id) as total from tab_programacao where dt_cancelamento is null and vf_id = '" + alltrim(FwFldGet("TMP_VIAGEM"))+"'"
			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasVF,.F.,.T.)
			dbselectarea(cAliasVF)

			if (cAliasVF)->total > 0
				nTotProg := (cAliasVF)->total

				(cAliasVF)->(dbCloseArea())
				cQuery := " select (vf_nr_vagao_cheio + vf_nr_vagao_vazio) as total from tab_viagem_ferroviaria where vf_id = '" + alltrim(FwFldGet("TMP_VIAGEM"))+"' and vf_dt_cancelamento is null "
				DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasVF,.F.,.T.)
				dbselectarea(cAliasVF)

				if (cAliasVF)->total > 0
					nTotVi := (cAliasVF)->total
					if (nOp == 3 .And. nTotProg >= nTotVi) .Or. (nOp == 4 .And. nTotProg > nTotVi)
						(cAliasVF)->(dbCloseArea())
						oModel:SetErrorMessage('PRAA802',,,,'3052','A viagem "'+alltrim(FwFldGet("TMP_VIAGEM"))+'" já possui agendamentos registrados para todos os vagões.' ,'', nil, nil)
						return .F.
					endif
				endif
			endif
			(cAliasVF)->(dbCloseArea())
		endif
		//jv

		if alltrim(oModelTMP:getvalue('TMP_DC_ID')) <> ''
			cQuery := " select convert(char(6),dc_tipo) as dc_tipo from tab_driver_capacidade where dc_id = " + alltrim(oModelTMP:getvalue('TMP_DC_ID'))
			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDv,.F.,.T.)
			dbselectarea(cAliasDv)

			if alltrim((cAliasDv)->(dc_tipo)) <> ''
				cTipoDriver := alltrim((cAliasDv)->(dc_tipo))
			endif
		endif

		if   alltrim(oModelTMP:getvalue('TMP_HR_PRE')) = ':'
			oModel:SetErrorMessage('PRAA802',,,,'3053' ,STR0266 ,'', nil, nil)
			return .F.
		endif

		if alltrim(oModelTMP:getvalue('TMP_DC_ID')) <> ''
			cdc_id := alltrim(oModelTMP:getvalue('TMP_DC_ID'))
			cOperacao := alltrim(oModelTMP:getvalue('TMP_OPE_ID'))
			//If !Empty(cOperacao)
			//	cOperacao := Val(cOperacao)
			//EndIf
			if val_operando(cOperacao,alltrim(oModelTMP:getvalue('TMP_SUB_ID')), alltrim(str(oModelTMP:getvalue('TMP_PAJ_ID'))), oModelTMP:getvalue('TMP_QUANT'),'P') = .F.
				return .F.
			endif
		endif
		
		//verifica se caso um documento estiver deletado, não exista nenhum item relacionado a este documento.
		For nI := 1 To oModelDOC:Length()
			oModelDOC:GoLine(nI)
			
			If(!(oModelDOC:IsDeleted()) .and. (alltrim(oModelDOC:getvalue('DOC_NUM_DC')) == '')) .And. (alltrim(oModelDOC:getvalue('DOC_RES_NU')) <> '')
					oModel:SetErrorMessage('PRAA802',,,,'3054' ,'A reserva ' + alltrim(oModelDOC:getvalue('DOC_RES_NU')) + ' não possui documento relacionado.','Selecione o documento.', nil, nil)
				return .F.
			endif
			
			If oModelDOC:IsDeleted()
			
				For nJ := 1 To oModelITD:Length()
					oModelITD:GoLine(nJ)
					If .not. oModelITD:IsDeleted() .and. alltrim(oModelITD:getvalue('ITD_DP_DS')) <> '' .and. alltrim(oModelITD:getvalue('ITD_DP_DS')) = alltrim(oModelDOC:getvalue('DOC_DOC_ID'))
						oModel:SetErrorMessage('PRAA802',,,,'3055' ,'O documento ' + alltrim(oModelDOC:getvalue('DOC_DOC_ID')) + ' não pode ser excluído pois tem item de descarga relacionado.','Exclua os itens de descarga relacionado ao documento ' + alltrim(oModelDOC:getvalue('DOC_DOC_ID')), nil, nil)
						return .F.
					endif
				next nJ

				For nJ := 1 To oModelITC:Length()
					oModelITC:GoLine(nJ)
					If .not. oModelITC:IsDeleted() .and. alltrim(oModelITC:getvalue('ITC_DP_DS')) <> '' .and. alltrim(oModelITC:getvalue('ITC_DP_DS')) = alltrim(oModelDOC:getvalue('DOC_DOC_ID'))
						oModel:SetErrorMessage('PRAA802',,,,'3056' ,'O documento ' + alltrim(oModelDOC:getvalue('DOC_DOC_ID')) + ' não pode ser excluído pois tem item de carga relacionado.','Exclua os itens de carga relacionado ao documento ' + alltrim(oModelDOC:getvalue('DOC_DOC_ID')), nil, nil)
						return .F.
					endif
				next nJ
			endif
		next nI
		
		if (cSubOpCntCheio == '')
		  	StaticCall(PRAA802,VAL_SUB_ID)      
		EndIf
		
		if !(cSubOpCntCheio == '1') .And. !(cSubOpMercSolta == '1')
			For nI := 1 To oModelDOC:Length()
				oModelDOC:GoLine(nI)
				if (oModelDOC:IsDeleted() = .F.) .and. (alltrim(oModelDOC:getvalue('DOC_NUM_DC')) <> '')
					oModel:SetErrorMessage('PRAA802',,,,'3057' ,'Sub operação '+alltrim(oModelTMP:getvalue('TMP_SUB_DS'))+' permite apenas a operação com contêineres vazios, não permitido o cadastro de documentos.', nil, nil)
					Return.F.				 
				endif
			next nI
		endif 

		if alltrim(SGetParam('PLANEJAMENTO_OPERACIONAL_DESCARGA_CARGA')) = 'S'

			if oModelTMP:getvalue('TMP_PESO') = 0
				oModel:SetErrorMessage('PRAA802',,,,'3058' ,'O campo Peso: (TMP_PESO) não foi preenchido.','', nil, nil)
				return .F.
			endif 

			//se for carga verificar se, caso tenha 1 documento,tenha pelo menos 1 item de carga ou container
			nQuant := 0
			//se for descarga verificar se, caso tenha 1 documento,tenha pelo menos 1 item de descarga ou container
		endif//fim do if sgetparam

		if oModelTMP:getvalue('TMP_PESO') <> 0 .or. oModelTMP:getvalue('TMP_CUBICO') <> 0
			if !Empty(oModelTMP:getvalue('TMP_OPE_ID')).And. Val(oModelTMP:getvalue('TMP_OPE_ID')) = 1
				For nI := 1 To oModelITC:Length()
					oModelITC:GoLine(nI)
					if oModelITC:IsDeleted() = .F.
						nqtd += oModelITC:GetValue('ITC_M3')
					endif
				Next nI

				//verifica se o volume do agendamento esta => ao irformado nos itens de carga
				if nqtd > oModelTMP:getvalue('TMP_CUBICO')
					oModel:SetErrorMessage('PRAA802',,'','','3059','Metragem cúbica maior que o estabelecido na programação.' ,'Metragem cúbica dos itens de carga: ' + alltrim(str(nqtd)) + '.'+ chr(13)+chr(10) + 'Metragem cúbica da programação: ' + alltrim(str(oModelTMP:getvalue('TMP_CUBICO'))) + '.',nil,nil)
					Return .F.
				endif
			endif

			if !Empty(oModelTMP:getvalue('TMP_OPE_ID')).And. Val(oModelTMP:getvalue('TMP_OPE_ID')) = 2
				For nI := 1 To oModelITD:Length()
					oModelITD:GoLine(nI)
					if oModelITD:IsDeleted() = .F.
						nqtd += oModelITD:GetValue('ITD_M3')
						nPeso += oModelITD:GetValue('ITD_PESO')
					endif
				Next nI

				//verifica se o volume do agendamento esta => ao irformado nos itens de carga
				if nqtd > oModelTMP:getvalue('TMP_CUBICO')
					oModel:SetErrorMessage('PRAA802ITD','ITD_M3','','','3060','Metragem cúbica maior que o estabelecido na programação.' ,'Metragem cúbica dos itens de descarga: ' + alltrim(str(nqtd)) + '.'+ chr(13)+chr(10) + 'Metragem cúbica da programação: ' + alltrim(str(oModelTMP:getvalue('TMP_CUBICO'))) + '.',nil,nil)
					Return .F.
				endif
				if nPeso > oModelTMP:getvalue('TMP_PESO')
					oModel:SetErrorMessage('PRAA802ITD','ITD_PESO','','','3061','Peso maior que o estabelecido na programação.' ,'Peso dos itens de descarga: ' + alltrim(str(nPeso)) + ' kg.'+  chr(13)+chr(10) + 'Peso da programação: ' + alltrim(str(oModelTMP:getvalue('TMP_PESO'))) + ' kg.',nil,nil)
					Return .F.
				endif
			endif
		endif

		//Validadcao para o driver de capacidade se for de veiculo
		nQuant := 0
		if cTipoDriver = '1' .And. cTipoModal == 'V'
			For nI := 1 To oModelREB:Length()
				oModelREB:GoLine( nI)
				if oModelREB:IsDeleted() = .F.
					if (alltrim(oModelREB:GetValue('REB_REB_ID')) <> '')
						nQuant := nQuant + 1
					endif
				endif
			Next nI

			if nQuant > oModelTMP:getvalue('TMP_QUANT')
				oModel:SetErrorMessage('PRAA802',,,,'3000',STR0207 +CHR(13)+CHR(10) +;
				STR0208 + alltrim(str(oModelTMP:getvalue('TMP_QUANT'))) + STR0237 +CHR(13)+CHR(10) + STR0209 + alltrim(str(nQuant)) + '.',;
				STR0210 + alltrim(str(oModelTMP:getvalue('TMP_QUANT'))),nil,nil)
				Return .F.
			endif
		endif
        
		//validacao de driver de capacidade se for container
		nQuant := 0
		if cTipoDriver = '2'
			For nI := 1 To oModelCNT:Length()
				oModelCNT:GoLine( nI)
				if oModelCNT:IsDeleted() = .F.
					if ((alltrim(oModelCNT:getvalue('CNT_CNT_ID')) <> '')   .or. (alltrim(oModelCNT:getvalue('CNT_TISO_I')) <> '') .Or. (alltrim(oModelCNT:getvalue('CNT_RES_NU')) <> '') .Or. (alltrim(oModelCNT:getvalue('CNT_QTD_CN')) <> ''))

						If aScan(aCnt,{|x| UPPER(ALLTRIM(X)) == oModelCNT:getvalue('CNT_CNT_ID')}) == 0
							aAdd(aCnt,oModelCNT:getvalue('CNT_CNT_ID'))
							nQuant := nQuant + val(alltrim(oModelCNT:getvalue('CNT_QTD_CN')))
						EndIf
					endif
				endif
			Next nI

			if nQuant != oModelTMP:getvalue('TMP_QUANT')
				oModel:SetErrorMessage('PRAA802',,,,'3062' ,STR0258, STR0259+ alltrim(str(oModelTMP:getvalue('TMP_QUANT')))+ ".", nil, nil)
				Return .F.
			endif
		endif
		
		if !(cSubOpCntCheio == '1') .And. !(cSubOpCntVazio == '1')
			For nI := 1 To oModelCNT:Length()
				oModelCNT:GoLine( nI)
				if oModelCNT:IsDeleted() = .F.
					if alltrim(oModelCNT:getvalue('CNT_CNT_ID')) <> '' 
						oModel:SetErrorMessage('PRAA802',,,,'3063' ,'Sub operação '+alltrim(oModelTMP:getvalue('TMP_SUB_DS'))+' permite apenas a operação com carga solta, não permitido o vínculo de contêineres.', nil, nil)
						Return .F.
					EndIf 
				EndIf 
			next nI
		EndIf 
		
		For nI := 1 To oModelCNT:Length()
			oModelCNT:GoLine( nI)
			if oModelCNT:IsDeleted() = .F.
				if alltrim(oModelCNT:getvalue('CNT_CNT_ID')) <> '' 
					if alltrim(oModelCNT:getvalue('CNT_CNTCHE')) == 'S'
						if !(cSubOpCntCheio == '1')
							oModel:SetErrorMessage('PRAA802',,,,'3064' ,'Sub operação '+alltrim(oModelTMP:getvalue('TMP_SUB_DS'))+' não permite a operação com contêineres cheios.', nil, nil)
							Return .F.
						EndIf 
					else
						if !(cSubOpCntVazio == '1')
							oModel:SetErrorMessage('PRAA802',,,,'3065' ,'Sub operação '+alltrim(oModelTMP:getvalue('TMP_SUB_DS'))+' não permite a operação com contêineres vazios.', nil, nil)
							Return .F.
						endif
					endif 
				endif 			
			endif 
		next nI

		//validacao de driver de capacidade se for documento de entrada
		nQuant := 0
		if cTipoDriver = '3'
			For nI := 1 To oModelDOC:Length()
				oModelDOC:GoLine(nI)
				If (AllTrim(oModelDOC:GetValue('DOC_DOC_ID')) <> '') .and. (AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = 'E')
					If .Not. oModelDOC:IsDeleted()
						nQuant := nQuant + 1
					EndIf
				EndIf
			Next nI

			if nQuant > oModelTMP:getvalue('TMP_QUANT')
				oModel:SetErrorMessage('PRAA802',,,,'3066',STR0215+CHR(13)+CHR(10) +STR0208 + alltrim(str(oModelTMP:getvalue('TMP_QUANT'))) + '.' +CHR(13)+CHR(10) + STR0209 + alltrim(str(nQuant)) + '.',;
				STR0218 + alltrim(str(oModelTMP:getvalue('TMP_QUANT'))) + '.',nil,nil )
				Return .F.
			endif
		endif

		//validacao de driver de capacidade se for documento de entrada
		nQuant := 0
		if cTipoDriver = '4'
			For nI := 1 To oModelDOC:Length()
				oModelDOC:GoLine(nI)
				If (AllTrim(oModelDOC:GetValue('DOC_DOC_ID')) <> '') .and. (AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = 'S')
					If .Not. oModelDOC:IsDeleted()
						nQuant := nQuant + 1
					EndIf
				EndIf
			Next nI

			if nQuant > oModelTMP:getvalue('TMP_QUANT')
				oModel:SetErrorMessage('PRAA802',,,,'3067',STR0219+CHR(13)+CHR(10) +STR0212+ alltrim(str(oModelTMP:getvalue('TMP_QUANT'))) + '.' +CHR(13)+CHR(10) + STR0209 + alltrim(str(nQuant)) + '.',;
				STR0221 + alltrim(str(oModelTMP:getvalue('TMP_QUANT'))) + '.',nil,nil )
				Return .F.
			endif
		endif
	EndIf
	
	cSubOpCntCheio  := ''
    cSubOpCntVazio  := ''
    cSubOpMercSolta := ''

Return .T.

//-----------------------------------
/*{Protheus.doc}
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Realiza a operação DIU das procedures.
*/
//-----------------------------------
static function A802OPE(omodel)
   Local oModelTMP := oModel:GetModel('PRAA802')
   Local oModelREB := oModel:GetModel('PRAA802REB')
   Local oModelDOC := oModel:GetModel('PRAA802DOC')
   Local oModelANE := oModel:GetModel('PRAA802ANE')
   Local oModelCNT := oModel:GetModel('PRAA802CNT')
   Local oModelITC := oModel:GetModel('PRAA802ITC')
   Local oModelITD := oModel:GetModel('PRAA802ITD')
   Local nOp       := oModel:getOperation()
   Local nRegOp
   Local nI := 0
   Local cErro
   Local cReboque := ""
   Local lAlterouGrid
   Local cAlias := GetNextAlias()
   Local cAlias2 := GetNextAlias()
   Local sqlExec := ''
   Local cQuery := ''
   Local consultaEvento := GetNextAlias()
   Local aResult := {}
   Local cClieresp := GetNextAlias()
   Local cData := SDBDate(alltrim(dtoc(oModelTMP:GetValue('TMP_DT_PRE'))),alltrim(oModelTMP:GetValue('TMP_HR_PRE')))
   Local cSqlDOC := ''
   Local cAlsDOC := GetNextAlias()
   Local opr_depot  := 'N'
   Local cod_armad  := ''
   Local cod_progra := 0
   Local cQryReboque := ''
   Local cAliasEmp  := GetNextAlias()
   Private cProg_ID :=''
   
//	oModelTMP:SetNoInsertLine(.F.)
    If cTipoModal == "V"    
    	oModelREB:SetNoInsertLine(.F.)
	EndIf
	oModelDOC:SetNoInsertLine(.F.)
	oModelANE:SetNoInsertLine(.F.)
	oModelCNT:SetNoInsertLine(.F.)
	oModelITC:SetNoInsertLine(.F.)
	oModelITD:SetNoInsertLine(.F.)
	
//	oModelTMP:SetNoDeleteLine(.F.)
    If cTipoModal == "V"    
    	oModelREB:SetNoDeleteLine(.F.)
	EndIf
	oModelDOC:SetNoDeleteLine(.F.)
	oModelANE:SetNoDeleteLine(.F.)
	oModelCNT:SetNoDeleteLine(.F.)
	oModelITC:SetNoDeleteLine(.F.)
	oModelITD:SetNoDeleteLine(.F.)
	
//	oModelTMP:SetNoUpdateLine(.F.)
    If cTipoModal == "V"    
    	oModelREB:SetNoUpdateLine(.F.)
	EndIf
	oModelDOC:SetNoUpdateLine(.F.)
	oModelANE:SetNoUpdateLine(.F.)
	oModelCNT:SetNoUpdateLine(.F.)
	oModelITC:SetNoUpdateLine(.F.)
	oModelITD:SetNoUpdateLine(.F.)
	
	
     IF ((nOp == 3) .or. (nOp == 4)) //.and. retorno == .T. //inclusão //Alteração

         VAL_EVE_DS()
     	  //pega o ultimo reboque para gravar (ja estava na implemntação do hadulski)
     	 If cTipoModal == "V"
	         cReboque := ""
		      For nI := 1 To oModelREB:Length()
		         oModelREB:GoLine(nI)
		         IF RTRIM(oModelREB:GetValue('REB_REB_ID')) <> ''
		            IF .Not. oModelREB:IsDeleted()
		               IF cReboque == ""
		                  cReboque := alltrim(oModelREB:GetValue('REB_REB_ID'))
		               EndIf
		            EndIf
		         EndIf
		      Next nI
		 EndIf
		 
		 cData := IIF(Empty(oModelTMP:GetValue('TMP_DT_PRE')),"",SDBDate(alltrim(dtoc(oModelTMP:GetValue('TMP_DT_PRE'))),alltrim(oModelTMP:GetValue('TMP_HR_PRE'))))	 	
		 /////////////////////////////////////////////////////
         //////INCIO DA  TRANSACAO DA TAB_PROGRAMACAO/////////
         /////////////////////////////////////////////////////
         //SDBDate(alltrim(oModelTMP:GetValue('TMP_AGDT_I')),alltrim(oModelTMP:GetValue('TMP_HR_PRE'))),;
	     aResult := TCSPExec("proc_diu_programacao_ag",;
                          nOp,; //@operacao int
                          VAL(AllTrim(oModelTMP:GetValue('TMP_PRG_ID'))),; //@prog_id int = null
                          cData,;
                          alltrim(oModelTMP:GetValue('TMP_VEI_ID')) ,; //@vei_id char(10) = null
                          cReboque,;
                          val(AllTrim(oModelTMP:GetValue('TMP_PES_ID'))),;
                          VAL(AllTrim(oModelTMP:GetValue('TMP_TRA_ID'))),; //@trans_id int = null
                          VAL(AllTrim(oModelTMP:GetValue('TMP_OPE_ID'))),; //@op_id int = null
                          VAL(AllTrim(oModelTMP:GetValue('TMP_SUB_ID'))),; //@sub_id int = null
                          0,;//status
                          0,;//ativo
                          SDBDate(date(),time()),;
                          alltrim(cEmpPai),;
                          alltrim(cModal),;
                          'c' + alltrim(SCodUsr()),;
                          val(Alltrim(oModelTMP:GetValue('TMP_EVE_ID'))),;
                          SDBDate(oModelTMP:GetValue('TMP_DT_EVE'),oModelTMP:GetValue('TMP_HR_EVE')),;
                          Alltrim(oModelTMP:GetValue('TMP_CLI_ID')),;
                          substr(Alltrim(oModelTMP:GetValue('TMP_OBSERV')),1,255),;
                          AllTrim(FwFldGet("TMP_VIAGEM"));
                          )
                          
             IF empty(aResult)
		         cErro := AllTrim(TCSQLError())
                 If ExistTemplate("PRAAXML")
                    ExecTemplate("PRAAERRO",.F.,.F.,{cErro,1})
                Endif
		         oModel:SetErrorMessage('PRAA802',,,,,cErro )
		         Return .F.
		      ELSE
		         IF AllTrim(aResult[2]) <> ''
		            cErro := AllTrim(aResult[2])
                    If ExistTemplate("PRAAXML")
                        ExecTemplate("PRAAERRO",.F.,.F.,{cErro,2})
                    Endif
		            oModel:SetErrorMessage('PRAA802',,,,,cErro )
		            Return .F.
		         Else
		            if ValType(aResult[1])='C'
		               cProg_ID := aResult[1]
		            else
		               cProg_ID := Str(aResult[1])
		            endif
		            
		            If nOp == 3
		              
		               cTmpEvId := IIF(Empty(oModelTMP:getvalue('TMP_EVE_ID')), "", AllTrim(oModelTMP:getvalue('TMP_EVE_ID'))) 
		            
		               oModelTMP:setvalue('TMP_PRG_ID',CVALTOCHAR(aResult[1]))
		               cQuery := " select eve_desc from tab_agen_eventos "
		               cQuery += "where eve_id = '" + cTmpEvId + "'"
		               cQuery += " and eve_modal = '"+ alltrim(cModal) + "'"
		               dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),consultaEvento, .F., .T.)
		               dbselectarea(consultaEvento)

		               oModelTMP:setvalue('TMP_EVE_DS',alltrim((consultaEvento)->eve_desc))

		               oModelTMP:setvalue('TMP_CRE_ID',alltrim(cEmpPai))

		               cQuery := " select cli_nome from tab_clientes where cli_id = '" + cEmpPai + "'"
		               DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cClieresp,.F.,.T.)
		               oModelTMP:setvalue('TMP_CRE_DS',alltrim((cClieresp)->cli_nome))

		               oModelTMP:setvalue('TMP_STR_PG',STRZERO(0,6-len(alltrim(CVALTOCHAR(aResult[1])))) + alltrim(CVALTOCHAR(aResult[1])))
		               //STRZERO(0,9-Len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))))+AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))+;
		            EndIF
		         EndIF
		      EndIF

		 oModelTMP:setvalue('TMP_DT_ENT',oModelTMP:GetValue('TMP_DT_PRE'))
		 oModelTMP:setvalue('TMP_HR_ENT',substr(alltrim(oModelTMP:GetValue('TMP_HR_PRE')),11,5))

	     /////////////////////////////////////////////////////
        //////FIM DA  TRANSACAO DA TAB_PROGRAMACAO///////////
        /////////////////////////////////////////////////////


	     /////////////////////////////////////////////////////
        //////INCIO DA  TRANSACAO DA TAB_PROG_JANELA//////////
        /////////////////////////////////////////////////////
        if alltrim(cErro) = ''
	        aResult := {}
	        aResult := TCSPExec("proc_diu_tab_prog_janela",;
	                          nOp,; //@operacao int
	                          VAL(AllTrim(oModelTMP:GetValue('TMP_PRG_ID'))),; //@prog_id int = null
	                          oModelTMP:GetValue('TMP_QUANT'),;
	                          SDBDate(alltrim(oModelTMP:GetValue('TMP_DT_INE'))+ " "+alltrim(oModelTMP:GetValue('TMP_AGHR_I'))),;
	                          SDBDate(alltrim(oModelTMP:GetValue('TMP_DT_FIE'))+ " "+alltrim(oModelTMP:GetValue('TMP_AGHR_F'))),;
	                          oModelTMP:GetValue('TMP_PA_ID'),;
	                          oModelTMP:GetValue('TMP_PAJ_ID'),;
	                          oModelTMP:GetValue('TMP_PESO'),;
	                          oModelTMP:GetValue('TMP_CUBICO'),;
	                          SDBDate(alltrim(dtoc(oModelTMP:GetValue('TMP_DT_PRE'))),alltrim(oModelTMP:GetValue('TMP_HR_PRE'))),;
	                          val(alltrim(oModelTMP:GetValue('TMP_DC_ID')));
	                          )

		      IF (empty(aResult)) .and. (AllTrim(TCSQLError()) <> '')
		         cErro := AllTrim(TCSQLError())
		         oModel:SetErrorMessage('PRAA802',,,,,cErro )
		         Return .F.
		      else
		      			IF AllTrim(aResult[1]) <> ''
			              cErro := "Ocorreu um erro no processo de gravação da janela"+Chr(13)+AllTrim(aResult[1])
			           EndIf
		      endif
	      endif

        /////////////////////////////////////////////////////
        //////FIM DA  TRANSACAO DA TAB_PROG_JANELA////////////
        /////////////////////////////////////////////////////

	    ////////////////////////////////////////////
	    /////INICIO GRAVACAO DO REBOQUE////////////
	    //////////////////////////////////////////////
	    if alltrim(cErro) = '' .And. cTipoModal == 'V'
	        cQryReboque := " select prog_id from rel_prog_reboque where prog_id = " + alltrim(oModelTMP:getvalue('TMP_PRG_ID'))
	    	cQryReboque := ChangeQuery(cQryReboque)
    
		    DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQryReboque),cAliasEmp,.F.,.T.)
		    
		    dbSelectArea(cAliasEmp)
		    (cAliasEmp)->(DbGoTop())
	    	
	    	If((cAliasEmp)->prog_id)
		    	sqlExec := " delete from rel_prog_reboque where prog_id = " + alltrim(oModelTMP:getvalue('TMP_PRG_ID'))
				TCSQLExec(sqlExec)
            Else

			     For nI := 1 To oModelREB:Length()
				 	 oModelREB:GoLine( nI)
				     if oModelREB:IsDeleted() = .F.
				            if (alltrim(oModelREB:GetValue('REB_REB_ID')) <> '')
	
					     		aResult := TCSPExec("proc_di_rel_prog_reboque_ag",;
				                                               3,; //@operacao int
				                                               VAL(AllTrim(oModelTMP:GetValue('TMP_PRG_ID'))),; //@prog_id int
				                                               alltrim(oModelREB:GetValue('REB_REB_ID'));  //@w_reb_id char(10)
				                                               )
	
								IF  (empty(aResult)) .and. (AllTrim(TCSQLError()) <> '')
				                     cErro := STR0098+Chr(13)+AllTrim(TCSQLError())
				                ELSE
				                    IF AllTrim(aResult[1]) <> ''
				                          cErro := STR0098+Chr(13)+AllTrim(aResult[1])
				                    EndIf
				                EndIf
			                 endif
					  endif
				  Next nI
				  
				  (cAliasEmp)->(dbCloseArea())
			  
			  EndIf
	   	endif
         ////////////////////////////////////////////
	     /////FIM GRAVACAO DO REBOQUE////////////////
	     ////////////////////////////////////////////


	     /////////////////////////////////////////////////////
        //////INICIO DAS TRANSAÇÕES DE containerS////////////
        /////////////////////////////////////////////////////




	     /////////////////////////////////////////////////////
        //////INICIO DAS TRANSAÇÕES DE DOCUMENTOS///////////////////////////
        /////////////////////////////////////////////////////

        IF AllTrim(cErro) == ""
         lAlterouGrid := .T.

         if lAlterouGrid == .T.
               For nI := 1 To oModelDOC:Length()
                  oModelDOC:GoLine(nI)


                     If oModelDOC:IsDeleted()
                        IF AllTrim(cErro) == ""
                                    aResult := TCSPExec("proc_diu_programacao_doc_ag",;
                                                        5,; //@operacao int
                                                        IIF(AllTrim(oModelDOC:GetValue('DOC_DP_ID')) = '',0,VAL(AllTrim(oModelDOC:GetValue('DOC_DP_ID')))),;
                                                        VAL(AllTrim(oModelTMP:GetValue('TMP_PRG_ID'))),; //@prog_id int
                                                        alltrim(oModelDOC:getvalue('DOC_DOC_ID')),; //@v_dent_id char(30)
                                                        '',; //@v_tp_dent_dsai char(1)
                                                        0,;
                                                        '',;
                                                        '';
                                                        )
                                    IF empty(aResult)
                                       cErro := STR0099+Chr(13)+AllTrim(TCSQLError())
                                       Exit
                                    ELSE
                                       IF AllTrim(aResult[1]) <> ''
                                          cErro := STR0099+Chr(13)+AllTrim(aResult[1])
                                          Exit
                                       EndIf
                                    EndIf
                         endif
                     EndIf
               Next nI
               For nI := 1 To oModelDOC:Length()
                  oModelDOC:GoLine(nI)
                  
                     if  (AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) == 'S')
						 cSqlDOC := SQLSel003TabDocSaida(alltrim(oModelDOC:getvalue('DOC_RES_ID')), AllTrim(oModelDOC:GetValue('DOC_NUM_DC')))
						 
						 dbUseArea(.T., 'TOPCONN', TCGenQry(,,cSqlDOC),cAlsDOC, .F., .T.)
						 IF (AllTrim((cAlsDOC)->cli_id) <> '')
							 oModelDOC:loadvalue('DOC_BEN',    AllTrim((cAlsDOC)->cli_nome))
							 oModelDOC:loadvalue('DOC_BEN_ID', AllTrim((cAlsDOC)->cli_id)  )
							 oModelDOC:loadvalue('DOC_BEN_CG', AllTrim((cAlsDOC)->cli_cgc) )
						 EndIf
						 
						 (cAlsDOC)->(dbCloseArea())
					 
					EndIf

              		 If oModelDOC:IsInserted() .And. !oModelDOC:IsDeleted() .And. !SEmpty(alltrim(oModelDOC:getvalue('DOC_DOC_ID')))
                        IF AllTrim(cErro) == ""
                           aResult := TCSPExec("proc_diu_programacao_doc_ag",;
                                               3,; //@operacao int
                                               VAL(AllTrim(oModelDOC:GetValue('DOC_DP_ID'))),; //@prog_id int
                                               VAL(AllTrim(oModelTMP:GetValue('TMP_PRG_ID'))),; //@prog_id int
                                               alltrim(oModelDOC:getvalue('DOC_DOC_ID')),;
                                               AllTrim(oModelDOC:GetValue('DOC_TPO_ES')),;  //@v_tp_dent_dsai char(1)
                                               IIF(AllTrim(oModelDOC:GetValue('DOC_RES_ID'))='',0,val(AllTrim(oModelDOC:GetValue('DOC_RES_ID')))),;
                                               AllTrim(oModelDOC:GetValue('DOC_BEN_ID')),;
                                               IIF(AllTrim(oModelDOC:GetValue('DOC_CFOP'))='.','',AllTrim(oModelDOC:GetValue('DOC_CFOP')));
                                               )
                           IF empty(aResult)
                              cErro := STR0099+Chr(13)+AllTrim(TCSQLError())
                              Exit
                           ELSE
                              IF AllTrim(aResult[1]) <> ''
                                 cErro := STR0099+Chr(13)+AllTrim(aResult[1])
                                 Exit
                              EndIf
                           EndIf
                        EndIf
                     elseIf oModelDOC:IsUpdated() .And. !oModelDOC:IsDeleted() .And. !SEmpty(alltrim(oModelDOC:getvalue('DOC_DOC_ID')))
                        IF AllTrim(cErro) == ""
                           aResult := TCSPExec("proc_diu_programacao_doc_ag",;
                                               2,; //@operacao int
                                               VAL(AllTrim(oModelDOC:GetValue('DOC_DP_ID'))),; //@prog_id int
                                               VAL(AllTrim(oModelTMP:GetValue('TMP_PRG_ID'))),; //@prog_id int
                                               alltrim(oModelDOC:getvalue('DOC_DOC_ID')),;
                                               AllTrim(oModelDOC:GetValue('DOC_TPO_ES')),;  //@v_tp_dent_dsai char(1)
                                               IIF(AllTrim(oModelDOC:GetValue('DOC_RES_ID'))='',0,val(AllTrim(oModelDOC:GetValue('DOC_RES_ID')))),;
                                               AllTrim(oModelDOC:GetValue('DOC_BEN_ID')),;
                                               IIF(AllTrim(oModelDOC:GetValue('DOC_CFOP'))='.','',AllTrim(oModelDOC:GetValue('DOC_CFOP')));
                                               )
                           IF empty(aResult)
                              cErro := STR0099+Chr(13)+AllTrim(TCSQLError())
                              Exit
                           ELSE
                              IF AllTrim(aResult[1]) <> ''
                                 cErro := STR0099+Chr(13)+AllTrim(aResult[1])
                                 Exit
                              EndIf
                           EndIf
                        EndIf
                     EndIf
             Next nI
         EndIf
      EndIf
        /////////////////////////////////////////////////////
        //////FIM DAS TRANSAÇÕES DE DOCUMENTOS///////////////
        /////////////////////////////////////////////////////

        if alltrim(cErro) = ''
//		     	 sqlExec := " delete from tab_programacao_cnt where prog_id = " + alltrim(oModelTMP:getvalue('TMP_PRG_ID'))
//				 TCSQLExec(sqlExec)

				 For nI := 1 To oModelCNT:Length()
					oModelCNT:GoLine( nI)
					if  (alltrim(oModelCNT:getvalue('CNT_CNT_ID')) <> '') .or. (alltrim(oModelCNT:getvalue('CNT_TISO_I')) <> '' ) .or. (alltrim(oModelCNT:getvalue('CNT_RES_ID')) <> '' )
						nRegOp := 0 // Sem alteração
						If !oModelCNT:IsDeleted() .And. oModelCNT:IsInserted() // Inserção
					       nRegOp := 3
					    ElseIf !oModelCNT:IsDeleted() .And. !oModelCNT:IsInserted() .And. oModelCNT:IsUpdated()// Atualização
					    	nRegOp := 4
					    ElseIf oModelCNT:IsDeleted() .And. !oModelCNT:IsInserted() // Exclusão
					    	nRegOp := 5
					    EndIf
					    If nRegOp != 0
							 aResult := {}
							 If lTemDepot
							     opr_depot  := oModelCNT:GetValue('CNT_DEPOT')
				                 cod_armad  := AllTrim(oModelCNT:GetValue('CNT_ARMADO'))
				                 cod_progra := val(AllTrim(oModelCNT:GetValue('CNT_PROGRA')))
							 EndIf
							 
			                 aResult := TCSPExec("proc_diu_tab_programacao_cnt",;
				                          nRegOp,; //@operacao int
				                          val(AllTrim(oModelCNT:GetValue('CNT_PCNT_I'))),; //@prog_id int = null
				                          val(alltrim(oModelTMP:GetValue('TMP_PRG_ID'))),;
				                          AllTrim(oModelCNT:GetValue('CNT_CNT_ID')),;
				                          AllTrim(oModelCNT:GetValue('CNT_TIS_TA')),;
				                          AllTrim(oModelCNT:GetValue('CNT_TISO_I')),;
				                          val(AllTrim(oModelCNT:GetValue('CNT_QTD_CN'))),;
				                          val(AllTrim(oModelCNT:GetValue('CNT_RES_ID'))),;
				                          GetDpId(oModelTMP:GetValue('TMP_PRG_ID'),oModelCNT:GetValue('CNT_DP_DS'),oModelCNT:GetValue('CNT_DP_ID')),;
				                          oModelCNT:GetValue('CNT_CNTCHE'),;
				                          substr(oModelCNT:GetValue('CNT_TPO_ES'),1,1),;
				                          opr_depot,;
				                          cod_armad,;
				                          cod_progra;
				                          )

				             IF empty(aResult)
						         cErro := AllTrim(TCSQLError())
						         oModel:SetErrorMessage('PRAA802',,,,,cErro )
						         Return .F.
						      ELSE
						         IF AllTrim(aResult[2]) <> ''
						            cErro := AllTrim(aResult[2])
						            oModel:SetErrorMessage('PRAA802',,,,,cErro )
						            Return .F.
						         Else
						             oModelCNT:setvalue('CNT_PCNT_I',CVALTOCHAR(aResult[1]))
						         EndIf
						      EndIf
		                endif
			     	endif
		     	Next nI
		    endif

     	/////////////////////////////////////////////////////
        //////FIM DAS TRANSAÇÕES DE containerS///////////////////////////
        /////////////////////////////////////////////////////


        /////////////////////////////////////////////////////
        //////INICIO DAS TRANSAÇÕES DE ITENS DE CARGA////////
        /////////////////////////////////////////////////////
        IF AllTrim(cErro) == ""
          lAlterouGrid := .T.

         if lAlterouGrid == .T.

            IF AllTrim(cErro) == ""
               For nI := 1 To oModelITC:Length()
                  oModelITC:GoLine(nI)
                  If (AllTrim(oModelITC:GetValue('ITC_LOT_ID')) <> '')
                  	If oModelITC:IsDeleted()
									aResult := TCSPExec("proc_diu_tab_programacao_itens_carga",;
                                               5,; //@operacao int
                                               VAL(AllTrim(oModelITC:GetValue('ITC_PIC_ID'))),;
                                               VAL(AllTrim(oModelTMP:GetValue('TMP_PRG_ID'))),;
                                               val(AllTrim(oModelITC:GetValue('ITC_DP_ID'))),;
                                               val(AllTrim(oModelITC:GetValue('ITC_RES_ID'))),;
                                               AllTrim(oModelITC:GetValue('ITC_LOT_ID')),;
                                               val(AllTrim(oModelITC:GetValue('ITC_LOT_IT'))),;
                                               val(AllTrim(oModelITC:GetValue('ITC_QTD_VO'))),;
                                               oModelITC:GetValue('ITC_M3');
                                               )

		                           IF empty(aResult)
		                              cErro := 'Ocorreu um erro no processo de gravação dos intens de carga.'+Chr(13)+AllTrim(TCSQLError())
		                           ELSE
		                              IF AllTrim(aResult[1]) <> ''
		                                 cErro := 'Ocorreu um erro no processo de gravação dos intens de carga.'+Chr(13)+AllTrim(aResult[1])
		                              EndIf
		                           EndIf
                     elseIf oModelITC:IsInserted() .And. !oModelITC:IsDeleted() .And. !SEmpty(alltrim(oModelITC:getvalue('ITC_LOT_ID')))

//                     If .Not. oModelITC:IsDeleted()
                        IF AllTrim(cErro) == ""
                        	    cQuery := " select dp_id,dent_id from rel_dent_programacao where dent_id = '" + AllTrim(oModelITC:GetValue('ITC_DP_DS')) + "' and prog_id = " + alltrim(oModelTMP:getvalue('TMP_PRG_ID'))
						   		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias2,.F.,.T.)

								if alltrim((cAlias2)->dent_id) <> ''
									oModelITC:setValue('ITC_DP_ID',alltrim(str((cAlias2)->dp_id)))
								endif
									aResult := TCSPExec("proc_diu_tab_programacao_itens_carga",;
                                               3,; //@operacao int
                                               VAL(AllTrim(oModelITC:GetValue('ITC_PIC_ID'))),;
                                               VAL(AllTrim(oModelTMP:GetValue('TMP_PRG_ID'))),;
                                               val(AllTrim(oModelITC:GetValue('ITC_DP_ID'))),;
                                               val(AllTrim(oModelITC:GetValue('ITC_RES_ID'))),;
                                               AllTrim(oModelITC:GetValue('ITC_LOT_ID')),;
                                               val(AllTrim(oModelITC:GetValue('ITC_LOT_IT'))),;
                                               val(AllTrim(oModelITC:GetValue('ITC_QTD_VO'))),;
                                               oModelITC:GetValue('ITC_M3');
                                               )

		                           IF empty(aResult)
		                              cErro := 'Ocorreu um erro no processo de gravação dos intens de carga.'+Chr(13)+AllTrim(TCSQLError())
		                           ELSE
		                              IF AllTrim(aResult[1]) <> ''
		                                 cErro := 'Ocorreu um erro no processo de gravação dos intens de carga.'+Chr(13)+AllTrim(aResult[1])
		                              EndIf
		                           EndIf
								//endif
                        EndIf
                     //EndIf
                     elseIf oModelITC:IsUpdated() .And. !oModelITC:IsDeleted() .And. !SEmpty(alltrim(oModelITC:getvalue('ITC_PIC_ID')))
                        IF AllTrim(cErro) == ""
                        	    cQuery := " select dp_id,dent_id from rel_dent_programacao where dent_id = '" + AllTrim(oModelITC:GetValue('ITC_DP_DS')) + "' and prog_id = " + alltrim(oModelTMP:getvalue('TMP_PRG_ID'))
						   		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias2,.F.,.T.)

								if alltrim((cAlias2)->dent_id) <> ''
									oModelITC:setValue('ITC_DP_ID',alltrim(str((cAlias2)->dp_id)))
								endif
									aResult := TCSPExec("proc_diu_tab_programacao_itens_carga",;
                                               4,; //@operacao int
                                               VAL(AllTrim(oModelITC:GetValue('ITC_PIC_ID'))),;
                                               VAL(AllTrim(oModelTMP:GetValue('TMP_PRG_ID'))),;
                                               val(AllTrim(oModelITC:GetValue('ITC_DP_ID'))),;
                                               val(AllTrim(oModelITC:GetValue('ITC_RES_ID'))),;
                                               AllTrim(oModelITC:GetValue('ITC_LOT_ID')),;
                                               val(AllTrim(oModelITC:GetValue('ITC_LOT_IT'))),;
                                               val(AllTrim(oModelITC:GetValue('ITC_QTD_VO'))),;
                                               oModelITC:GetValue('ITC_M3');
                                               )

		                           IF empty(aResult)
		                              cErro := 'Ocorreu um erro no processo de gravação dos intens de carga.'+Chr(13)+AllTrim(TCSQLError())
		                           ELSE
		                              IF AllTrim(aResult[1]) <> ''
		                                 cErro := 'Ocorreu um erro no processo de gravação dos intens de carga.'+Chr(13)+AllTrim(aResult[1])
		                              EndIf
		                           EndIf
								//endif
                        EndIf
                     endif
                  EndIf
               Next nI
            EndIf
         EndIf
      EndIf
        /////////////////////////////////////////////////////
        //////FIM DAS TRANSAÇÕES DE ITENS DE CARGA///////////
        /////////////////////////////////////////////////////

        /////////////////////////////////////////////////////
        //////INICIO DAS TRANSAÇÕES DE ITENS DE DESCARGA/////
        /////////////////////////////////////////////////////

        IF AllTrim(cErro) == ""
         lAlterouGrid := .T.

         if lAlterouGrid == .T.
            IF AllTrim(cErro) == ""
               For nI := 1 To oModelITD:Length()
                  oModelITD:GoLine(nI)
                  If (AllTrim(oModelITD:GetValue('ITD_ESP_ID')) <> '')
                     If oModelITD:IsDeleted()
										aResult := TCSPExec("proc_diu_tab_programacao_itens_desc",;
		                                               5,; //@operacao int                                      //	@w_operacao	int
		                                               VAL(AllTrim(oModelITD:GetValue('ITD_PID_ID'))),;         //  @w_pid_id	int
		                                               VAL(AllTrim(oModelITD:GetValue('ITD_DP_ID'))),;                                        //  @w_dp_id	int
		                                               AllTrim(oModelITD:GetValue('ITD_ESP_ID')),;              //  @w_esp_id	char
		                                               VAL(AllTrim(oModelITD:GetValue('ITD_QTD_VO'))),;         //  @w_pid_qt_volumes	int
		                                               oModelITD:GetValue('ITD_M3'),;                           //  @w_pid_m3	float
		                                               oModelITD:GetValue('ITD_PESO'),;                         //  @w_pid_peso	float
		                                               AllTrim(oModelITD:GetValue('ITD_FAM_ID')),;              //  @w_fam_id	char
		                                               AllTrim(oModelITD:GetValue('ITD_DESC'));                 //  @w_pid_descricao_produto	varchar
		                                               )                                                        //  @Msg_Retorno	varchar
		                           IF empty(aResult)
		                              cErro := 'Ocorreu um erro no processo de gravação dos intens de descarga.'+Chr(13)+AllTrim(TCSQLError())
		                           ELSE
		                              IF AllTrim(aResult[1]) <> ''
		                                 cErro := 'Ocorreu um erro no processo de gravação dos intens de descarga.'+Chr(13)+AllTrim(aResult[1])
		                              EndIf
		                           EndIf
                     elseIf oModelITD:IsInserted() .And. !oModelITD:IsDeleted() .And. !SEmpty(alltrim(oModelITD:getvalue('ITD_ESP_ID')))
                        IF AllTrim(cErro) == ""
	                        	cQuery := " select dp_id,dent_id from rel_dent_programacao where dent_id = '" + AllTrim(oModelITD:GetValue('ITD_DP_DS')) + "' and prog_id = " + alltrim(oModelTMP:getvalue('TMP_PRG_ID'))
	                        	cAlias := Getnextalias()
						   		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)

								if alltrim((cAlias)->dent_id) <> ''
										oModelITD:setValue('ITD_DP_ID',alltrim(str((calias)->dp_id)))
								endif
										aResult := TCSPExec("proc_diu_tab_programacao_itens_desc",;
		                                               3,; //@operacao int
		                                               VAL(AllTrim(oModelITD:GetValue('ITD_PID_ID'))),;
		                                               VAL(AllTrim(oModelITD:GetValue('ITD_DP_ID'))),;
		                                               AllTrim(oModelITD:GetValue('ITD_ESP_ID')),;
		                                               VAL(AllTrim(oModelITD:GetValue('ITD_QTD_VO'))),;
		                                               oModelITD:GetValue('ITD_M3'),;
		                                               oModelITD:GetValue('ITD_PESO'),;
		                                               AllTrim(oModelITD:GetValue('ITD_FAM_ID')),;
		                                               AllTrim(oModelITD:GetValue('ITD_DESC'));
		                                               )
		                           IF empty(aResult)
		                              cErro := 'Ocorreu um erro no processo de gravação dos intens de descarga.'+Chr(13)+AllTrim(TCSQLError())
		                           ELSE
		                              IF AllTrim(aResult[1]) <> ''
		                                 cErro := 'Ocorreu um erro no processo de gravação dos intens de descarga.'+Chr(13)+AllTrim(aResult[1])
		                              EndIf
		                           EndIf
								//endif
                        EndIf
                     //EndIf
                     elseIf oModelITD:IsUpdated() .And. !oModelITD:IsDeleted() .And. !SEmpty(alltrim(oModelITD:getvalue('ITD_PID_ID')))
                        IF AllTrim(cErro) == ""
	                        	cQuery := " select dp_id,dent_id from rel_dent_programacao where dent_id = '" + AllTrim(oModelITD:GetValue('ITD_DP_DS')) + "' and prog_id = " + alltrim(oModelTMP:getvalue('TMP_PRG_ID'))
	                        	cAlias := Getnextalias()
						   		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F.,.T.)

								if alltrim((cAlias)->dent_id) <> ''
										oModelITD:setValue('ITD_DP_ID',alltrim(str((calias)->dp_id)))
								endif
										aResult := TCSPExec("proc_diu_tab_programacao_itens_desc",;
		                                               4,; //@operacao int
		                                               VAL(AllTrim(oModelITD:GetValue('ITD_PID_ID'))),;
		                                               VAL(AllTrim(oModelITD:GetValue('ITD_DP_ID'))),;
		                                               AllTrim(oModelITD:GetValue('ITD_ESP_ID')),;
		                                               VAL(AllTrim(oModelITD:GetValue('ITD_QTD_VO'))),;
		                                               oModelITD:GetValue('ITD_M3'),;
		                                               oModelITD:GetValue('ITD_PESO'),;
		                                               AllTrim(oModelITD:GetValue('ITD_FAM_ID')),;
		                                               AllTrim(oModelITD:GetValue('ITD_DESC'));
		                                               )
		                           IF empty(aResult)
		                              cErro := 'Ocorreu um erro no processo de gravação dos intens de descarga.'+Chr(13)+AllTrim(TCSQLError())
		                           ELSE
		                              IF AllTrim(aResult[1]) <> ''
		                                 cErro := 'Ocorreu um erro no processo de gravação dos intens de descarga.'+Chr(13)+AllTrim(aResult[1])
		                              EndIf
		                           EndIf
								//endif
                        EndIf
                     endif
                  EndIf
               Next nI
            EndIf
         EndIf
      EndIf
        /////////////////////////////////////////////////////
        //////FIM DAS TRANSAÇÕES DE ITENS DE DESCARGA///////////////
        /////////////////////////////////////////////////////

        /////////////////////////////////////////////////////
        //////INICIO DAS TRANSAÇÕES DE ANEXOS///////////////
        /////////////////////////////////////////////////////
        IF AllTrim(cErro) == ""

          	 lAlterouGrid := .T.
            if lAlterouGrid == .T.
          	   aResult := TCSPExec("proc_diu_tab_progr_anexos",;
                                5,; //@operacao int
                                VAL(AllTrim(oModelTMP:GetValue('TMP_PRG_ID'))),; //@prog_id int
                                0,; //@ane_prog_id Int
                                '',; //@ane_arquivo char(255)
                                ''; //@ane_obs char(50)
                                )
	            IF empty(aResult)
	               cErro := STR0100+Chr(13)+AllTrim(TCSQLError())
	            ELSE
	               IF AllTrim(aResult[1]) <> ''
	                  cErro := STR0100+Chr(13)+AllTrim(aResult[1])
	               EndIf
	            EndIf

               For nI := 1 To oModelANE:Length()
                  oModelANE:GoLine(nI)
                  If AllTrim(oModelANE:GetValue('ANE_ARQUIV')) <> ''
                     If .Not. oModelANE:IsDeleted()
                        IF AllTrim(cErro) == ""
                           aResult := TCSPExec("proc_diu_tab_progr_anexos",;
                                               3,; //@operacao int
                                               VAL(AllTrim(oModelTMP:GetValue('TMP_PRG_ID'))),; //@prog_id int
                                               VAL(AllTrim(oModelANE:GetValue('ANE_ANE_ID'))),; //@ane_prog_id int
                                               AllTrim(oModelANE:GetValue('ANE_ARQUIV')),;  //@ane_arquivo char(255)
                                               AllTrim(oModelANE:GetValue('ANE_OBSERV'));  //@ane_obs char(50)
                                               )
                           IF empty(aResult)
                              cErro := STR0100+Chr(13)+AllTrim(TCSQLError())
                           ELSE
                              IF AllTrim(aResult[1]) <> ''
                                 cErro := STR0100+Chr(13)+AllTrim(aResult[1])
                              EndIf
                           EndIf
                        EndIf
                     EndIf
                  EndIf
               Next nI
            EndIf
         EndIf


	    IF AllTrim(cErro) <> ""
	         IF nOp == 3//Inclusão
	            TCSPExec("proc_diu_programacao_ag",5,VAL(AllTrim(oModelTMP:GetValue('TMP_PRG_ID'))),;
	                     '','','',0,0,0,0,0,0,'','','','',0,'','','')
	            oModel:SetErrorMessage('PRAA802',,,,,cErro,STR0094)
	            Return .F.
	         ELSE
	            MsgStop(cErro+Chr(13)+	STR0094)
	            Final(cErro+STR0101,,.F.)
	            Return .F.
	         EndIf
	    EndIf

//	      GERARCODES(2,AllTrim(oModelTMP:GetValue('TMP_PRG_ID')))
        
        //chamada para minuta...        
        
        if !Empty(cProg_ID) .and. cModal='V'
           	if AllTrim(GETPSARA("HBILITA_IMPRESSAO_MINUTA")) == 'S' 
				if MSGYESNO('Gostaria de Imprimir a Minuta de Agendamento?')
					PRAR802()
				endif
			END 
        endif 
     endif
 
return .T.

/*/{Protheus.doc} PRALogMsg
//TODO Descrição auto-gerada.
Padronizar a geração de mensagens no console
@author Mohamed S B Djalo
@since 21/02/2018
@version undefined
@param cLevel, characters, descricao
@param cMsg, characters, descricao
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Function PRALogMsg(cLevel, cMsg)
	Default cLevel := "INFO"
	Default cMsg := ""
    
	cLevel := PadR(Upper(cLevel), 7)
    FWLogMsg(cLevel, "LAST", "SIGAPRA", ProcName(2), , "01", cMsg, , ,{}, 2)
    
Return

/*/{Protheus.doc} erro
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Funcao chamada pelo bloco de codigo do Try/exctption do programa
/*/
static function erro(E)
    PRALogMsg(,E:DESCRIPTION + CRLF + E:ERRORSTACK)
return .T.

/*/{Protheus.doc} PRAC938
@author   Fernando da Cruz Pinheiro
@version  P12
@since    02/01/2014
@obs     Funcao para fazer ooperacao de exponenciação
/*/
static function A802ELEVA(x,y)
	Local nf := 0
    Local nb := 0

	 nb := x

     for nf := 1 to y-1
         	x := nb * x
     next nf
return x


/*/{Protheus.doc} PRAC938
@author   Fernando da Cruz Pinheiro
@version  P12
@since    02/01/2014
@obs     Funcao para validar se o CNT_ID é válido.
/*/
function A802VALDIG(cCNT_ID)
	Local c_tabela := ''
    Local n_total  := 0
    Local nk := 0
    Local nl := 0
    Local lResult := .T.

    n_total := 0
    c_tabela := '1012131415161718192021232425262728293031323435363738'
    n_total  := n_total +;
		                    (val(substring(c_tabela,((asc(substring(cCNT_ID,1,1))-64)*2)-1,2))) ;
		            +       (val(substring(c_tabela,((asc(substring(cCNT_ID,2,1))-64)*2)-1,2))*2) ;
		            +       (val(substring(c_tabela,((asc(substring(cCNT_ID,3,1))-64)*2)-1,2))*4) ;
		            +       (val(substring(c_tabela,((asc(substring(cCNT_ID,4,1))-64)*2)-1,2))*8)


	nk:= 4

	while nk <= 9
      n_total := n_total + (val(substring(cCNT_ID,nk+1,1))* A802ELEVA(2,nk))
      nk := nk + 1
    enddo

    nl := mod(n_total,11)

    if (nl > 9)
    	nl := 0
    endif

   cdigito := str(nl);

   if nl = val(substring(cCNT_ID,11,1))
       lResult := .T.
   else
       lResult:= .F.
   endif

return lResult


/*static function A802GEARQ(cNomeArquivo,cCaminho,cConteudo)
	local nHDestino := 0

    if DirRemove('C:\TOTVS 11\Log\SQLs.txt',Nil,.F.)
	   nHDestino := MakeDir('C:\TOTVS 11\Log\SQLs.txt',Nil,.F.)
	endIf
	
	// Testa a criação do arquivo de destino
	If nHDestino != 0
		MsgStop('Erro ao criar destino. Ferror = '+str(ferror(),4),'Erro')
		Return .F.
	Endif

	FSEEK(nHDestino,2)
	FWRITE(nHDestino,chr(13)+chr(10) + dtoc(date()) + ' ' + TIME() + chr(13)+chr(10) + cConteudo)
	FCLOSE(nHDestino)


return*/


/*/{Protheus.doc} PRAC938
@author   Fernando da Cruz Pinheiro
@version  P12
@since    02/01/2014
@obs     Funcao para validar se o CNT_ID é válido.
/*/
static function VAL_CNT()
  Local oModel    := FWModelActive()
  Local oModelTMP := oModel:getmodel('PRAA802')
  Local oModelCNT
  Local cAlias := GetNextAlias()
  Local bError := errorBlock({|e|erro(e)})
  Local nI := 0
  Local cQuery := ''
  Local cQueryAux := ''
  Local nQuantCNT := 0
  Local contador := 0
  Local containerAtu := ''
  Private cdigito := ''

	BEGIN SEQUENCE
	        

		oModelCNT := oModel:GetModel('PRAA802CNT')

		if (alltrim(oModelCNT:GetValue('CNT_CNT_ID')) <> '' )
		   
		    if (cSubOpCntCheio == '')
		  	     StaticCall(PRAA802,VAL_SUB_ID)      
		    EndIf
		
            if !(cSubOpCntCheio == '1') .And. !(cSubOpCntVazio == '1')
            	oModel:SetErrorMessage('PRAA802CNT','CNT_CNT_ID','','','3068','Operação negada.','Sub operação '+alltrim(oModelTMP:getvalue('TMP_SUB_DS'))+' não permite a operação com contêineres.',nil,nil)
            	cSubOpCntCheio  := ''
				cSubOpCntVazio  := ''
				cSubOpMercSolta := ''
            	Return .F.
            endif		

			if (len(alltrim(oModelCNT:GetValue('CNT_CNT_ID'))) <> 11 )
				oModel:SetErrorMessage('PRAA802CNT','CNT_CNT_ID','','','3069', STR0269 + CHr(13) +STR0270,STR0271,nil,nil)
				return .F.
			endif

			for nI := 1 to 11

				if nI <= 4

					if isdigit(substring(alltrim(oModelCNT:GetValue('CNT_CNT_ID')),nI,1))
						oModel:SetErrorMessage('PRAA802CNT','CNT_CNT_ID','','','3070', STR0269 + CHr(13) +STR0270,STR0271,nil,nil)
						return .F.
					endif

				endif

				if nI > 4

					if isalpha(substring(alltrim(oModelCNT:GetValue('CNT_CNT_ID')),nI,1))	  
						oModel:SetErrorMessage('PRAA802CNT','CNT_CNT_ID','','','3071', STR0270 + CHr(13) +STR0270,STR0271,nil,nil)
						return .F.
					endif

				endif

			next nI

			if A802VALDIG(alltrim(oModelCNT:GetValue('CNT_CNT_ID'))) = .F.
				oModel:SetErrorMessage('PRAA802CNT','CNT_CNT_ID','','','3072', STR0272,STR0273 + alltrim(cdigito) + Chr(13) +;
				STR0274+Chr(13)+ ;
				STR0275,nil,nil)
				return .F.
			else

				containerAtu := AllTrim(oModelCNT:GetValue('CNT_CNT_ID'))

				if !Empty(oModelTMP:getvalue('TMP_OPE_ID')) .And. !Empty(omodelCNT:getvalue('CNT_DP_DS')) .And. DOC_CNT_SAID()        
                     
					if alltrim(omodelCNT:getvalue('CNT_RES_NU')) = ''

						if alltrim(omodelTMP:getvalue('TMP_CLI_ID')) = ''
							oModel:SetErrorMessage('PRAA802CNT','CNT_CNT_ID','','','3073', "Operação negada.","Informe o cliente de carga para pesquisar o container.",nil)
							return .F.
						endif

						cQuery := 	" select isnull(a.cnt_id,'') as cnt_id, "
						cQuery += 	"        isnull(a.tiso_id,'') as tiso_id, "
						cQuery += 	"        isnull(a.status,'VAZIO') as status, "
						cQuery += 	"        c.tiso_tamanho cnt_tipo "
						cQuery += 	"   from vw_inventario_container a "
						cQuery += 	"        left join tab_container b "
						cQuery +=  "                  on b.cnt_id  = a.cnt_id "
						cQuery +=  "        left join tab_tipo_iso c "
						cQuery +=  "                  on c.tiso_id  = b.tiso_id"
						cQuery +=  "  where a.cli_id = '" +alltrim(oModelTMP:getvalue('TMP_CLI_ID'))+ "'"

					else

						cQuery :=  " select isnull(a.cnt_id,'') as cnt_id, "
						cQuery +=  "        isnull(a.tiso_id,'') as tiso_id, "
						cQuery +=	"        isnull(a.status,'VAZIO') as status, "
						cQuery +=  "        d.tiso_tamanho cnt_tipo "
						cQuery +=  "   from vw_inventario_container a "
						cQuery += 	"        inner join tab_reserva_doc_cnt b "
						cQuery +=  "                on  b.mcnt_id = a.mcnt_id "
						cQuery +=  "        left join tab_container c "
						cQuery +=	"               on c.cnt_id = a.cnt_id "
						cQuery += 	"        left join tab_tipo_iso d "
						cQuery += 	"               on d.tiso_id  = c.tiso_id"
						cQuery +=  "  where b.res_id = " + alltrim(omodelCNT:getvalue('CNT_RES_ID'))

					endif

					if alltrim(omodelCNT:getvalue('CNT_DP_DS')) <> ''
						cQuery +=	' and exists (select 1'
						cQuery +=  '                from tab_di_item c'
						cQuery +=  '                     inner join tab_lote_atual d'
						cQuery +=  '                             on d.latu_lote = c.latu_lote'
						cQuery +=  '                            and d.latu_item = c.latu_item'
						cQuery +=  '                            and d.cnt_id = a.cnt_id'
						cQuery +=  '                            and d.latu_qt_saldo > 0'
						cQuery +=  "                            and c.dsai_id = '"  +alltrim(omodelCNT:getvalue('CNT_DP_DS')) +  "')"
					endif

					cQuery +=  "  and a.cnt_id = '" +alltrim(oModelCNT:GetValue('CNT_CNT_ID'))+ "'"

					contador := oModelCNT:getline()

					For nI := 1 To oModelCNT:Length()

						If contador != nI .And. (AllTrim(oModelCNT:GetValue('CNT_CNT_ID',nI)) <> '') .and. (.Not. oModelCNT:IsDeleted(nI));
						.and.  AllTrim(oModelCNT:GetValue('CNT_TISO_I',nI)) <> ''  .and.  AllTrim(oModelCNT:GetValue('CNT_QTD_CN',nI)) <> ''       
							If nQuantCNT > 0
								cQueryAux +=","
							EndIf

							nQuantCNT++

							cQueryAux += "'" + AllTrim(oModelCNT:GetValue('CNT_CNT_ID',nI)) + "'"

						EndIf

					Next nI

					cQueryAux += ")"

					if nQuantCNT > 0
						cQuery := cQuery + cQueryAux
					endif

					DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),calias,.F.,.T.)

					if alltrim((calias)->cnt_id) <> ''
						oModelCNT:loadvalue('CNT_TISO_I',alltrim((calias)->tiso_id))
						oModelCNT:loadvalue('CNT_TIS_TA',alltrim((calias)->cnt_tipo))
						oModelCNT:loadvalue('CNT_QTD_CN','1')
						oModelCNT:loadvalue('CNT_CNTCHE',If(	alltrim((calias)->status) == 'VAZIO', 'N','S'))
					else
						oModel:SetErrorMessage('PRAA802CNT','CNT_CNT_ID','','','3074', "Operação negada.","Para a operação selecionada, não foi localizado o container no estoque do recinto.",nil)
						return .F.
					endif

				else

					cQuery := "	select isnull(a.cnt_id,'') as cnt_id, "
					cQuery += "          isnull(a.tiso_id,'') as tiso_id, "
					cQuery += "	       b.tiso_tamanho cnt_tipo "
					cQuery += "     from tab_container a"
					cQuery += "          left join tab_tipo_iso b "
					cQuery += "                 on b.tiso_id  = a.tiso_id"
					cQuery += "    where cnt_id = '" + containerAtu + "'"

					DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),calias,.F.,.T.)

					if alltrim((calias)->cnt_id) <> ''
						oModelCNT:loadvalue('CNT_TISO_I',alltrim((calias)->tiso_id))
						oModelCNT:loadvalue('CNT_TIS_TA',alltrim((calias)->cnt_tipo))
					endif

					oModelCNT:loadvalue('CNT_QTD_CN','1')

				endif

			endif
		else
			oModelCNT:loadvalue('CNT_TISO_I','')
			oModelCNT:loadvalue('CNT_TIS_TA','')
			oModelCNT:loadvalue('CNT_QTD_CN','')
		endif

	END SEQUENCE

	ErrorBlock(bError)
  
return .T.



/*/{Protheus.doc} PRAC938
@author   Fernando da Cruz Pinheiro
@version  P12
@since    02/01/2014
@obs     Setmodel do modelo.
/*/
static function A802LOAD(oModel)
	Local cAlias2 := GetNextAlias()
  	Local cAlias3 := GetNextAlias()
  	local cQuery := ''
  	Local nOp       := oModel:getOperation()
  	Local cModal := ''

	if nop = 3
		If Empty(cTipoModal)
	  		if MV_PAR01 = 1
	  	    	cModal := 'V'
			elseif MV_PAR01 = 2
	  	    	cModal := 'F'
			elseif MV_PAR01 = 3
	  	    	cModal := 'A'
			endif
		Else
			cModal := cTipoModal
		EndIf
		
		If cModal == 'F' .And. !Empty(GetCodViagem())
    		oModel:GetModel("PRAA802"):SetValue("TMP_VIAGEM", GetCodViagem())
    	EndIf
		
		cQuery := " select min(eve_id) as eve_id from tab_agen_eventos where eve_modal = 'V' and eve_seq = (select min(eve_seq) from tab_agen_eventos) "
	  	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias2,.F.,.T.)
	  	dbselectarea(cAlias2)

	  	if (cAlias2)->eve_id <> 0
	  		cQuery := " select eve_id, eve_desc from tab_agen_eventos where eve_modal = '" + cModal + "'" + ' and eve_id = ' + str((cAlias2)->eve_id)

			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias3,.F.,.T.)
	  	   	dbselectarea(cAlias3)

			if (cAlias3)->eve_id <> 0
	  	   		oModel:GetModel('PRAA802'):setvalue('TMP_EVE_ID',alltrim(str((cAlias3)->eve_id)))
			endif
		else
			oModel:GetModel('PRAA802'):setvalue('TMP_EVE_ID','')
		endif

		if cModal != 'F'
			oModel:GetModel('PRAA802'):loadvalue('TMP_DT_INE',dtoc(date()))
		endif
	endif
return .T.

/*/{Protheus.doc} A802CANP
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Realiza o cancelamento da programação.
/*/
function A802CANP()
	Local cAlias := GetNextAlias()
	Local cAlias2 := GetNextAlias()
	Local cQuery := ''
	Local nRet := 0

	if alltrim(cEmpPai) = SGetTerm()
		cQuery := " SELECT cesv_id FROM TAB_programacao WHERE prog_id = " + stranstype((cAliasTMP)->TMP_PRG_ID,'C')

       dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
       IF AllTrim((cAlias)->cesv_id) = ''
       	cQuery := " SELECT CONVERT(VARCHAR, dt_cancelamento ,103) as data_dt_cancelamento FROM TAB_programacao WHERE prog_id = " + stranstype((cAliasTMP)->TMP_PRG_ID,'C')
         	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias2, .F., .T.)

         	if alltrim((cAlias2)->data_dt_cancelamento) <> ''
         		if MSGYESNO('Deseja estornar o cancelamento da programação?')
         			cQuery := " SELECT count(*) qtd, vf_id FROM TAB_programacao WHERE not dt_cancelamento is null and vf_id = '" + (cAliasTMP)->TMP_VIAGEM + "' group by vf_id"
         	 		(cAlias)->(dbCloseArea())
					dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
					
					If (cAlias)->qtd > 1 .And. MsgYesNo("Deseja estornar o cancelamento de todas as programações referente a viagem " + (cAliasTMP)->TMP_VIAGEM + "?")
						(cAlias)->(dbCloseArea())
						A802CANESTP()
						Return
					Else
						(cAlias)->(dbCloseArea())
					EndIf
					
            		nRet := TCSQLExec(" update tab_programacao set dt_cancelamento = null where prog_id = " + stranstype((cAliasTMP)->TMP_PRG_ID,'C') )
					tcsqlexec('delete tab_programacao_eventos where eve_prog_id = (select max(eve_prog_id) from tab_programacao_eventos where prog_id = ' + stranstype((cAliasTMP)->TMP_PRG_ID,'C')  + ' and eve_id = 8 )')
				endif
			else
         		if MSGYESNO(STR0261)
         	 		cQuery := " SELECT count(*) qtd,vf_id FROM TAB_programacao WHERE dt_cancelamento is null and vf_id = '" + (cAliasTMP)->TMP_VIAGEM + "' group by vf_id"
         	 		(cAlias)->(dbCloseArea())
					dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
					If (cAlias)->qtd > 1 .And. MsgYesNo("Deseja cancelar todas as programações referente a viagem " + (cAliasTMP)->TMP_VIAGEM + "?")
						(cAlias)->(dbCloseArea())
						A802CANPBAT()
						Return
					EndIf
					nRet := TCSQLExec(" update tab_programacao set dt_cancelamento = '" + SDBDate(Date(),time())+ "' where prog_id = " + stranstype((cAliasTMP)->TMP_PRG_ID,'C') )
				endif
			endif
		Else
       	alert(STR0235)
		endif
	else
		alert(STR0140)
	endif
return


/*/{Protheus.doc} A802AGETEL
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Função chamda no consulta padrao para pesquisar um agendamento.
/*/
function A802AGETEL()

Return .T.

/*/{Protheus.doc} A802AGRET
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Função retornada pelo consulta padrão. Realiza a chamada da tela para consultar a agenda.
/*/
Function A802AGRET()
	Local cRet := ''
	Local nOp
	Local cAlias := GetNextAlias()
	Local cDataViagem := ''
	Local cHoraViagem := ''
	Local cQuery := ''
	Local cAgenda := ''
	Local oView    := FWViewActive()
	Private paadmin_bloqueado := ''
	Private lCancel := .F.
	Private oModel    := FWModelActive()
	Private dData :=  ctod(alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DT_INE')))
	Private dData2 := ctod(alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DT_FIE')))
	Private paj_id := ''
	Private pa_id := ''
	Private cResul_Agen := ''
	Private dt_agen_ini := ''
	Private hr_agen_ini := ''
	Private dt_agen_fim := ''
	Private hr_agen_fim := ''
	Private pa_bloqueado := ''
	Private ldDataVazio := .F.
	Private ldData2Vazio := .F.
	Private cOperacao := ''
	Private cSubOperacao := ''
	Private nQuantidade := 0
	Private cModal_id := cModal
	Private cdc_id := ''

	if cTipoModal != 'F'

		nOp := oModel:getoperation()

		if nOp <> 3
			cQuery := " select convert(varchar(50),dt_liberacao) as  dt_liberacao from tab_programacao where prog_id = " + alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_PRG_ID'))
			dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
			if alltrim((cAlias)->dt_liberacao) <> ''
				if alltrim(cEmpPai) <> SGetTerm()
					alert(STR0276)
					cRet :=  alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DT_FIE'))
					cG_Data :=  alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DT_INE'))
					cG_data2 :=  alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DT_FIE'))
					triggerErro := .T.
					return cRet
				endif
			endif
		endif


		if (alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DC_ID')) <> '' ) .and. (alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DC_ID')) <> '0' )
			if (alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_SUB_ID')) = '') .or. (oModel:getmodel('PRAA802'):getvalue('TMP_QUANT') = 0 )
				alert(STR0277)
				chamouConsulta = .T.
				cG_Data :=  alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DT_INE'))
				triggerErro := .T.
				return oModel:getmodel('PRAA802'):getvalue('TMP_DT_FIE')
			endif
		else
			if (alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_SUB_ID')) = '')
				alert(STR0278)
				chamouConsulta = .T.
				cG_Data :=  alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DT_INE'))
				triggerErro := .T.
				return oModel:getmodel('PRAA802'):getvalue('TMP_DT_FIE')
			endif
		endif

		cOperacao     := alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_OPE_ID'))
		//If !Empty(cOperacao)
		//	cOperacao := cValToChar(Val(cOperacao))
		//EndIf
		cSubOperacao := alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_SUB_ID'))
		nQuantidade := oModel:getmodel('PRAA802'):getvalue('TMP_QUANT')

		if alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DC_D')) <> ''
			cdc_id := alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DC_ID'))
		endif

		PRAC808()

		chamouConsulta := .T.

		if ((lCancel = .F.) .and. ((nOp <> 1) .or. (nOp <> 5)) )
			cG_pa_bloqueado = pa_bloqueado
			cG_Data := dData
			cG_Data2 := dData2
			cG_Resul_Agen := cResul_Agen
			cG_paj_id := paj_id
			cG_pa_id := pa_id
			cG_dt_a_ini := dt_agen_ini
			cG_hr_a_ini := hr_agen_ini
			cG_dt_a_fim := dt_agen_fim
			cG_hr_a_fim := hr_agen_fim
		endif

		if (lCancel = .T.)
			triggerErro := .T.
		endif

		if (lCancel = .T.)
			if (ldDataVazio = .T.)
				cG_Data := '/  /'
			else
				cG_Data := alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DT_INE'))
			endif

			if (ldData2Vazio = .T.)
				cRet := '/  /'
				cG_Data2 := '/  /'
			else
				cRet :=  alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DT_FIE'))
				cG_Data2 := alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DT_FIE'))
			endif
		else
			cG_Data := alltrim(dtoc(dData))

			cRet := alltrim(dtoc(dData2))
			cG_Data2 := alltrim(dtoc(dData2))
		endif

	else

		cViagem := alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_VIAGEM'))
		if SEmpty(cViagem)
			alert('Viagem não informada')
			return oModel:getmodel('PRAA802'):getvalue('TMP_DT_FIE')
		endif

		if (alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DC_ID')) <> '' ) .and. (alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DC_ID')) <> '0' )
			if (alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_SUB_ID')) = '') .or. (oModel:getmodel('PRAA802'):getvalue('TMP_QUANT') = 0 )
				alert(STR0277)
				return oModel:getmodel('PRAA802'):getvalue('TMP_DT_FIE')
			endif
		else
			if (alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_SUB_ID')) = '')
				alert(STR0278)
				return oModel:getmodel('PRAA802'):getvalue('TMP_DT_FIE')
			endif
		endif

		cDataViagem := A802ATUD(cViagem)
		cHoraViagem := A802ATUH(cViagem)

		cOperacao     := alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_OPE_ID'))
		//If !Empty(cOperacao)
		//	cOperacao := cValToChar(Val(cOperacao))
		//EndIf
		cSubOperacao := alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_SUB_ID'))
		nQuantidade := oModel:getmodel('PRAA802'):getvalue('TMP_QUANT')

		if alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DC_D')) <> ''
			cdc_id := alltrim(oModel:getmodel('PRAA802'):getvalue('TMP_DC_ID'))
		endif

		if cdc_id <> ''
			cQuery := "  select b.dc_id, CONVERT(VARCHAR,  c.paj_datahora_ini,103) + ' ' + CONVERT(VARCHAR,  c.paj_datahora_ini,108) as data_inicio, "
			cQuery += "	CONVERT(VARCHAR,c.paj_datahora_fim,103)  + ' ' + CONVERT(VARCHAR,c.paj_datahora_fim,108)  as data_fim,  "
			cQuery += "	c.paj_id, c.pa_id, "
			cQuery += "	CONVERT(VARCHAR,  c.paj_datahora_ini,103) + ' ' + CONVERT(VARCHAR,  c.paj_datahora_ini,108) + ' - ' + CONVERT(VARCHAR,c.paj_datahora_fim,103)  + ' ' + CONVERT(VARCHAR,c.paj_datahora_fim,108)  as result_data, "
			cQuery += "   CONVERT(VARCHAR,  c.paj_datahora_ini,103) as data_dt_inicio, "
			cQuery += "   CONVERT(VARCHAR,  c.paj_datahora_ini,108) as horas_inicio, "
			cQuery += "  CONVERT(VARCHAR,  c.paj_datahora_fim,103) as data_dt_fim, "
			cQuery += "   CONVERT(VARCHAR,  c.paj_datahora_fim,108) as horas_fim, "
			cQuery += "   d.pa_bloqueado "
			cQuery += "			from tab_portal_agenda_janela c "
			cQuery += "            inner join tab_portal_agenda d "
			cQuery += "                 on d.pa_id = c.pa_id "
			cQuery += "            left join tab_portal_janela_capacidade b "
			cQuery += "                 on b.paj_id = c.paj_id "
			cQuery += "            left join tab_portal_operacoes a "
			cQuery += "                 on a.pjc_id = b.pjc_id "
			cQuery += "              where 1 = 1  "
			cQuery += "                and (( a.modal_id = '" + cTipoModal + "' and a.op_id = " + cOperacao + " and a.sub_id =  " + cSubOperacao +  "  and b.dc_id = " + cdc_id + " ) or b.pjc_id is null ) "
		else
			cQuery := "  select 0 as dc_id, CONVERT(VARCHAR,  a.paj_datahora_ini,103) + ' ' + CONVERT(VARCHAR,  a.paj_datahora_ini,108) as data_inicio, "
			cQuery += "	CONVERT(VARCHAR,a.paj_datahora_fim,103)  + ' ' + CONVERT(VARCHAR,a.paj_datahora_fim,108)  as data_fim,  "
			cQuery += "	a.paj_id, a.pa_id, "
			cQuery += "	CONVERT(VARCHAR,  a.paj_datahora_ini,103) + ' ' + CONVERT(VARCHAR,  a.paj_datahora_ini,108) + ' - ' + CONVERT(VARCHAR,a.paj_datahora_fim,103)  + ' ' + CONVERT(VARCHAR,a.paj_datahora_fim,108)  as result_data, "
			cQuery += "   CONVERT(VARCHAR,  a.paj_datahora_ini,103) as data_dt_inicio, "
			cQuery += "   CONVERT(VARCHAR,  a.paj_datahora_ini,108) as horas_inicio, "
			cQuery += "  CONVERT(VARCHAR,  a.paj_datahora_fim,103) as data_dt_fim, "
			cQuery += "   CONVERT(VARCHAR,  a.paj_datahora_fim,108) as horas_fim, "
			cQuery += "   d.pa_bloqueado "
			cQuery +=  "		from tab_portal_agenda_janela a               "
			cQuery +=  "        left join tab_portal_janela_capacidade b "
			cQuery +=  "          on b.paj_id = a.paj_id "
			cQuery +=  "        left join tab_portal_agenda d "
			cQuery +=  "           on d.pa_id = a.pa_id where 1=1 and b.pjc_id  is null "
		endif

		cQuery += "   and ('" + SDBDate(Date(),time()) + "' >= d.pa_dt_liberacao_ini "
		cQuery += "   and  '" + SDBDate(Date(),time()) + "' <= d.pa_dt_liberacao_fim ) "

		cQuery += " and '" +  SDBDate(cDataViagem,cHoraViagem+':00.000') + "' >= paj_datahora_ini "
		cQuery += " and '"+SDBDate(cDataViagem,cHoraViagem+':00.000')+"' <= paj_datahora_fim order by paj_datahora_ini asc "

		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

		While !(cAlias)->(Eof())

			if ((cAlias)->dc_id <> 0)
				if val_operando(cOperacao, cSubOperacao, alltrim(str((cAlias)->paj_id)), nQuantidade, 'F') == .T.
					cAgenda := AllTrim(Str((cAlias)->paj_id))
					Exit
				endif
			else
				cAgenda := AllTrim(Str((cAlias)->paj_id))
				Exit
			endif

	      (cAlias)->(DbSkip())
	   EndDo

		if (!empty(cAgenda))

			oModel:getmodel('PRAA802'):loadvalue('TMP_PA_BLQ',alltrim((cAlias)->pa_bloqueado))
			oModel:getmodel('PRAA802'):loadvalue('TMP_DT_AGE',alltrim((cAlias)->result_data))
			oModel:getmodel('PRAA802'):loadvalue('TMP_PAJ_ID',(cAlias)->paj_id)
			oModel:getmodel('PRAA802'):loadvalue('TMP_PA_ID' ,(cAlias)->pa_id)
			oModel:getmodel('PRAA802'):loadvalue('TMP_AGDT_I',alltrim((cAlias)->data_dt_inicio))
			oModel:getmodel('PRAA802'):loadvalue('TMP_AGHR_I',alltrim((cAlias)->horas_inicio))
			oModel:getmodel('PRAA802'):loadvalue('TMP_AGDT_F',alltrim((cAlias)->data_dt_fim))
			oModel:getmodel('PRAA802'):loadvalue('TMP_AGHR_F',alltrim((cAlias)->horas_fim))
			oModel:getmodel('PRAA802'):loadvalue('TMP_DT_PRE',ctod((cAlias)->data_dt_inicio))
			oModel:getmodel('PRAA802'):loadvalue('TMP_HR_PRE',cHoraViagem)

			oModel:getmodel('PRAA802'):loadvalue('TMP_DT_INE',alltrim((cAlias)->data_dt_inicio))
			oModel:getmodel('PRAA802'):loadvalue('TMP_DT_FIE',alltrim((cAlias)->data_dt_inicio))

			cRet := (cAlias)->data_dt_inicio

			 If !Empty(oView) .And. oView:lActivate
				oView:refresh()
			EndIf
		else
			Alert('Sem janela disponivel.')

			oModel:getmodel('PRAA802'):loadvalue('TMP_PA_BLQ','0')
			oModel:getmodel('PRAA802'):loadvalue('TMP_DT_AGE','')
			oModel:getmodel('PRAA802'):loadvalue('TMP_PAJ_ID',0)
			oModel:getmodel('PRAA802'):loadvalue('TMP_PA_ID' ,0)
			oModel:getmodel('PRAA802'):loadvalue('TMP_AGDT_I','  /  /    ')
			oModel:getmodel('PRAA802'):loadvalue('TMP_AGHR_I','  :  ')
			oModel:getmodel('PRAA802'):loadvalue('TMP_AGDT_F','  /  /    ')
			oModel:getmodel('PRAA802'):loadvalue('TMP_AGHR_F','  :  ')
			oModel:getmodel('PRAA802'):loadvalue('TMP_DT_PRE',ctod('  /  /    '))
			oModel:getmodel('PRAA802'):loadvalue('TMP_HR_PRE','  :  ')

			oModel:getmodel('PRAA802'):loadvalue('TMP_DT_INE','  /  /    ')
			oModel:getmodel('PRAA802'):loadvalue('TMP_DT_FIE','  /  /    ')

			 If !Empty(oView) .And. oView:lActivate
				oView:refresh()
			EndIf

			cRet := '  /  /    '
		endif

	   (cAlias)->(DbCloseArea())

	endif

Return cRet

Static function A802LC()
	Local oModel    := FWModelActive()
	Local oView    := FWViewActive()

    If !(ALTERA)
		oModel:getmodel('PRAA802'):loadvalue('TMP_PA_BLQ','0')
		oModel:getmodel('PRAA802'):loadvalue('TMP_DT_AGE','')
		oModel:getmodel('PRAA802'):loadvalue('TMP_PAJ_ID',0)
		oModel:getmodel('PRAA802'):loadvalue('TMP_PA_ID' ,0)
		oModel:getmodel('PRAA802'):loadvalue('TMP_AGDT_I','  /  /    ')
		oModel:getmodel('PRAA802'):loadvalue('TMP_AGHR_I','  :  ')
		oModel:getmodel('PRAA802'):loadvalue('TMP_AGDT_F','  /  /    ')
		oModel:getmodel('PRAA802'):loadvalue('TMP_AGHR_F','  :  ')
		oModel:getmodel('PRAA802'):loadvalue('TMP_DT_PRE',ctod('  /  /    '))
		oModel:getmodel('PRAA802'):loadvalue('TMP_HR_PRE','  :  ')
	
		oModel:getmodel('PRAA802'):loadvalue('TMP_DT_INE','  /  /    ')
		oModel:getmodel('PRAA802'):loadvalue('TMP_DT_FIE','  /  /    ')
	EndIf
	
	If !Empty(oView) .And. oView:lActivate
		oView:refresh()
	EndIf
return .T.

static function A802DEDAD(cModel)
	Local oModel    := FWModelActive()
	Local oModelGEN := oModel:GetModel(cModel)
	Local nI := 0

	if cModel = 'PRAA802DOC'
		for nI := 1 to oModelGEN:length()
			oModelGEN:goline(nI)
			If !oModelGEN:IsDeleted()
				oModelGEN:loadvalue('DOC_PRG_ID','')
				oModelGEN:loadvalue('DOC_DP_ID','')
				oModelGEN:loadvalue('DOC_DOC_ID','')
				oModelGEN:loadvalue('DOC_TPO_DC','')
				oModelGEN:loadvalue('DOC_ANO_DC','')
				oModelGEN:loadvalue('DOC_NUM_DC','')
				oModelGEN:loadvalue('DOC_SER_DC','')
				oModelGEN:loadvalue('DOC_PRC_DC','')
				oModelGEN:loadvalue('DOC_RES_ID','')
				oModelGEN:loadvalue('DOC_RES_NU','')
				oModelGEN:loadvalue('DOC_CFOP','')
				oModelGEN:loadvalue('DOC_CFOP_D','')
				oModelGEN:loadvalue('DOC_BEN_ID','')
				oModelGEN:loadvalue('DOC_BEN','')
				oModelGEN:loadvalue('DOC_TPO_ES','')
			EndIf
		next nI
	elseif cModel = 'PRAA802ITC'
		for nI := 1 to oModelGEN:length()
			oModelGEN:goline(nI)
			If !oModelGEN:IsDeleted()
				oModelGEN:loadvalue('ITC_PIC_ID','')
				oModelGEN:loadvalue('ITC_PRG_ID','')
				oModelGEN:loadvalue('ITC_DP_ID','')
				oModelGEN:loadvalue('ITC_DP_DS','')
				oModelGEN:loadvalue('ITC_RES_ID','')
				oModelGEN:loadvalue('ITC_RES_NU','')
				oModelGEN:loadvalue('ITC_LOT_ID','')
				oModelGEN:loadvalue('ITC_LOT_IT','')
				oModelGEN:loadvalue('ITC_LIT_DS','')
				oModelGEN:loadvalue('ITC_QTD_VO','')
				oModelGEN:loadvalue('ITC_M3',0)
			EndIf
		next nI
	elseif cModel = 'PRAA802ITD'
		for nI := 1 to oModelGEN:length()
			oModelGEN:goline(nI)
			If !oModelGEN:IsDeleted()
				oModelGEN:loadvalue('ITD_PRG_ID','')
				oModelGEN:loadvalue('ITD_PID_ID','')
				oModelGEN:loadvalue('ITD_DP_ID','')
				oModelGEN:loadvalue('ITD_DP_DS','')
				oModelGEN:loadvalue('ITD_ESP_ID','')
				oModelGEN:loadvalue('ITD_ESP_DS','')
				oModelGEN:loadvalue('ITD_QTD_VO','')
				oModelGEN:loadvalue('ITD_M3',0)
				oModelGEN:loadvalue('ITD_PESO',0)
				oModelGEN:loadvalue('ITD_FAM_ID','')
				oModelGEN:loadvalue('ITD_FAM_DS','')
				oModelGEN:loadvalue('ITD_DESC','')
			EndIf
		next nI
	endif

return .T.

/*/{Protheus.doc} VAL_OPERACAO
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Validacao realizada para o campo Sub-operacao
/*/
Static Function VAL_OPERACAO()
	Local oModel    := FWModelActive()
	Local oView    := FWViewActive()
	Local oModelTMP := oModel:GetModel('PRAA802')
	Local lResult := .T.
	Local tTabSubope := GetNextAlias()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local lOpcaoNao := .F.
	Local cOpId := AllTrim(oModelTMP:GetValue('TMP_OPE_ID'))

	Default cTipomodal := ""

    IF cOpId <> ''
         cQuery := " SELECT op_descricao FROM TAB_OPERACAO WHERE OP_ID = "+ cValToChar(Val(oModelTMP:GetValue('TMP_OPE_ID')))

         dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabSubope, .F., .T.)
         IF AllTrim((tTabSubope)->op_descricao) <> ''
		            if (cValToChar(Val(oModelTMP:GetValue('TMP_OPE_ID'))) = '1') .and. (alltrim((CALIASTMP)->TMP_OPE_ID) = '2')
		              	if (oModelDOC:length() > 0)
		              		oModelDOC:goline(1)
		              		if !oModelDOC:isdeleted() .and. /*(alltrim(oModelDOC:getvalue('DOC_DOC_ID')) <> '') .and.*/ (oModelDOC:getvalue( 'DOC_TPO_ES') = 'E')
		              		   if MSGYESNO('A operação foi alterada. As informações referente aos documentos e seus respectivos itens serão apagados.' + chr(13) + ;
		              		   				 'Deseja continuar?')

										A802DEDAD('PRAA802ITD')
										A802DEDAD('PRAA802DOC')

					              	oModelTMP:setvalue('TMP_OPE_DS',alltrim((tTabSubope)->op_descricao))
					              	oModelTMP:setvalue('TMP_SUB_DS','')
										oModelTMP:setvalue('TMP_SUB_ID','')
					              	lResult := .T.
					              else
										 lOpcaoNao := .T.
										oModel:SetErrorMessage('PRAA802','TMP_OPE_ID','','','3075','Valor inválido.','Escolha outra operação.',nil,nil)
					              	return .F.
		              		    endif
		              		else
		                 			oModelTMP:setvalue('TMP_OPE_DS',alltrim((tTabSubope)->op_descricao))
		              		endif
		                  else
		                 		oModelTMP:setvalue('TMP_OPE_DS',alltrim((tTabSubope)->op_descricao))
		              	endif
			        elseif (cValToChar(Val(oModelTMP:GetValue('TMP_OPE_ID'))) = '2' ) .and. (Type("CALIASTMP") != "C" .Or. Empty(CALIASTMP) .Or. alltrim((CALIASTMP)->TMP_OPE_ID) = '1')
			        		if (oModelDOC:length() > 0)
		              		oModelDOC:goline(1)
		              		if !oModelDOC:isdeleted() .and. /*(alltrim(oModelDOC:getvalue('DOC_DOC_ID')) <> '') .and.*/ (oModelDOC:getvalue( 'DOC_TPO_ES') = 'S')
		              		   if MSGYESNO('A operação foi alterada. As informações referente aos documentos e seus respectivos serão apagados.' + chr(13) + ;
		              		   				 'Deseja continuar?')
		              		   		A802DEDAD('PRAA802ITC')
										A802DEDAD('PRAA802DOC')

					              	oModelTMP:setvalue('TMP_OPE_DS',alltrim((tTabSubope)->op_descricao))
					              	oModelTMP:setvalue('TMP_SUB_DS','')
										oModelTMP:setvalue('TMP_SUB_ID','')

		  				 				lResult := .T.
					              else
										  lOpcaoNao := .T.
										  oModel:SetErrorMessage('PRAA802','TMP_OPE_ID','','','3076','Valor inválido.','Escolha outra operação.',nil,nil)
					              	return .F.
		              		    endif
		              		else
		                 			oModelTMP:setvalue('TMP_OPE_DS',alltrim((tTabSubope)->op_descricao))
		              		endif
		              	else
		                 		oModelTMP:setvalue('TMP_OPE_DS',alltrim((tTabSubope)->op_descricao))
		              	endif

			        else
			            oModelTMP:loadvalue('TMP_OPE_DS',alltrim((tTabSubope)->op_descricao))

			        endif
         Else
            lResult := .F.
         EndIf
         (tTabSubope)->(DbCloseArea())

	   ELSE
	      oModelTMP:setvalue('TMP_OPE_DS','')
	   EndIf

	if lresult = .T. .and. lOpcaoNao = .F.
		oModelTMP:setvalue('TMP_SUB_DS','')
		oModelTMP:setvalue('TMP_SUB_ID','')

		if cTipoModal == 'F'
			A802LC()
		endif
	endif
	If !Empty(oView) .And. oView:lActivate
//   		oView:GetViewObj('PRAA802')[3]:EvalWhen()
		oView:refresh()
   	EndIf
//   oView:GetViewObj('PRAA802DOC')[3]:EvalWhen()

Return lResult


/*/{Protheus.doc} VAL_SUB_ID
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Validacao realizada para o campo Sub-operacao
/*/
Static Function VAL_SUB_ID()
	Local oModel    := FWModelActive()
	Local oView    := FWViewActive()
	Local oModelTMP := oModel:GetModel('PRAA802')
	Local lResult := .T.
	Local tTabSubope := GetNextAlias()
	Local cQuery := ''
	Local cConsDriver := GetNextAlias()

    cSubOpCntCheio  := ''
    cSubOpCntVazio  := ''
    cSubOpMercSolta := ''

    IF AllTrim(oModelTMP:GetValue('TMP_SUB_ID')) <> ''
      IF AllTrim(oModelTMP:GetValue('TMP_OPE_ID')) <> ''
         cQuery := " SELECT SUB_DESCRICAO, "
         cQuery += "        convert(varchar,SUB_TIPOCARGA_CNT_CHEIO) as CNT_CHEIO,  "
         cQuery += "        convert(varchar,SUB_TIPOCARGA_CNT_VAZIO) as CNT_VAZIO, "
         cQuery += "        convert(varchar,SUB_TIPOCARGA_MERC_SOLTA) as MERC_SOLTA "
         cQuery += "   FROM TAB_SUB_OPERACAO "
         cQuery += "  WHERE SUB_ID = "+oModelTMP:GetValue('TMP_SUB_ID')
         cQuery += "    AND OP_ID = "+cValToChar(Val(oModelTMP:GetValue('TMP_OPE_ID')))
         cQuery += "    AND SUB_MODAL = '"+cTipomodal+"'"
         dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabSubope, .F., .T.)
         IF AllTrim((tTabSubope)->SUB_DESCRICAO) <> ''
            oModelTMP:setvalue('TMP_SUB_DS',(tTabSubope)->SUB_DESCRICAO)
            cSubOpCntCheio  := AllTrim((tTabSubope)->CNT_CHEIO)
            cSubOpCntVazio  := AllTrim((tTabSubope)->CNT_VAZIO)
            cSubOpMercSolta := AllTrim((tTabSubope)->MERC_SOLTA)
         Else
            oModelTMP:loadvalue('TMP_SUB_ID','')
           If !Empty(oView) .And. oView:lActivate
				oView:refresh()
			EndIf
            lResult := .F.
         EndIf
         (tTabSubope)->(DbCloseArea())
      ELSE
      	 oModelTMP:loadvalue('TMP_SUB_DS','')
         oModelTMP:loadvalue('TMP_SUB_ID','')
          If !Empty(oView) .And. oView:lActivate
				oView:refresh()
			EndIf
         lResult := .F.
      EndIF
   ELSE
      oModelTMP:setvalue('TMP_SUB_DS','')
      oModelTMP:setvalue('TMP_SUB_ID','')
   EndIF

   if (alltrim(oModelTMP:GetValue('TMP_OPE_ID')) <> '') .and. (alltrim(oModelTMP:GetValue('TMP_SUB_ID')) <> '')
	   		cQuery := ' select b.dc_id, b.dc_descricao from rel_driver_suboperacao a                     '
			cQuery +=			'	inner join tab_driver_capacidade b on a.dc_id = b.dc_id   '
			cQuery +=			'          where sub_id = ' + alltrim(oModelTMP:GetValue('TMP_SUB_ID'))
         dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cConsDriver, .F., .T.)

          IF AllTrim((cConsDriver)->dc_descricao) <> ''
             oModelTMP:loadvalue('TMP_DC_D' ,alltrim((cConsDriver)->dc_descricao))
             oModelTMP:loadvalue('TMP_DC_ID',alltrim(str((cConsDriver)->dc_id)))
          else
             oModelTMP:loadvalue('TMP_DC_D' ,'')
       		 oModelTMP:loadvalue('TMP_DC_ID','')
          endif
          (cConsDriver)->(DbCloseArea())
   else
   		oModelTMP:loadvalue('TMP_DC_D' ,'')
        oModelTMP:loadvalue('TMP_DC_ID','')
   endif
   
   If !lResult
	   oModelTMP:loadvalue('TMP_DT_AGE','')
	   oModelTMP:loadvalue('TMP_DT_PRE',ctod('  /  /    '))
	   oModelTMP:loadvalue('TMP_HR_PRE',':')
   EndIf

Return lResult


/*/{Protheus.doc} CAR_TABTMP
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Monta dados da tabela temporaria
/*/
Static Function CAR_TABTMP(lBrowse)
   Local cAliTABPRO
   Local aArrTABPRO
   Local cAliTABEVE := GetNextAlias()
   Local aArrTABEVE := {}
   Local cAliTABREB := GetNextAlias()
   Local aArrTABREB := {}
   Local cAliTABDOC := GetNextAlias()
   Local aArrTABDOC := {}
   Local cAliTABANE := GetNextAlias()
   Local aArrTABANE := {}
   Local cAliPRCNT := GetNextAlias()
   Local aArrTABPRCNT := {}
   Local cAliITCAR := GetNextAlias()
   Local aArrTABITCAR := {}
   Local cAliITDES := GetNextAlias()
   Local aArrTABITDES := {}
   Local cAnoDoc := ""
   Local cTpoDoc := ""
   Local cNumDoc := ""
   Local cSerDoc := ""
   Local cPrcDoc := ""
   Local cPrgId := (cAliasTMP)->TMP_PRG_ID
   Local cCNTTPOES := ''
   Default lBrowse := .F.

      cAliTABPRO := GetNextAlias()
      aArrTABPRO := {}


   //TABELA PRINCIPAL
   cQueryP :=     " SELECT  "
   cQueryP +=            " CAST(A.PROG_ID as VarChar(10)) as PROG_ID, "
   cQueryP +=			 " REPLICATE('0',6-LEN(CAST(a.PROG_ID as VarChar(10)))) ++ CAST(A.PROG_ID as VarChar(10)) as STR_PG, "
   cQueryP +=            " A.VEI_ID, "
   cQueryP +=            " CAST(A.EVE_ID as VarChar(10)) as EVE_ID, "
   cQueryP +=            " B.EVE_DESC, "
   cQueryP +=            " CONVERT(VARCHAR, A.PROG_DT_EVENTO, 103) AS DT_EVENTO, "
   cQueryP +=            " CONVERT(VARCHAR, A.PROG_DT_EVENTO, 108) AS HR_EVENTO, "
   cQueryP +=            " CONVERT(VARCHAR, A.DT_ENTRADA, 103) AS DT_ENTRADA, "
   cQueryP +=            " CONVERT(VARCHAR, A.DT_ENTRADA, 108) AS HR_ENTRADA, "
   cQueryP +=            " CONVERT(VARCHAR, C.PREV_SAIDA, 103) AS PREV_SAIDA, "
   cQueryP +=            " CONVERT(VARCHAR, C.PREV_SAIDA, 108) AS HR_PREV_SAIDA, "
   cQueryP +=            " A.REB_ID, "
   cQueryP +=            " A.VEI_ID_REL, "
   cQueryP +=            " A.cli_id_resp_agen, "
   cQueryP +=            " D.CLI_NOME, "
   cQueryP +=            " D.CLI_ID, "
   cQueryP +=            " A.DEST_CARGA, "
   cQueryP +=            " D.CLI_NOME as CLI_NOMEDES, "
   cQueryP +=            " CAST(A.REC_ID as VarChar(10)) AS REC_ID, "
   cQueryP +=            " CAST(A.PORT_ID as VarChar(10)) AS PORT_ID, "
   cQueryP +=            " CAST(A.TRANS_ID as VarChar(10)) AS TRANS_ID, "
   cQueryP +=            " F.CLI_NOME cli_nometr, "
   cQueryP +=            " F.CLI_CGC CGC_TR, " // CGC TRANSPORTADORA
   cQueryP +=            " A.NAT_CARGA, "
   cQueryP +=            " CAST(A.SUB_ID as VarChar(10)) AS SUB_ID, "
   cQueryP +=            " H.SUB_DESCRICAO, "
   cQueryP +=            " CAST(A.OP_ID as VarChar(10)) AS OP_ID, "
   cQueryP +=            " M.OP_DESCRICAO, "
   cQueryP +=            " CAST(A.REC_ID2 as VarChar(10)) AS REC_ID2, "
   cQueryP +=            " CAST(A.PES_ID as VarChar(10)) AS PES_ID, "
   cQueryP +=            " G.PES_NOME, "
   cQueryP +=            " G.PES_CPF, " //CPF MOTORISTA
   cQueryP +=            " CAST(A.CRA_ID as VarChar(10)) AS CRA_ID, "
   cQueryP +=            " A.CARGA_PREVISTA, d.cli_cgc, " //CGC CLIENTE
   cQueryP +=            " A.CARGA_REALIZADA, "
   cQueryP +=            " A.CESV_ID, "
   cQueryP +=            " A.STATUS as PRG_STATUS, "
   cQueryP +=            " A.ATIVO as PRG_ATIVO,   "
   cQueryP +=            " t.td_descricao as driver, "
   cQueryP +=            " u.modal_descricao as modal, "
   cQueryP +=            " a.prog_tipo_modal as cod_modal, "
   cQueryP +=            " o.qtd_janela,   "
   cQueryP +=            " r.pjc_id,   "
   cQueryP +=            " s.dc_descricao,   "
   cQueryP +=            " b.eve_desc,   "
   cQueryP +=            " CONVERT(VARCHAR, o.dt_ini_agenda, 103) AS DT_INI_AG,   "
   cQueryP +=            " CONVERT(VARCHAR, o.dt_fim_agenda, 103) AS DT_FIM_AG,    "
   cQueryP +=            " convert(varchar, q.paj_datahora_ini,103) + ' ' + convert(varchar, q.paj_datahora_ini,108) + ' - ' + convert(varchar, q.paj_datahora_fim,103) + ' ' + convert(varchar, q.paj_datahora_fim,108) as agenda, "
   cQueryP +=            " o.peso, "
   cQueryP += 			 " o.mtcubico, "
   cQueryP += 			 " CONVERT(VARCHAR, o.dt_hr_previsto, 103) as dt_previsto, "
   cQueryP +=            "  CONVERT(VARCHAR, o.dt_hr_previsto, 108) AS hr_previsto, "
   cQueryP += 			 " q.paj_id, o.dc_id, r.pjc_quantidade, "
   cQueryP += 			 " b.eve_edita_prog, "
   cQueryP += 			 " p.pa_bloqueado, "
   cQueryP +=            " o.pa_id, "
   cQueryP +=            " CONVERT(VARCHAR, z.cesv_dt_saida, 103) as cesv_dt_saida, "
   cQueryP +=            "  k.cli_nome as cli_resp,  "
   cQueryP +=            " CONVERT(VARCHAR,  q.paj_datahora_ini, 103) AS dt_age_ini, "
   cQueryP +=            " CONVERT(VARCHAR,  q.paj_datahora_ini, 108) AS hr_age_ini, "
   cQueryP +=            " CONVERT(VARCHAR,  q.paj_datahora_fim, 103) AS dt_age_fim, "
   cQueryP +=            " CONVERT(VARCHAR,  q.paj_datahora_fim, 108) AS hr_age_fim, "
   cQueryP +=            " a.observacao, "
   cQueryP +=            " CONVERT(VARCHAR,  a.dt_cancelamento, 103) as dt_cancela, "
   cQueryP  +=            " (select count(prog_id) from rel_dent_programacao where prog_id = a.prog_id) as total_doc, "
   cQueryP  +=            " (select count(prog_id) from tab_programacao_cnt where prog_id = a.prog_id) as total_cnt, "
   cQueryP += 			 " a.vf_id,"
   cQueryP += 			 " cast(vg.cli_operador as varchar(10)) cli_operador,"
   cQueryP += 			 " vgcli.cli_nome nome_operador, "
   cQueryP += 			 " VGOP.OP_DESCRICAO viagem_operacao "
   cQueryP +=       " FROM TAB_PROGRAMACAO A"
   cQueryP +=       " LEFT JOIN TAB_AGEN_EVENTOS B ON B.EVE_ID = A.EVE_ID "
   cQueryP +=       " LEFT JOIN TAB_PROG_COMPLEMENTO C ON C.PROG_ID = A.PROG_ID "
   cQueryP +=       " LEFT JOIN TAB_CLIENTES D ON D.CLI_ID = A.CLI_ID "
   cQueryP +=       " LEFT JOIN TAB_CLIENTES K ON K.CLI_ID = A.CLI_ID_RESP_AGEN "
   cQueryP +=       " LEFT JOIN rel_trans_ben_com tr ON tr.trans_id = A.TRANS_ID "
   cQueryP +=       " LEFT JOIN TAB_CLIENTES F ON F.CLI_ID = tr.ben_id "
   cQueryP +=       " LEFT JOIN TAB_PESSOAS G ON G.PES_ID = A.PES_ID "
   cQueryP +=       " LEFT JOIN TAB_SUB_OPERACAO H ON H.SUB_ID = A.SUB_ID "
   cQueryP +=       " LEFT JOIN TAB_OPERACAO M ON M.OP_ID = A.OP_ID "
   cQueryP +=       " LEFT JOIN tab_prog_janela O ON O.prog_id = A.PROG_ID "
   cQueryP +=       " LEFT JOIN tab_portal_agenda P ON P.pa_id = O.pa_ID "
   cQueryP +=       " left join tab_portal_janela_capacidade R on r.paj_id = o.paj_id and r.dc_id = o.dc_id "
   cQueryP +=       " left join tab_driver_capacidade S on S.dc_id = o.dc_id "
   cQueryP +=       " left join  tab_tipo_driver T on t.td_id = S.dc_tipo "
   cQueryP +=       " left join  tab_modal U on u.modal_id = a.prog_tipo_modal "
   cQueryP +=       " left join tab_cesv z on z.cesv_id = a.cesv_id "
   cQueryP +=       " inner join tab_portal_agenda_janela q on q.pa_id = o.pa_id and q.paj_id = o.paj_id "
   cQueryP +=			" left join tab_viagem_ferroviaria vg on a.vf_id = vg.vf_id "
   cQueryP +=			" left JOIN rel_trans_ben_com vgclir On vgclir.trans_id = vg.cli_operador"
   cQueryP +=			" left JOIN tab_clientes vgcli ON vgcli.cli_id = vgclir.ben_id"
   cQueryP +=       " LEFT JOIN TAB_OPERACAO VGOP ON VGOP.OP_ID = VG.OP_ID "
   cQueryP +=			" WHERE A.PROG_TIPO_MODAL = '"+cTipomodal+"'"
   
   If !lBrowse .And. !Empty(cPrgId)
   		cQueryP +=			" AND A.PROG_ID = " + cPrgId
   EndIf


   if (cEmpPai != SGetTerm())
      cQueryP += " and a.cli_id_resp_agen = '" + cEmpPai + "'"
   endif

   if (alltrim(dtoc(mv_par02)) <> '/  /') .and. (alltrim(dtoc(mv_par03)) <> '/  /')
   			 cQueryP += " and a.dt_cadastro between '" + alltrim(SDBDate(mv_par02,'00:00:00.000')) + "' and '" + alltrim(SDBDate(mv_par03,'23:59:59.000')) + "'"
   	elseif  alltrim(dtoc(mv_par02)) <> '/  /'
   		    cQueryP += " and a.dt_cadastro >= '" + alltrim(SDBDate(mv_par02,'00:00:00.000')) + "'"
   else
   		if  alltrim(dtoc(mv_par03)) <> '/  /'
   		    cQueryP += " and a.dt_cadastro <= '" + alltrim(SDBDate(mv_par03,'23:59:59.000')) + "'"
   		endif
   endif

   // 2 - NAO -> programacao nao pendentes
   if mv_par04 = 1
   	 	 //cQueryP += " and z.cesv_dt_saida is not null"//Não traz programação após Cancelamento da CESV

		cQueryP +=  " and z.cesv_dt_saida is null and a.dt_cancelamento is null "
   endif



   If !Empty(cVigPar)
   		cQueryP +=  " and a.vf_id = '" + cVigPar + "'"
   	EndIf


   cQueryP += " order by a.prog_id "

   cQueryP := ChangeQuery(cQueryP)

   DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQueryP),cAliTABPRO,.F.,.T.)

   DbSelectArea(cAliTABPRO)

   While !(cAliTABPRO)->(Eof())
      Aadd(aArrTABPRO,{;
     	               (cAliTABPRO)->PROG_ID, ;
     	               (cAliTABPRO)->STR_PG, ;
     	               (cAliTABPRO)->VEI_ID, ;
     	               (cAliTABPRO)->EVE_ID, ;
     	               (cAliTABPRO)->EVE_DESC, ;
     	               stranstype((cAliTABPRO)->DT_EVENTO,'D'), ;
     	               (cAliTABPRO)->HR_EVENTO, ;
     	               stranstype((cAliTABPRO)->DT_ENTRADA,'D'), ;
     	               (cAliTABPRO)->HR_ENTRADA, ;
     	               stranstype((cAliTABPRO)->PREV_SAIDA,'D'), ;
     	               (cAliTABPRO)->HR_PREV_SAIDA, ;
     	               (cAliTABPRO)->REB_ID, ;
     	               (cAliTABPRO)->VEI_ID_REL, ;
     	               (cAliTABPRO)->CLI_ID, ;
     	               (cAliTABPRO)->CLI_CGC, ;
     	               (cAliTABPRO)->CLI_NOME, ;
     	               (cAliTABPRO)->DEST_CARGA, ;
     	               (cAliTABPRO)->CLI_NOMEDES, ;
     	               (cAliTABPRO)->REC_ID, ;
     	               (cAliTABPRO)->PORT_ID, ;
     	               (cAliTABPRO)->TRANS_ID, ;
     	               (cAliTABPRO)->CGC_TR,;
     	               (cAliTABPRO)->cli_nometr, ;
     	               (cAliTABPRO)->NAT_CARGA, ;
     	               (cAliTABPRO)->OP_ID, ;
     	               (cAliTABPRO)->OP_DESCRICAO, ;
     	               (cAliTABPRO)->SUB_ID, ;
     	               (cAliTABPRO)->SUB_DESCRICAO, ;
     	               (cAliTABPRO)->REC_ID2, ;
     	               (cAliTABPRO)->PES_ID, ;
     	               (cAliTABPRO)->PES_CPF, ;
     	               (cAliTABPRO)->PES_NOME, ;
     	               (cAliTABPRO)->CRA_ID, ;
     	               (cAliTABPRO)->CARGA_PREVISTA, ;
     	               (cAliTABPRO)->CARGA_REALIZADA, ;
     	               (cAliTABPRO)->CESV_ID, ;
     	               (cAliTABPRO)->PRG_STATUS, ;
     	               (cAliTABPRO)->PRG_ATIVO,;
     	               (cAliTABPRO)->MODAL,;
     	               stranstype((cAliTABPRO)->DC_ID,'C'),;
     	               stranstype((cAliTABPRO)->qtd_janela,'N'),;
     	               stranstype((cAliTABPRO)->PJC_ID,'N'),;
     	               (cAliTABPRO)->dc_descricao,;
     	               (cAliTABPRO)->eve_desc,;
     	               (cAliTABPRO)->dt_ini_ag,;
     	               (cAliTABPRO)->dt_fim_ag,;
     	               (cAliTABPRO)->agenda,;
     	               (cAliTABPRO)->peso,;
     	               (cAliTABPRO)->mtcubico,;
     	               stranstype(alltrim((cAliTABPRO)->dt_previsto),'D'),;
     	               alltrim((cAliTABPRO)->hr_previsto),;
     	               val((cAliTabpro)->eve_edita_prog),;
     	               (cAliTABPRO)->cod_modal,;
     	               alltrim(str(val((cAliTABPRO)->pa_bloqueado))),;
     	               (cAliTABPRO)->pa_id,;
     	               (cAliTABPRO)->paj_id,;
     	               (cAliTABPRO)->dt_age_ini,;
     	               (cAliTABPRO)->hr_age_ini,;
     	               (cAliTABPRO)->dt_age_fim,;
     	               (cAliTABPRO)->hr_age_fim,;
     	               (cAliTABPRO)->dt_cancela,;
     	               (cAliTABPRO)->cli_cgc,;
     	               (cAliTABPRO)->cli_id_resp_agen,;
     	               (cAliTABPRO)->observacao,;
     	               (cAliTABPRO)->cli_resp,;
     	               alltrim(stranstype((cAliTABPRO)->total_doc,'C')),;
     	               alltrim(stranstype((cAliTABPRO)->total_cnt,'C')),;
     	               (cAliTABPRO)->vf_id,;
     	               (cAliTABPRO)->cli_operador,;
     	               (cAliTABPRO)->nome_operador,;
     	               (cAliTABPRO)->viagem_operacao;
     	               })
      (cAliTABPRO)->(DbSkip())
   EndDo
   (cAliTABPRO)->(DbCloseArea())
   cAliasTMP := MntCargDad(cAliasTMP,aArrTABPRO,aCamposTMP)
   If lBrowse
	   aSize(aArrTABEVE  ,0)
	   aSize(aArrTABREB  ,0)
	   aSize(aArrTABDOC  ,0)
	   aSize(aArrTABANE  ,0)
	   aSize(aArrTABPRCNT,0) 
	   aSize(aArrTABITCAR,0) 
	   aSize(aArrTABITDES,0)
	   Return
	EndIf

   //Alimenta a tabela cnt
   cQuery := 			 " select    a.prog_cnt_id, "
   cQuery += 			 			" a.prog_id, "
   cQuery += 			 			" a.cnt_id, "
   cQuery += 						" a.tiso_tamanho, "
   cQuery += 			 			" a.tiso_id, "
   cQuery += 			 			" a.qtd_cnt, "
   cQuery += 			 			" a.cnt_operacao, "
   cQuery +=           			" a.res_id, b.res_numero, a.dp_id, c.dent_id, a.cnt_cheio,  "
   cQuery +=           			" a.isdepot, a.cli_id_armador, "
   cQuery +=           			" (select arma_nome from tab_armador where cli_id = a.cli_id_armador) as nome_armador, a.id_prog_depot "
   cQuery +=  			 			" from tab_programacao_cnt a left join tab_reserva b on b.res_id = a.res_id "
   cQuery +=                   ' left join rel_dent_programacao c '
   cQuery +=                   '   on a.dp_id = c.dp_id '
   
   If !lBrowse .And. !Empty(cPrgId)
   		cQuery +=			" WHERE a.PROG_ID = " + cPrgId
   EndIf
   
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliPRCNT,.F.,.T.)

   DbSelectArea(cAliPRCNT)
   While !(cAliPRCNT)->(Eof())
      
      If ((cAliPRCNT)->cnt_operacao == "E")
          cCNTTPOES := "ENTRADA"
      ElseIf ((cAliPRCNT)->cnt_operacao == "S")
          cCNTTPOES := "SAIDA"
      EndIf
      
      Aadd(aArrTABPRCNT,{;
     	               alltrim(stranstype((cAliPRCNT)->prog_id,'C')),;
     	               alltrim(stranstype((cAliPRCNT)->prog_cnt_id,'C')),;
     	               (cAliPRCNT)->cnt_id,;
     	               cCNTTPOES,; //TIPO_OPERACAO
     	               (cAliPRCNT)->tiso_tamanho,;
     	               (cAliPRCNT)->tiso_id,;
     	               alltrim(stranstype((cAliPRCNT)->qtd_cnt,'C')),;
     	               alltrim((cAliPRCNT)->res_numero),;
     	               IIF(alltrim(stranstype((cAliPRCNT)->res_id,'C'))="0",'',alltrim(stranstype((cAliPRCNT)->res_id,'C'))),;
     	               alltrim(stranstype((cAliPRCNT)->dp_id,'C')),;
     	               alltrim((cAliPRCNT)->dent_id),;
     	               (cAliPRCNT)->cnt_cheio,;
     	               alltrim((cAliPRCNT)->isdepot),;
     	               alltrim((cAliPRCNT)->cli_id_armador),;
     	               alltrim((cAliPRCNT)->nome_armador),;
     	               alltrim(cValToChar((cAliPRCNT)->id_prog_depot));
     	               })
      (cAliPRCNT)->(DbSkip())
   EndDo
   (cAliPRCNT)->(DbCloseArea())
   cAliTMPP := MntCargDad(cAliTMPP,aArrTABPRCNT,aCamTMPPCNT)

   //HISTÓRICO DE EVENTOS
   cQuery :=     " SELECT  "
   cQuery +=            " CAST(A.PROG_ID as VarChar(10)) as PROG_ID, "
   cQuery +=            " CAST(A.EVE_PROG_ID as VarChar(10)) as EVE_PROG_ID, "
   cQuery +=            " CONVERT(VARCHAR, A.DT_INICIO, 103) AS DT_INICIO, "
   cQuery +=            " CONVERT(VARCHAR, A.DT_INICIO, 108) AS HR_INICIO, "
   cQuery +=            " B.EVE_DESC "
   cQuery +=       " FROM TAB_PROGRAMACAO_EVENTOS A"
   cQuery +=       " LEFT JOIN TAB_AGEN_EVENTOS B on B.EVE_ID = A.EVE_ID"
   
   If !lBrowse .And. !Empty(cPrgId)
   		cQuery +=			" WHERE A.PROG_ID = " + cPrgId
   EndIf
   
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliTABEVE,.F.,.T.)


   DbSelectArea(cAliTABEVE)
   While !(cAliTABEVE)->(Eof())
      Aadd(aArrTABEVE,{;
     	               (cAliTABEVE)->PROG_ID, ;
     	               (cAliTABEVE)->EVE_PROG_ID, ;
     	               stranstype((cAliTABEVE)->DT_INICIO,'D'), ;
     	               (cAliTABEVE)->HR_INICIO, ;
     	               (cAliTABEVE)->EVE_DESC})
      (cAliTABEVE)->(DbSkip())
   EndDo
   (cAliTABEVE)->(DbCloseArea())
    cAliTMPEve := MntCargDad(cAliTMPEve,aArrTABEVE,aCamTMPEve)

   //REBOQUES
   if cTipomodal == 'V'
      cQuery :=     " SELECT  "
      cQuery +=            " CAST(PROG_ID as VarChar(10)) as PROG_ID, "
      cQuery +=            " REB_ID "
      cQuery +=       " FROM REL_PROG_REBOQUE"
      
      If !lBrowse .And. !Empty(cPrgId)
   		cQuery +=			" WHERE PROG_ID = " + cPrgId
      EndIf
      
      cQuery := ChangeQuery(cQuery)
      DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliTABREB,.F.,.T.)

      DbSelectArea(cAliTABREB)
      While !(cAliTABREB)->(Eof())
         Aadd(aArrTABREB,{;
     	                  (cAliTABREB)->PROG_ID, ;
     	                  (cAliTABREB)->REB_ID})
         (cAliTABREB)->(DbSkip())
      EndDo
      (cAliTABREB)->(DbCloseArea())
       cAliTMPReb := MntCargDad(cAliTMPReb,aArrTABREB,aCamTMPReb)
    EndIf

   //DOCUMENTOS
   cQuery :=     " SELECT  "
   cQuery +=            " CAST(a.PROG_ID as VarChar(10)) as PROG_ID, "
   cQuery +=            " a.TP_DENT_DSAI, "
   cQuery +=            " a.DENT_ID,c.res_numero, e.cli_nome, e.cli_cgc, a.res_id, a.cfop, a.beneficiario, a.dp_id, d.cfop_descricao "
   cQuery +=       " FROM REL_DENT_PROGRAMACAO a "
   cQuery +=       " left join TAB_TMP_DOC_ENTRADA b "
   cQuery +=       "       on b.dent_id = a.dent_id "
   cQuery +=       " left join tab_reserva c "
   cQuery +=       "       on c.res_id = a.res_id "
   cQuery +=       " left join tab_cfop d "
   cQuery +=       "       on d.cfop_id = a.cfop "
   cQuery +=       " left join tab_clientes e "
   cQuery +=       "       on e.cli_id = a.beneficiario "

   If !lBrowse .And. !Empty(cPrgId)
   		cQuery +=			" WHERE a.PROG_ID = " + cPrgId
   EndIf
   
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliTABDOC,.F.,.T.)

   DbSelectArea(cAliTABDOC)
   While !(cAliTABDOC)->(Eof())

      cTpoDoc := GetDocId(SUBSTR(AllTrim((cAliTABDOC)->DENT_ID),5,1))
      cAnoDoc := SUBSTR(AllTrim((cAliTABDOC)->DENT_ID),1,4)

      IF AllTrim((cAliTABDOC)->TP_DENT_DSAI) == 'S'         
         Retorno := SUBSTR(AllTrim((cAliTABDOC)->DENT_ID),15,6)

         IF UPPER(cTpoDoc) == 'NF'
         	cSerDoc := SUBSTR(AllTrim((cAliTABDOC)->DENT_ID),6,3)
         	cNumDoc := SUBSTR(AllTrim((cAliTABDOC)->DENT_ID),9,9)
			cPrcDoc := AllTrim(GETPSARA("PROC_NAC"))        	
         else
         	cSerDoc := ''
         	cNumDoc := SUBSTR(AllTrim((cAliTABDOC)->DENT_ID),6,9)
			cPrcDoc := ''         	
         endif         
      ELSE        
         IF UPPER(cTpoDoc) == 'NF'
            cNumDoc := SUBSTR(AllTrim((cAliTABDOC)->DENT_ID),9,13)
            cSerDoc := SUBSTR(AllTrim((cAliTABDOC)->DENT_ID),6,3)
            cPrcDoc := SUBSTR(AllTrim((cAliTABDOC)->DENT_ID),22,3)
         ELSE
            cNumDoc := SUBSTR(AllTrim((cAliTABDOC)->DENT_ID),6,16)
            cSerDoc := ""
            cPrcDoc := SUBSTR(AllTrim((cAliTABDOC)->DENT_ID),22,3)
         EndIf
      EndIf

      Aadd(aArrTABDOC,{;
     	               alltrim(stranstype((cAliTABDOC)->PROG_ID,'C')), ;
     	               alltrim(stranstype((cAliTABDOC)->dp_id,'C')), ;
     	               alltrim((cAliTABDOC)->TP_DENT_DSAI), ;
     	               alltrim((cAliTABDOC)->DENT_ID),;
     	               cTpoDoc,;
     	               cAnoDoc,;
     	               cNumDoc,;
     	               cSerDoc,;
     	               cPrcDoc,;
     	               alltrim(stranstype((cAliTABDOC)->res_id,'C')),;
     	               alltrim((cAliTABDOC)->cfop),;
     	               alltrim((cAliTABDOC)->res_numero),;
     	               alltrim((cAliTABDOC)->beneficiario),;
     	               alltrim((cAliTABDOC)->cli_cgc),;
     	               alltrim((cAliTABDOC)->cli_nome),;
     	               alltrim((cAliTABDOC)->cfop_descricao);
     	               })
      (cAliTABDOC)->(DbSkip())
   EndDo
   (cAliTABDOC)->(DbCloseArea())
    cAliTMPDoc := MntCargDad(cAliTMPDoc,aArrTABDOC,aCamTMPDoc)

   //ANEXOS
   cQuery :=     " SELECT  "
   cQuery +=            " CAST(PROG_ID as VarChar(10)) as PROG_ID, "
   cQuery +=            " REPLICATE('0', 10 -LEN(ANE_PROG_ID)) + CAST(ANE_PROG_ID as VarChar(10)) ANE_PROG_ID, "
   cQuery +=            " ANE_ARQUIVO, "
   cQuery +=            " ANE_OBS "
   cQuery +=       " FROM TAB_PROGRAMACAO_ANEXOS"
   
   If !lBrowse .And. !Empty(cPrgId)
   		cQuery +=			" WHERE PROG_ID = " + cPrgId
   EndIf
   
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliTABANE,.F.,.T.)

   DbSelectArea(cAliTABaNE)
   While !(cAliTABANE)->(Eof())
      Aadd(aArrTABANE,{;
     	               (cAliTABANE)->PROG_ID, ;
     	               (cAliTABANE)->ANE_PROG_ID, ;
     	               (cAliTABANE)->ANE_ARQUIVO, ;
     	               (cAliTABANE)->ANE_OBS})
      (cAliTABANE)->(DbSkip())
   EndDo
   (cAliTABANE)->(DbCloseArea())
    cAliTMPAne := MntCargDad(cAliTMPAne,aArrTABANE,aCamTMPAne)

	cQuery :=		'    select  a.pic_id, '
	cQuery +=		'        a.prog_id,'
	cQuery +=		'       a.dp_id,b.dent_id, '
	cQuery +=		'        a.res_id,'
	cQuery +=		'        e.res_numero,'
	cQuery +=		'        a.lote_id,'
	cQuery +=		'        a.lote_item,'
	cQuery +=		'        a.pic_qt_volumes,'
	cQuery +=		'        a.pic_m3,'
	cQuery += 		"		  f.esp_id + " + "' - '" + " + g.esp_descricao as embalagem, "
	cQuery +=		'        f.latu_descricao '
	cQuery +=		'        from tab_programacao_itens_carga a'
	cQuery +=		'        left join rel_dent_programacao b'
	cQuery +=		'            on b.dp_id = a.dp_id'
	cQuery +=		'        left join tab_reserva e'
	cQuery +=		'            on e.res_id = a.res_id '
	cQuery +=		'        left join vw_inventario_armazem f'
	cQuery +=		'            on f.latu_lote = a.lote_id and  f.latu_item = a.lote_item '
	cQuery +=		'        left join tab_especie g '
	cQuery +=		'            on g.esp_id = f.esp_id '

    If !lBrowse .And. !Empty(cPrgId)
   		cQuery +=			" WHERE a.PROG_ID = " + cPrgId
    EndIf
   
	cQuery := ChangeQuery(cQuery)
   DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliITCAR,.F.,.T.)

   DbSelectArea(cAliITCAR)
   While !(cAliITCAR)->(Eof())
      Aadd(aArrTABITCAR,{;
      					 alltrim(stranstype((cAliITCAR)->prog_id,'C')),;
     	               alltrim(stranstype((cAliITCAR)->pic_id,'C')),;
     	               alltrim(stranstype((cAliITCAR)->dp_id,'C')), ;
     	               alltrim(stranstype((cAliITCAR)->dent_id,'C')), ;
     	               alltrim(stranstype((cAliITCAR)->res_id,'C')), ;
     	               alltrim((cAliITCAR)->res_numero), ;
     	               alltrim((cAliITCAR)->lote_id), ;
     	               IIF((cAliITCAR)->lote_item = 0,'',alltrim(stranstype((cAliITCAR)->lote_item,'C'))),;
     	               alltrim(stranstype((cAliITCAR)->pic_qt_volumes,'C')), ;
     	               alltrim((cAliITCAR)->latu_descricao), ;
     	               (cAliITCAR)->pic_m3,;
      					 alltrim((cAliITCAR)->embalagem);
      					 })
      (cAliITCAR)->(DbSkip())
   EndDo
   (cAliITCAR)->(DbCloseArea())
   cAliTMPITCAR := MntCargDad(cAliTMPITCAR,aArrTABITCAR,aCamTMPITCAR)

	cQuery :=	' select a.pid_id, '
	cQuery +=	' a.dp_id,'
	cQuery +=	' a.esp_id,b.dent_id,'
	cQuery +=	' a.pid_qt_volumes,'
	cQuery +=	' a.pid_m3,'
	cQuery +=	' a.pid_peso,'
	cQuery +=	' a.fam_id, d.fam_desc_gen,c.esp_descricao,d.fam_desc_gen, '
	cQuery +=	' a.pid_descricao_produto, b.prog_id'
	cQuery +=	' from tab_programacao_itens_desc a'
	cQuery +=	' left join rel_dent_programacao b'
	cQuery +=	'    on b.dp_id = a.dp_id'
	cQuery +=	' left join tab_especie c'
	cQuery +=	'    on c.esp_id = a.esp_id'
	cQuery +=	' left join tab_familias d'
	cQuery +=	'   on d.fam_id = a.fam_id'
	
	If !lBrowse .And. !Empty(cPrgId)
   		cQuery +=			" WHERE b.PROG_ID = " + cPrgId
   EndIf

   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliITDES,.F.,.T.)

   DbSelectArea(cAliITDES)
   While !(cAliITDES)->(Eof())
      Aadd(aArrTABITDES,{;
      					 alltrim(stranstype((cAliITDES)->prog_id,'C')),;
     	               alltrim(stranstype((cAliITDES)->pid_id,'C')),;
     	               alltrim(stranstype((cAliITDES)->dp_id,'C')),;
     	               alltrim((cAliITDES)->dent_id),;
     	               alltrim((cAliITDES)->esp_id),;
     	               alltrim((cAliITDES)->esp_descricao),;
     	               alltrim(stranstype((cAliITDES)->pid_qt_volumes,'C')),;
     	               (cAliITDES)->pid_m3,;
     	               (cAliITDES)->pid_peso,;
     	               alltrim((cAliITDES)->fam_id),;
     	               alltrim((cAliITDES)->fam_desc_gen),;
     	               alltrim((cAliITDES)->pid_descricao_produto);
     	               })
      (cAliITDES)->(DbSkip())
   EndDo

   (cAliITDES)->(DbCloseArea())
   cAliTMPITDES := MntCargDa2(cAliTMPITDES,aArrTABITDES,aCamTMPITDES)

   aSize(aArrTABEVE  ,0)
   aSize(aArrTABREB  ,0)
   aSize(aArrTABDOC  ,0)
   aSize(aArrTABANE  ,0)
   aSize(aArrTABPRCNT,0) 
   aSize(aArrTABITCAR,0) 
   aSize(aArrTABITDES,0)
Return .T.

static Function MntCargDa2(cAliasTab,arrayDados, arrayCampos)

	Local nCont := 0
	Local nCont1   := 0

	//-------------------------------------------------------------------
	// Limpa tabela temporária
	//-------------------------------------------------------------------
	dbSelectArea(cAliasTab)
	(cAliasTab)->( dbSetOrder(1) )
	ZAP

	//-------------------------------------------------------------------
	// Carga de dados
	//-------------------------------------------------------------------
	For nCont := 1 To Len(arrayDados)
		RecLock(cAliasTab,.T.)
		For nCont1 := 1 To Len(arrayCampos)
			(cAliasTab)->&(arrayCampo[nCont1,1]) := arrayDados[nCont,nCont1]
		Next
		MsUnLock(cAliasTab)
	Next
	dbGoTop()
Return cAliasTab

/*/{Protheus.doc} PST_TABDOC
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Tratamento realizados no post do Model da tabela de documentos
/*/
Static Function PST_TABDOC()
	Local lRet       := .T.
	Local cDoc_ID := ''
	Local cTipoDOC
	Local cProcNac
	Local oModel    := FWModelActive()
	Local nOp       := oModel:getOperation()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local serie := ''
	Local nI := 0

	if alltrim(omodeldoc:getvalue('DOC_NUM_DC')) <> ''
		/*
		IF (UPPER(cProcNac) <> UPPER(AllTrim(oModelDOC:GetValue('DOC_PRC_DC')))) .and. (UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF')
		  oModel:SetErrorMessage('PRAA802DOC', 'DOC_SER_DC',,,,STR0106 )
		  Return .F.
		EndIf
	   */
		if PST_VAL_DOC_NUM() = .F.
				return .f.
		endif

	   IF ((nOp == 3) .or. (nOp == 4))//inclusão //Alteração
			if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) == 'E'
			
					For nI := 1 To oModelDOC:Length()
					oModelDOC:GoLine(nI)	
					if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) == 'E'
				    	if .not. oModelDOC:IsDeleted()	
 
				    	   if  UPPER(AllTrim(oModelDOC:GetValue('DOC_PRC_DC'))) <> ''
					         	cProcNac := AllTrim(GETPSARA("PROC_NAC"))
					         	IF (UPPER(cProcNac) <> UPPER(AllTrim(oModelDOC:GetValue('DOC_PRC_DC')))) .and. (UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF')
					         	   oModel:SetErrorMessage('PRAA802DOC', 'DOC_SER_DC',,,,STR0106 )
					         	   Return .F.
					        	 EndIf
							else
							 	 oModel:SetErrorMessage('PRAA802DOC', 'DOC_SER_DC',,,,'Para o documento de entrada, deve-se informar a procedência.')
						       Return .F.
					   		endif
					   		
					   		cTipoDOC := VAL0005RetornaCodTipoDoc(oModelDOC:GetValue('DOC_TPO_DC'))

				      		IF UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF'
				      	   		serie := AllTrim(oModelDOC:GetValue('DOC_SER_DC'))
				      	   		
				           	IF Len(AllTrim(oModelDOC:GetValue('DOC_SER_DC'))) <> 3
				            		oModel:SetErrorMessage('PRAA802DOC', 'DOC_SER_DC',,,,STR0105 )
				            		Return .F.
				            	endif

				          		IF AllTrim(oModelDOC:GetValue('DOC_CFOP')) = ''
				            		oModel:SetErrorMessage('PRAA802DOC', 'DOC_CFOP',,,,'Para nota fiscal o campo CFOP é obrigatório.' )
				            		Return .F.
				          		endif

				          		IF AllTrim(oModelDOC:GetValue('DOC_BEN')) = ''
				             		oModel:SetErrorMessage('PRAA802DOC', 'DOC_BEN',,,,'Para nota fiscal o campo beneficiário é obrigatório.' )
				            		Return .F.
				          		endif

 								////VAL_NUM_DC(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) + AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))+;
				         		cDoc_ID := AllTrim(oModelDOC:GetValue('DOC_ANO_DC'))+;
				                    AllTrim(cTipoDOC) +;
				                    serie  +;
				                    VAL_NUM_DC()+;
				                    AllTrim(cProcNac) +;
				                    Alltrim(oModelDOC:GetValue('DOC_BEN_ID'))				                    
				          else
				      	   		cDoc_ID := AllTrim(oModelDOC:GetValue('DOC_ANO_DC'))+;
				                    AllTrim(cTipoDOC) +;
				                    serie  +;
				                    VAL_NUM_DC()+;
				                    UPPER(AllTrim(oModelDOC:GetValue('DOC_PRC_DC'))) +;
				                    '999999'
				          endif	

				          	oModelDOC:setvalue('DOC_DOC_ID',cDoc_ID)				         
				          	
				          	if VAL_NUM_DC() <> 'ERROR'
								if (AllTrim(oModelDOC:GetValue('DOC_RES_NU')) != '') .And. (VAL0003ReservaPossuiPreCadastro(AllTrim(oModelDOC:GetValue('DOC_RES_NU')))) .And. !oModelDOC:IsDeleted()	
	 								if !VAL0004PossuiRelReserva((AllTrim(oModelDOC:GetValue('DOC_RES_NU'))), AllTrim(cDoc_ID), '')  
										oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3078', 'O número de documento ' + AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) + ' não possui relacionamento com a reserva selecionada.','',nil,nil)
										Return .F.
									endif	 	
								endif  
							endif	 
						endif
					EndIf					         
					next nI

		      ELSE
					cTipoDOC := VAL0005RetornaCodTipoDoc(oModelDOC:GetValue('DOC_TPO_DC'))
					
		         //VAL_NUM_DC(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) + AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))+;
		         	IF UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF'
		         		 serie := AllTrim(oModelDOC:GetValue('DOC_SER_DC'))
				         IF Len(AllTrim(oModelDOC:GetValue('DOC_SER_DC'))) <> 3
				            oModel:SetErrorMessage('PRAA802DOC', 'DOC_SER_DC',,,,STR0105 )
				            Return .F.
				         endif

				         IF AllTrim(oModelDOC:GetValue('DOC_CFOP')) = ''
				            oModel:SetErrorMessage('PRAA802DOC', 'DOC_CFOP',,,,'Para nota fiscal o campo CFOP é obrigatório.' )
				            Return .F.
				         endif

				         IF AllTrim(oModelDOC:GetValue('DOC_BEN')) = ''
				            oModel:SetErrorMessage('PRAA802DOC', 'DOC_BEN',,,,'Para nota fiscal o campo beneficiário é obrigatório.' )
				            Return .F.
				         endif

				         cDoc_ID :=  AllTrim(oModelDOC:GetValue('DOC_ANO_DC'))+;
		                     AllTrim(cTipoDOC) +;
		                     serie +;
		                     VAL_NUM_DC()+;
		                     Alltrim(oModelDOC:GetValue('DOC_BEN_ID'))
					else
						cDoc_ID :=  AllTrim(oModelDOC:GetValue('DOC_ANO_DC'))+;
		                     AllTrim(cTipoDOC) +;
		                     serie +;
		                     VAL_NUM_DC()
				    endif

		         	   oModelDOC:setvalue('DOC_PRC_DC','')
		         	   oModelDOC:setvalue('DOC_DOC_ID',cDoc_ID)
		         	   
				      if VAL_NUM_DC() <> 'ERROR'
							if (AllTrim(oModelDOC:GetValue('DOC_RES_NU')) != '') .And. !oModelDOC:IsDeleted()	
	 							if !VAL0007PossuiRelResSaida('' , AllTrim(cDoc_ID), '')  
									oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3079', 'O número de documento ' + AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) + ' não possui relacionamento com a reserva selecionada.','',nil,nil)
									Return .F.
								endif	 	
							endif  
					   endif	 		         	   
		      EndIF

	   endif
	endif
Return lRet



/*/{Protheus.doc} PST_TABD2
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@Param aInf, array, retorno no formato de array, passado como referencia
@obs Tratamento realizados no post do Model da tabela de documentos
/*/
Static Function PST_TABD2(aInf)
	Local cDoc_ID := ''
	Local cTipoDOC
	Local cProcNac
	Local tTabDocum := GetNextAlias()
	Local oModel    := FWModelActive()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local oModelCNT := oModel:GetModel('PRAA802CNT')
	Local nOp       := oModel:getOperation()
	lOCAL serie := ''
	Local cValorNumDC := ''
	Default aInf := {'','','','','',''}
	//alert('testePST_TABDOC()')
	cValorNumDC := VAL_DOC2()
	if  alltrim(cValorNumDC) <> ''
			return alltrim(cValorNumDC)
	endif
   If Type("a_PRC_DC") == "U"
		a_PRC_DC := {''}
		SEL_AR_PRO()
   EndIf
   IF ((nOp == 3) .or. (nOp == 4))//inclusão //Alteração
   	   cQuery := " SELECT DOC_ORDEM1 FROM TAB_DOCUMENTOS WHERE DOC_ID = '"+AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))+"'"
       dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabDocum, .F., .T.)
       cTipoDOC := AllTrim((tTabDocum)->DOC_ORDEM1)
       (tTabDocum)->(DbCloseArea())
       
       
       if (cSubOpCntCheio == '')
		  	StaticCall(PRAA802,VAL_SUB_ID)      
	   EndIf
      
       //ESTA VERIFICAÇÃO É FEITA SOMENTE COM A OPERAÇÃO DE CNT VAZIO OU CHEIA
       If (( AllTrim(oModelCNT:GetValue('CNT_TPO_ES')) <> '') .And. (cSubOpMercSolta <> '1') .And.;
          ((oModelCNT:GetValue('CNT_TPO_ES') <> oModelDOC:GetValue('DOC_TPO_ES')) .Or.;
          (oModelCNT:GetValue('CNT_RES_ID') <> oModelDOC:GetValue('DOC_RES_ID'))))
            cDoc_ID := ''
       Else
	   if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) == 'E'

                 if  UPPER(AllTrim(oModelDOC:GetValue('DOC_PRC_DC'))) <> ''
			         cProcNac := AllTrim(GETPSARA("PROC_NAC"))
			         IF (UPPER(cProcNac) <> UPPER(AllTrim(oModelDOC:GetValue('DOC_PRC_DC')))) .and. (UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF')
			            //oModel:SetErrorMessage('PRAA802DOC', 'DOC_SER_DC',,,,STR0106 )
			            Return 'ERROR' + STR0106 + '(DOC_SER_DC)'
			         EndIF
				 else
					  //oModel:SetErrorMessage('PRAA802DOC', 'DOC_SER_DC',,,,'Para o documento de entrada, deve-se informar a procedência.')
				      Return 'ERROR' + 'Para o documento de entrada, deve-se informar a procedência.' + '(DOC_SER_DC)'
			     endif

			      IF UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF'
			      	  serie := AllTrim(oModelDOC:GetValue('DOC_SER_DC'))
			         IF Len(AllTrim(oModelDOC:GetValue('DOC_SER_DC'))) <> 3
			            //oModel:SetErrorMessage('PRAA802DOC', 'DOC_SER_DC',,,,STR0105 )
			            Return 'ERROR' + STR0105 + '(DOC_SER_DC)'
			         endif

			         IF AllTrim(oModelDOC:GetValue('DOC_CFOP')) = ''
			            //oModel:SetErrorMessage('PRAA802DOC', 'DOC_CFOP',,,,'Para nota fiscal o campo CFOP é obrigatório.' )
			            Return 'ERROR' + 'Para nota fiscal o campo CFOP é obrigatório.' + '(DOC_CFOP)'
			         endif

			         IF AllTrim(oModelDOC:GetValue('DOC_BEN')) = ''
			            //oModel:SetErrorMessage('PRAA802DOC', 'DOC_BEN',,,,'Para nota fiscal o campo beneficiário é obrigatório.' )
			            Return 'ERROR' + 'Para nota fiscal o campo beneficiário é obrigatório.' + '(DOC_BEN)'
			         endif

						////VAL_NUM_DC(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) + AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))+;
						if VAL_NUM_DC() = 'ERROR'
							return 'ERRORDefina os valores do documento corretamente.'
						endif

			         	cDoc_ID := AllTrim(oModelDOC:GetValue('DOC_ANO_DC'))+;
			                    AllTrim(cTipoDOC) +;
			                    serie  +;
			                    VAL_NUM_DC()+;
			                    AllTrim(cProcNac) +;
			                    Alltrim(oModelDOC:GetValue('DOC_BEN_ID'))
			          aInf := {	cDoc_ID,;
			          			   AllTrim(oModelDOC:GetValue('DOC_TPO_DC')),;
			          			   AllTrim(oModelDOC:GetValue('DOC_ANO_DC')),;
			          			   VAL_NUM_DC(),;
			                    serie  ,;
			                    GetStrAbox(a_PRC_DC,AllTrim(oModelDOC:GetValue('DOC_PRC_DC'))) }
			      else
			      		if VAL_NUM_DC() = 'ERROR'
							return 'ERRORDefina os valores do documento corretamente.'
						endif
			      		cDoc_ID := AllTrim(oModelDOC:GetValue('DOC_ANO_DC'))+;
			                    AllTrim(cTipoDOC) +;
			                    serie  +;
			                    VAL_NUM_DC()+;
			                    UPPER(AllTrim(oModelDOC:GetValue('DOC_PRC_DC'))) +;
			                    '999999'
						 aInf := {	cDoc_ID,;
			          			   AllTrim(oModelDOC:GetValue('DOC_TPO_DC')),;
			          			   AllTrim(oModelDOC:GetValue('DOC_ANO_DC')),;
			          			   VAL_NUM_DC(),;
			                    serie  ,;
			                    GetStrAbox(a_PRC_DC,AllTrim(oModelDOC:GetValue('DOC_PRC_DC'))) }
			      endif

	      ELSE
	         //VAL_NUM_DC(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) + AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))+;
	         //AllTrim(oModelDOC:GetValue('DOC_PRC_DC'))+;
	         	IF UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF'
	         		 serie := AllTrim(oModelDOC:GetValue('DOC_SER_DC'))
			         IF Len(AllTrim(oModelDOC:GetValue('DOC_SER_DC'))) <> 3
			            //oModel:SetErrorMessage('PRAA802DOC', 'DOC_SER_DC',,,,STR0105 )
			            Return 'ERROR' + STR0105 + '(DOC_SER_DC)'
			         endif

			         IF AllTrim(oModelDOC:GetValue('DOC_CFOP')) = ''
			            //oModel:SetErrorMessage('PRAA802DOC', 'DOC_CFOP',,,,'Para nota fiscal o campo CFOP é obrigatório.' )
			            Return 'ERROR' + 'Para nota fiscal o campo CFOP é obrigatório.' + '(DOC_CFOP)'
			         endif

			         IF AllTrim(oModelDOC:GetValue('DOC_BEN')) = ''
			            //oModel:SetErrorMessage('PRAA802DOC', 'DOC_BEN',,,,'Para nota fiscal o campo beneficiário é obrigatório.' )
			            Return 'ERROR' + 'Para nota fiscal o campo beneficiário é obrigatório.' + '(DOC_BEN)'
			         endif

			         if VAL_NUM_DC() = 'ERROR'
							return 'ERRORDefina os valores do documento corretamente.'
						endif
			         cDoc_ID :=  AllTrim(oModelDOC:GetValue('DOC_ANO_DC'))+;
	                     AllTrim(cTipoDOC) +;
	                     serie +;
	                     VAL_NUM_DC()+;
	                     Alltrim(oModelDOC:GetValue('DOC_BEN_ID'))//oModelTMP:GetValue('TMP_CLI_ID')//DOC_BEN_ID

	                 aInf := {	cDoc_ID,;
			          			   AllTrim(oModelDOC:GetValue('DOC_TPO_DC')),;
			          			   AllTrim(oModelDOC:GetValue('DOC_ANO_DC')),;
			          			   VAL_NUM_DC(),;
			                    serie  ,;
			                    GetStrAbox(a_PRC_DC,AllTrim(oModelDOC:GetValue('DOC_PRC_DC'))) }
				else
					   if VAL_NUM_DC() = 'ERROR'
							return 'ERRORDefina os valores do documento corretamente.'
						endif

						cDoc_ID :=  AllTrim(oModelDOC:GetValue('DOC_ANO_DC'))+;
                     			AllTrim(cTipoDOC) +;
                     			serie +;
                     			VAL_NUM_DC()

                     aInf := {	cDoc_ID,;
			          			   AllTrim(oModelDOC:GetValue('DOC_TPO_DC')),;
			          			   AllTrim(oModelDOC:GetValue('DOC_ANO_DC')),;
			          			   VAL_NUM_DC(),;
			                    serie  ,;
			                    GetStrAbox(a_PRC_DC,AllTrim(oModelDOC:GetValue('DOC_PRC_DC'))) }
			    endif

	         			//oModelDOC:setvalue('DOC_PRC_DC','')
	      EndIF 
	  EndIf   
      //oModelDOC:setvalue('DOC_DOC_ID',cDoc_ID)
   endif
Return cDoc_ID

/*/{Protheus.doc} PST_TABANE
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Tratamento realizados no post do Model da tabela de anexos
/*/
Static Function PST_TABANE(oModelANE)
	Local lRet     := .T.
	Local nOp      := (oModelANE:getOperation())
	Local oModel   := FWModelActive()
	Local FileName := ""
	Local cDirGrav := GetMV("MV_WMSANEP")
	Local cDrive   :=""
	Local cFile    :=""
	Local cDir     :=""
	Local cExten   :=""
	Local cBarra   :="\"

   IF ((nOp == 3) .or. (nOp == 4))//inclusão //Alteração
      FileName := AllTrim(oModelANE:GetValue('ANE_ARQUIV'))
      IF File(FileName, 1 ,.T.)
         IF CpyT2S(FileName,cDirGrav,.F.)
            IF IsSrvUnix()
               cBarra := "/"
            ELSE
               cBarra := "\"
            EndIf

            SplitPath( FileName, @cDrive, @cDir, @cFile, @cExten )
            FileName := cFile+"_"+cValToChar(Day(Date()))+"-"+cValToChar(MONTH(Date()))+"-"+cValToChar(Year(Date()))+"_"+SUBSTR(TIME(),1,2)+"-"+SUBSTR(TIME(),4,2)+"-"+SUBSTR(TIME(),7,2)+cExten
            IF FRenameEx(cDirGrav+cBarra+cFile+cExten,cDirGrav+cBarra+FileName) = 0
               oModelANE:SetValue('ANE_ARQUIV',FileName)
            ELSE
               oModel:SetErrorMessage('PRAA802ANE', 'ANE_ARQUIV',,,,STR0109)
               lRet := .F.
            EndIf
         ELSE
            oModel:SetErrorMessage('PRAA802ANE', 'ANE_ARQUIV',,,,STR0109)
            lRet := .F.
         EndIf
      ELSE
         oModel:SetErrorMessage('PRAA802ANE', 'ANE_ARQUIV',,,,STR0110+" : "+oModelANE:GetValue('ANE_ARQUIV') )
         lRet := .F.
      EndIf
   EndIf

Return lRet



/*/{Protheus.doc} RET_USER
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Retorna Usuario
/*/
Function RET_USER()
   Local tTabUser := GetNextAlias()
   Local cCodUsr

   cQuery :=     " SELECT  "
   cQuery +=            " USU_ID "
   cQuery +=       " FROM TAB_USUARIOS "
   cQuery +=      " WHERE USU_ID = 'c"+ StrTran(SCodUsr(),'ECPF','',1,1) + "'"
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),tTabUser,.F.,.T.)

   cCodUsr := AllTrim((tTabUser)->USU_ID)
   (tTabUser)->(DbCloseArea())
Return cCodUsr


/*/{Protheus.doc} A802CRI_TABTMP
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Cria a tabela temporaria
/*/
Function A802CRI_TABTMP()

   Aadd(aCamposTMP,{"TMP_PRG_ID","C",10,0})
   Aadd(aCamposTMP,{"TMP_STR_PG","C",10,0})
   Aadd(aCamposTMP,{"TMP_VEI_ID","C",11,0})
   Aadd(aCamposTMP,{"TMP_EVE_ID","C",10,0})
   Aadd(aCamposTMP,{"TMP_EVE_DS","C",20,0})
   Aadd(aCamposTMP,{"TMP_DT_EVE","D",10,0})
   Aadd(aCamposTMP,{"TMP_HR_EVE","C",5,0})
   Aadd(aCamposTMP,{"TMP_DT_ENT","D",10,0})
   Aadd(aCamposTMP,{"TMP_HR_ENT","C",5,0})
   Aadd(aCamposTMP,{"TMP_PRE_SA","D",10,0})
   Aadd(aCamposTMP,{"TMP_HR_SAI","C",5,0})
   Aadd(aCamposTMP,{"TMP_REB_ID","C",10,0})
   Aadd(aCamposTMP,{"TMP_VEI_RE","C",10,0})
   Aadd(aCamposTMP,{"TMP_CLI_ID","C",6,0})
   Aadd(aCamposTMP,{"TMP_CLI_CG","C",18,0})
   Aadd(aCamposTMP,{"TMP_ORI_DS","C",50,0})
   Aadd(aCamposTMP,{"TMP_DES_ID","C",10,0})
   Aadd(aCamposTMP,{"TMP_DES_DS","C",50,0})
   Aadd(aCamposTMP,{"TMP_REC_ID","C",10,0})
   Aadd(aCamposTMP,{"TMP_PRT_ID","C",10,0})
   Aadd(aCamposTMP,{"TMP_TRA_ID","C",10,0})
   Aadd(aCamposTMP,{"TMP_TRA_CG","C",18,0})
   Aadd(aCamposTMP,{"TMP_TRA_DS","C",50,0})
   Aadd(aCamposTMP,{"TMP_NAT_ID","C",3,0})
   Aadd(aCamposTMP,{"TMP_OPE_ID","C",10,0})
   Aadd(aCamposTMP,{"TMP_OPE_DS","C",30,0})
   Aadd(aCamposTMP,{"TMP_SUB_ID","C",10,0})
   Aadd(aCamposTMP,{"TMP_SUB_DS","C",30,0})
   Aadd(aCamposTMP,{"TMP_RC_ID2","C",10,0})
   Aadd(aCamposTMP,{"TMP_PES_ID","C",10,0})
   Aadd(aCamposTMP,{"TMP_PES_CG","C",18,0})
   Aadd(aCamposTMP,{"TMP_PES_DS","C",50,0})
   Aadd(aCamposTMP,{"TMP_CRA_ID","C",10,0})
   Aadd(aCamposTMP,{"TMP_CG_PRE","N",18,7})
   Aadd(aCamposTMP,{"TMP_CG_REA","N",18,7})
   Aadd(aCamposTMP,{"TMP_CES_ID","C",12,0})
   Aadd(aCamposTMP,{"TMP_STATUS","N",1,0})
   Aadd(aCamposTMP,{"TMP_ATIVO","N",1,0})
   Aadd(aCamposTMP,{"TMP_MODAL","C",11,0})
   Aadd(aCamposTMP,{"TMP_DC_ID","C",10,0})
   Aadd(aCamposTMP,{"TMP_QUANT","N",6,0})
   Aadd(aCamposTMP,{"TMP_PJC_ID","N",5,0})
   Aadd(aCamposTMP,{"TMP_DC_D","C",50,0})
   Aadd(aCamposTMP,{"TMP_EVE_D","C",20,0})
   Aadd(aCamposTMP,{"TMP_DT_INE","C",10,0})
   Aadd(aCamposTMP,{"TMP_DT_FIE","C",10,0})
   Aadd(aCamposTMP,{"TMP_DT_AGE","C",50,0})
   Aadd(aCamposTMP,{"TMP_PESO",  "N",13,2})
   Aadd(aCamposTMP,{"TMP_CUBICO","N",13,2})
   Aadd(aCamposTMP,{"TMP_DT_PRE","D",10,0})
   Aadd(aCamposTMP,{"TMP_HR_PRE","C",5,0})
   Aadd(aCamposTMP,{"TMP_EDIT_P","N",1,0})
   Aadd(aCamposTMP,{"TMP_COD_M","C",1,0})
   Aadd(aCamposTMP,{"TMP_PA_BLQ","C",1,0})
   Aadd(aCamposTMP,{"TMP_PA_ID","N",5,0})
   Aadd(aCamposTMP,{"TMP_PAJ_ID","N",5,0})
   Aadd(aCamposTMP,{"TMP_AGDT_I","C",30,0})
   Aadd(aCamposTMP,{"TMP_AGHR_I","C",30,0})
   Aadd(aCamposTMP,{"TMP_AGDT_F","C",30,0})
   Aadd(aCamposTMP,{"TMP_AGHR_F","C",30,0})
   Aadd(aCamposTMP,{"TMP_DT_CAN","C",20,0})
   Aadd(aCamposTMP,{"TMP_CL_CGC","C",20,0})
   Aadd(aCamposTMP,{"TMP_CRE_ID","C",6,0})
   Aadd(aCamposTMP,{"TMP_OBSERV","M",255,0})
   Aadd(aCamposTMP,{"TMP_CRE_DS","C",50,0})
   Aadd(aCamposTMP,{"TMP_TO_DOC","C",10,0})
   Aadd(aCamposTMP,{"TMP_TO_CNT","C",10,0})
   Aadd(aCamposTMP,{"TMP_VIAGEM","C",8,0})
   Aadd(aCamposTMP,{"TMP_VIGOPE","C",10,0})
   Aadd(aCamposTMP,{"TMP_CLIFER","C",50,0})
   Aadd(aCamposTMP,{"TMP_OPFER","C",30,0})


  // cAliasTMP := CriaTabTmp(aCamposTMP,{'TMP_PRG_ID',"TMP_VEI_ID",'TMP_DT_ENT'},cAliasTMP)
  cAliasTMP := SCriaTbTmp({aCamposTMP,{'TMP_STR_PG','TMP_VEI_ID','DTOS(TMP_DT_ENT)+TMP_HR_ENT'}},cAliasTMP)
   //cAliasTMP := CriaTabTmp(aCamposTMP,{'TMP_STR_PG','TMP_VEI_ID','DTOS(TMP_DT_ENT)+TMP_HR_ENT'},cAliasTMP)
   //cAliasTMP := CriaTabTmp(aCamposTMP,{'TMP_STR_PG','TMP_VEI_ID','DTOS(TMP_DT_ENT)'},cAliasTMP)




   //tab_programacao_container
   Aadd(aCamTMPPCNT,{"CNT_PRG_ID","C",10,0})
   Aadd(aCamTMPPCNT,{"CNT_PCNT_I","C",10,0})
   Aadd(aCamTMPPCNT,{"CNT_CNT_ID","C",11,0})
   Aadd(aCamTMPPCNT,{"CNT_TPO_ES","C",10,0})
   Aadd(aCamTMPPCNT,{"CNT_TIS_TA","C",2,0})
   Aadd(aCamTMPPCNT,{"CNT_TISO_I","C",4,0})
   Aadd(aCamTMPPCNT,{"CNT_QTD_CN","C",10,0})
   Aadd(aCamTMPPCNT,{"CNT_RES_NU","C",30,0}) 
   Aadd(aCamTMPPCNT,{"CNT_RES_ID","C",10,0})
   Aadd(aCamTMPPCNT,{"CNT_DP_ID" ,"C",10,0})
   Aadd(aCamTMPPCNT,{"CNT_DP_DS" ,"C",30,0})
   Aadd(aCamTMPPCNT,{"CNT_CNTCHE" ,"C",1,0})  
   Aadd(aCamTMPPCNT,{"CNT_DEPOT" ,  "C",1, 0})
   Aadd(aCamTMPPCNT,{"CNT_ARMADO" ,"C",10,0})
   Aadd(aCamTMPPCNT,{"CNT_ARM_DS","C",30,0})
   Aadd(aCamTMPPCNT,{"CNT_PROGRA" ,"C",10,0})
   cAliTMPP := SCriaTbTmp({aCamTMPPCNT,{"CNT_PRG_ID+CNT_PCNT_I"}},cAliTMPP)

  //tab_programacao_eventos
   Aadd(aCamTMPEve,{"EVE_PRG_ID","C",10,0})
   Aadd(aCamTMPEve,{"EVE_SEQ_ID","C",10,0})
   Aadd(aCamTMPEve,{"EVE_DT_INI","D",10,0})
   Aadd(aCamTMPEve,{"EVE_HR_INI","C",5,0})
   Aadd(aCamTMPEve,{"EVE_EVE_DS","C",50,0})
   cAliTMPEve := SCriaTbTmp({aCamTMPEve,{"EVE_PRG_ID+EVE_SEQ_ID"}},cAliTMPEve)

   //rel_prog_reboque
   if cTipomodal == 'V'
      Aadd(aCamTMPReb,{"REB_PRG_ID","C",10,0})
      Aadd(aCamTMPReb,{"REB_REB_ID","C",10,0})
      cAliTMPReb := SCriaTbTmp({aCamTMPReb,{"REB_PRG_ID+REB_REB_ID"}},cAliTMPReb)
   EndIf

   //rel_dent_programacao
   Aadd(aCamTMPDoc,{"DOC_PRG_ID","C",10,0})
   Aadd(aCamTMPDoc,{"DOC_DP_ID","C",10,0})
   Aadd(aCamTMPDoc,{"DOC_TPO_ES","C",1,0})
   Aadd(aCamTMPDoc,{"DOC_DOC_ID","C",30,0})
   Aadd(aCamTMPDoc,{"DOC_TPO_DC","C",10,0})
   Aadd(aCamTMPDoc,{"DOC_ANO_DC","C",4,0})
   Aadd(aCamTMPDoc,{"DOC_NUM_DC","C",20,0})
   Aadd(aCamTMPDoc,{"DOC_SER_DC","C",3,0})
   Aadd(aCamTMPDoc,{"DOC_PRC_DC","C",3,0})
   Aadd(aCamTMPDoc,{"DOC_RES_ID","C",10,0})
   Aadd(aCamTMPDoc,{"DOC_CFOP"  ,"C",5,0})
   Aadd(aCamTMPDoc,{"DOC_RES_NU"  ,"C",30,0})
   Aadd(aCamTMPDoc,{"DOC_BEN_ID"   ,"C",6,0})
   Aadd(aCamTMPDoc,{"DOC_BEN_CG","C",18,0})
   Aadd(aCamTMPDoc,{"DOC_BEN"   ,"C",50,0})
   Aadd(aCamTMPDoc,{"DOC_CFOP_D"   ,"C",100,0})
   cAliTMPDoc := SCriaTbTmp({aCamTMPDoc,{"DOC_PRG_ID+DOC_DOC_ID","DOC_DOC_ID"}},cAliTMPDoc)

   //tab_programacao_anexos
   Aadd(aCamTMPAne,{"ANE_PRG_ID","C",10,0})
   Aadd(aCamTMPAne,{"ANE_ANE_ID","C",10,0})
   Aadd(aCamTMPAne,{"ANE_ARQUIV","C",256,0})
   Aadd(aCamTMPAne,{"ANE_OBSERV","C",50,0})
   cAliTMPAne := SCriaTbTmp({aCamTMPAne,{"ANE_PRG_ID+ANE_ANE_ID"}},cAliTMPAne)


   Aadd(aCamTMPITCAR,{"ITC_PRG_ID","C",10,0})
   Aadd(aCamTMPITCAR,{"ITC_PIC_ID","C",10,0})
   Aadd(aCamTMPITCAR,{"ITC_DP_ID","C",10,0})
   Aadd(aCamTMPITCAR,{"ITC_DP_DS","C",30,0})
   Aadd(aCamTMPITCAR,{"ITC_RES_ID","C",10,0})
   Aadd(aCamTMPITCAR,{"ITC_RES_NU","C",30,0})
   Aadd(aCamTMPITCAR,{"ITC_LOT_ID","C",12,0})
   Aadd(aCamTMPITCAR,{"ITC_LOT_IT","C",10,0})
   Aadd(aCamTMPITCAR,{"ITC_QTD_VO","C",10,0})
   Aadd(aCamTMPITCAR,{"ITC_LIT_DS","C",30,0})
   Aadd(aCamTMPITCAR,{"ITC_M3"    ,"N",13,2})
   Aadd(aCamTMPITCAR,{"ITC_EMB"   ,"C",50,0})

   cAliTMPITCAR := SCriaTbTmp({aCamTMPITCAR,{"ITC_PRG_ID+ITC_PIC_ID"}},cAliTMPITCAR)

   Aadd(aCamTMPITDES,{"ITD_PRG_ID","C",10,0})
   Aadd(aCamTMPITDES,{"ITD_PID_ID" ,"C",10,0})
   Aadd(aCamTMPITDES,{"ITD_DP_ID"  ,"C",10,0})
   Aadd(aCamTMPITDES,{"ITD_DP_DS"  ,"C",30,0})
   Aadd(aCamTMPITDES,{"ITD_ESP_ID" ,"C",2,0})
   Aadd(aCamTMPITDES,{"ITD_ESP_DS" ,"C",30,0})
   Aadd(aCamTMPITDES,{"ITD_QTD_VO","C",10,0})
   Aadd(aCamTMPITDES,{"ITD_M3"     ,"N",13,2})
   Aadd(aCamTMPITDES,{"ITD_PESO"   ,"N",13,2})
   Aadd(aCamTMPITDES,{"ITD_FAM_ID"   ,"C",7,0})
   Aadd(aCamTMPITDES,{"ITD_FAM_DS"   ,"C",30,0})
   Aadd(aCamTMPITDES,{"ITD_DESC"   ,"C",100,0})
   cAliTMPITDES := SCriaTbTmp({aCamTMPITDES,{"ITD_PRG_ID+ITD_PID_ID"}},cAliTMPITDES)

Return .T.

/*/{Protheus.doc} PRAA802OCR
@author Marcelo nunes
@version P12
@Since	11/04/13
@obs Realiza consulta da Placa através da captura OCR
/*/
Function PRAA802OCR()
   Local cNrPlaca := ""
   Local tTabPort  := GetNextAlias()
   Local cPortID := ""
   Local cHostName := ""
   Local nPos := 0
   Local lError := .F.
   Local bError := errorBlock({|e| erro(e) })
   Local oWsOCR := WSIOCRservice():New()
   Local cUrl := ""
   Local cUtilizaOCR := ""
   Local cOCRTriagem := ""

   BEGIN SEQUENCE

   cUtilizaOCR := GETPSARA("HABILITAR_ANALISE_IMAGENS_PORTARIA")
   cOCRTriagem := GETPSARA("OCR_TRIAGEM")
   IF .not.((cUtilizaOCR <> "" .and. cUtilizaOCR <> "0") .and. (cOCRTriagem= "S"))
      MsgInfo(STR0111)
      lError := .T.
      return .F.
   EndIF
   cHostName := ComputerName()
   nPos := At(".", cHostName)
   if nPos > 0
      cHostName := Substr(cHostName, 1, nPos-1)
   EndIF

   cQuery :=     " SELECT "
   cQuery +=            " MIN(PORT_ID) AS PORTARIA "
   cQuery +=       " FROM TAB_PORTARIAS "
   cQuery +=      " WHERE PORT_ENDERECO = (SELECT PARAM_VALOR FROM TAB_PARAMETRO "
   cQuery +=                              " WHERE PARAM_DESC = 'LOC_"+cHostName+"')"
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),tTabPort,.F.,.T.)
   DbSelectArea(tTabPort)
   cPortID := AllTrim(CVALTOCHAR((tTabPort)->PORTARIA))
   (tTabPort)->(DbCloseArea())
   if (cPortID == '' .or. cPortID == '0')
      MsgStop(STR0112)
      lError := .T.
      return .F.
   else
      cUrl := Alltrim(GetMV("MV_WMSAURL"))
      IF cUrl == ""
         MsgStop(STR0113+chr(13)+STR0094)
         lError := .T.
         return .F.
      EndIf

      bConsultaPlaca := {||oWsOCR := WSIOCRservice():New(),oWsOCR:_URL:=cUrl,oWsOCR:ncodPort:=Val(cPortID),oWsOCR:cdtHra := DTOC(DATE())+ ' ' + TIME(),oWsOCR:BuscaPlaca()}
      MsgRun( STR0114,STR0115, bConsultaPlaca )

      cNrPlaca := oWsOCR:creturn

      if cNrPlaca == ''
         MsgInfo(STR0116)
         lError := .T.
         return .F.
      else
         DbSelectArea(cAliasTMP)
         IF (cAliasTMP)->(DbSeek(AllTrim(cNrPlaca)))
         else
            MsgInfo(STR0117+" : "+cNrPlaca)
            lError := .T.
            return .F.
         EndIF
      EndIF
   EndIF
   END SEQUENCE
   ErrorBlock(bError)
   if lError
      Return .F.
   endif

Return .T.

/*/{Protheus.doc} ErroOCR
@author Marcelo nunes
@version P12
@Since	02/01/2014
@obs Tratamento da mensagem de erro ao consultar placa OCR
/*/
Static Function ErroOCR(e,lError)
	Local cDesc :=  e:Description

	if lError == .T.
		return
	else
		if lError == .F.
			MsgStop(cDesc)
		endif
	endif
	lError := .T.
return


/*/{Protheus.doc} LEG_EVENTO
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
		@obs Realiza a montagem de legenda do browse
/*/
Static Function LEG_EVENTO()
   Local tTabEvento := GetNextAlias()
   Local cModal

   if cTipomodal == 'V'
      cModal := 'V'
   else
      cModal := cTipomodal
   EndIf

   cQuery :=     " SELECT  "
   cQuery +=            " EVE_ID, "
   cQuery +=            " EVE_DESC, "
   cQuery +=            " EVE_COR "
   cQuery +=       " FROM TAB_AGEN_EVENTOS"
   cQuery +=      " WHERE EVE_MODAL = '"+cModal+"'"
   cQuery +=        " AND EVE_COR IS NOT NULL "
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),tTabEvento,.F.,.T.)

   DbSelectArea(tTabEvento)
   While !(tTabEvento)->(Eof())
     // oBrowse:AddLegend(" AllTrim((cAliasTMP)->TMP_EVE_ID) == '"+CVALTOCHAR((tTabEvento)->EVE_ID)+"'" ,(tTabEvento)->EVE_COR,(tTabEvento)->EVE_DESC)
      oBrowse:AddLegend(" AllTrim(TMP_EVE_ID) == '"+CVALTOCHAR((tTabEvento)->EVE_ID)+"'" ,(tTabEvento)->EVE_COR,(tTabEvento)->EVE_DESC)
      (tTabEvento)->(DbSkip())
   EndDO
   (tTabEvento)->(DbCloseArea())
Return .T.

/*/{Protheus.doc} GETPSARA
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Esta funcao retorna o valor configurado no parametro no sistema SARA
/*/
Function GETPSARA(cParam)
   Local tTabParam := GetNextAlias()
   cQuery :=     " SELECT  "
   cQuery +=            " PARAM_VALOR AS PARAMETRO"
   cQuery +=       " FROM TAB_PARAMETRO"
   cQuery +=      " WHERE PARAM_DESC = '"+cParam+"'"
   cQuery := ChangeQuery(cQuery)
   DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),tTabParam,.F.,.T.)

   DbSelectArea(tTabParam)
   cParam := AllTrim((tTabParam)->PARAMETRO)
   (tTabParam)->(DbCloseArea())
Return cParam

/*/{Protheus.doc} SEL_AR_POR
@author Marcelo nunes
@version P12
@Since	12/04/13
/*/
Static Function SEL_AR_POR()
    Local tTabPortar := GetNextAlias()

	cQuery := " SELECT PORT_ID, PORT_ENDERECO FROM TAB_PORTARIAS "
	cQuery += "  WHERE PORT_MODAL = '"+cTipomodal+"'"
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabPortar, .F., .T.)

    //Carga combo Pais
	While (tTabPortar)->(!Eof())
		aAdd(a_PRT_ID,CVALTOCHAR((tTabPortar)->PORT_ID)+"="+AllTrim((tTabPortar)->PORT_ENDERECO))
  		(tTabPortar)->(dbSkip())
	EndDo
	(tTabPortar)->(DbCloseArea())
Return .T.

/*/{Protheus.doc} SEL_AR_NAT
@author Marcelo nunes
@version P12
@Since	12/04/13
@obs Seleciona todas as naturezas de operacao cadastradas no SARA e preenche o array que sera utilizado na view
/*/
Static Function SEL_AR_NAT()
   Local tTabNatur := GetNextAlias()

	cQuery := " SELECT NAT_ID, NAT_DESC FROM TAB_NATUREZA "
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabNatur, .F., .T.)

    //Carga combo Pais
	While (tTabNatur)->(!Eof())
	   aAdd(a_NAT_ID,CVALTOCHAR((tTabNatur)->NAT_ID)+"="+AllTrim((tTabNatur)->NAT_DESC))
  	   (tTabNatur)->(dbSkip())
	EndDo
	(tTabNatur)->(DbCloseArea())
Return .T.

/*/{Protheus.doc} SEL_AR_OPE
@author Marcelo nunes
@version P12
@Since	12/04/13
@obs Seleciona todas operacoes cadastradas no SARA e preenche o array que sera utilizado na view
/*/
Static Function SEL_AR_OPE()
   Local tTabOperac := GetNextAlias()

	cQuery := " SELECT OP_ID, OP_DESCRICAO FROM TAB_OPERACAO "
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabOperac, .F., .T.)

    //Carga combo Pais
	While (tTabOperac)->(!Eof())
	   aAdd(a_OPE_ID,CVALTOCHAR((tTabOperac)->OP_ID)+"="+AllTrim((tTabOperac)->OP_DESCRICAO))
  	   (tTabOperac)->(dbSkip())
	EndDo
	(tTabOperac)->(DbCloseArea())
Return .T.


/*/{Protheus.doc} SEL_AR_TES
@author Marcelo nunes
@version P12
@Since	12/04/13
@obs preenche o array do tipo de documentos. (sera utilizado na view)
/*/
Static Function SEL_AR_TES()
   a_TPO_ES := {'','1=1','2=2'}
   //aAdd(a_TPO_ES,'E=ENTRADA')
   //aAdd(a_TPO_ES,'S=SAÍDA')
Return .T.

//-----------------------------------
/*{Protheus.doc}
Preenche array ano

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs preenche o array com os ultimos 6 anos. (sera utilizado na view)
*/
//-----------------------------------
Static Function SEL_AR_ANO()
	If Len(a_ANO_DC) == 1
   aAdd(a_ANO_DC,CValToChar(YEAR(DATE())  )+"="+CValToChar(YEAR(DATE())  ))
   aAdd(a_ANO_DC,CValToChar(YEAR(DATE())-1)+"="+CValToChar(YEAR(DATE())-1))
   aAdd(a_ANO_DC,CValToChar(YEAR(DATE())-2)+"="+CValToChar(YEAR(DATE())-2))
   aAdd(a_ANO_DC,CValToChar(YEAR(DATE())-3)+"="+CValToChar(YEAR(DATE())-3))
   aAdd(a_ANO_DC,CValToChar(YEAR(DATE())-4)+"="+CValToChar(YEAR(DATE())-4))
   aAdd(a_ANO_DC,CValToChar(YEAR(DATE())-5)+"="+CValToChar(YEAR(DATE())-5))
	EndIf
Return .T.


//-----------------------------------
/*{Protheus.doc}
Preenche array procedencia

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Seleciona todas as procedencias cadastradas no SARA e preenche o array que sera utilizado na view
*/
//-----------------------------------
Static Function CAR_BEN()
	//Local oModel    := FWModelActive()
	//Local oModelDOC := oModel:GetModel('PRAA802')
	//Local result := alltrim(oModelDOC:GetValue('DOC_NUM_DC'))
	Local cSql  := ''
	Local cQryCli := GetNextAlias()

	/*
	cQuery := " SELECT b.cli_nome, a.cli_id_acesso_info from vw_portal_permissao_acesso a left join tab_clientes b on b.cli_id = a.cli_id_acesso_info where a.mnu_id = '" + SuperGetMV("MV_SARAMAO",.T., "A") + "'"

	IF alltrim(cEmpPai) <> '999999'
		cQuery += " and usu_id = c " + alltrim(SCodUsr())
	endif
	*/
	    cSql := "   		select convert(varchar(6),a.cli_id) as cli_id,convert(varchar(32),a.cli_nome) as cli_nome,convert(varchar(15),a.cli_cgc) as cli_cgc "
		cSql += "			from tab_clientes a                    "
		cSql += "			  inner join rel_tipo_cliente b  "
		cSql += "			    on a.cli_id = b.cli_id  "
		cSql += "			where b.tcli_id = 1    "

      	if cEmpPai <> SGetTerm()
			cSql += " and exists (select 1            "
            cSql += " from vw_portal_permissao_acesso "
            cSql += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "' and mnu_id = 'A'"
            cSql += " and cli_id_acesso_info = a.cli_id) "
	  	endif

	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cSql),cQryCli, .F., .T.)


	While (cQryCli)->(!Eof())
	   aAdd(a_BEN,alltrim((cQryCli)->cli_id)+"="+AllTrim((cQryCli)->cli_nome))
  	   (cQryCli)->(dbSkip())
	EndDo
	(cQryCli)->(DbCloseArea())
Return .T.


//-----------------------------------
/*{Protheus.doc}
Preenche array procedencia

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Seleciona todas as procedencias cadastradas no SARA e preenche o array que sera utilizado na view
*/
//-----------------------------------
Function SEL_AR_PRO()
   Local tTabProced := GetNextAlias()

	cQuery := " SELECT PROC_ID, PROC_NOME FROM TAB_PROCEDENCIA"
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabProced, .F., .T.)

	While (tTabProced)->(!Eof())
	   aAdd(a_PRC_DC,CVALTOCHAR((tTabProced)->PROC_ID)+"="+AllTrim((tTabProced)->PROC_NOME))
  	   (tTabProced)->(dbSkip())
	EndDo
	(tTabProced)->(DbCloseArea())
Return .T.

static function A802RESEX()
	Local oModel    := FWModelActive()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local oModelCNT := oModel:GetModel('PRAA802CNT')
	Local oModelITC := oModel:GetModel('PRAA802ITC')
	Local lResult := ''
	Local nI := 0

			For nI := 1 To oModelDOC:Length()
		      	  if (.not. oModelDOC:isdeleted()) .and. (alltrim(oModelDOC:getvalue('DOC_RES_NU')) <> '' )
				     lResult += 'Recebim. c. solta '
				     nI := oModelDOC:Length()
			      endif
		    next nI

		    For nI := 1 To oModelITC:Length()
		      	  if .not. oModelITC:isdeleted() .and. (alltrim(oModelITC:getvalue('ITC_RES_NU')) <> '' )
		      	  	 if lResult = ''
		      	  	 	lResult += 'Carreg. c. solta '
		      	  	 else
				    	lResult += ' / Carreg. c. solta '
				    endif
				    nI := oModelITC:Length()
			      endif
		    next nI

		    For nI := 1 To oModelCNT:Length()
		      	  if .not. oModelCNT:isdeleted();
		      	  	 .and. (alltrim(oModelCNT:getvalue('CNT_RES_NU')) <> '' )
				     if lResult = ''
		      	  	 	lResult += ' Container '
		      	  	 else
				    	lResult += ' / Container '
				    endif
				     nI := oModelCNT:Length()
			      endif
		    next nI

return lresult
//-----------------------------------
/*{Protheus.doc}
Validacao campo Motorista

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao realizada para o campo Motorista
*/
//-----------------------------------
Static Function VAL_CLIENTE(cModelo)
	Local oModel    := FWModelActive()
	Local oView    := FWViewActive()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local oModelCNT := oModel:GetModel('PRAA802CNT')
	Local oModelITC := oModel:GetModel('PRAA802ITC')
	Local oModelGEN := oModel:GetModel(cModelo)
	Local lResult := .T.
	Local tTabClient := GetNextAlias()
	Local nI := 0
	Local validaRES := ''         
	Local idCliente
	Local cli_cgc_tmp

    if 'PRAA802' = cModelo

   		   validaRES := A802RESEX()
		    
		   idCliente := PRAA802VerificaCli(AllTrim(oModelGEN:GetValue('TMP_CLI_CG')))
		    
		   IF AllTrim(oModelGEN:GetValue('TMP_CLI_CG')) <> ''
		      //cQuery := " SELECT CLI_NOME, cli_cgc FROM TAB_CLIENTES WHERE CLI_ID = '"+alltrim(oModelTMP:GetValue('TMP_CLI_ID'))+"'"

			    cQuery := "   		select a.cli_id,a.cli_cgc,a.cli_nome  "
				cQuery += "			from tab_clientes a                   "
				cQuery += "			  inner join rel_tipo_cliente b  "
				cQuery += "			    on a.cli_id = b.cli_id  "
				cQuery += "			where b.tcli_id = 1    "


		      	if cEmpPai <> SGetTerm()
					cQuery += " and exists (select 1            "
		            cQuery += " from vw_portal_permissao_acesso "
		            cQuery += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "' and mnu_id = 'A'"
		            cQuery += " and cli_id_acesso_info = a.cli_id) "
			  	endif

			  cQuery += " and a.cli_cgc = '" + alltrim(oModelGEN:GetValue('TMP_CLI_CG')) + "'"
		      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabClient, .F., .T.)


		      IF AllTrim((tTabClient)->CLI_NOME) <> ''

				 oModelGEN:loadvalue('TMP_CLI_CG',alltrim((tTabClient)->CLI_CGC))  
		         oModelGEN:loadvalue('TMP_ORI_DS',alltrim((tTabClient)->CLI_NOME))
		         
		         If (tTabClient)->CLI_ID != oModelGEN:GetValue('TMP_CLI_ID')
		         	oModelGen:LoadValue('TMP_CLI_ID',AllTrim((tTabClient)->CLI_ID))
		         	 If !Empty(oView) .And. oView:lActivate
						oView:refresh()
					EndIf
		         EndIf
		         
		         if  oModelDOC:getvalue('DOC_TPO_DC') = 'NF' .and. alltrim(oModelDOC:getvalue('DOC_BEN_CG')) = ''
			         	oModelDOC:loadvalue('DOC_BEN_ID',alltrim( (tTabClient)->cli_id ))
			         	oModelDOC:loadvalue('DOC_BEN_CG',alltrim( (tTabClient)->cli_cgc ))
			         	oModelDOC:loadvalue('DOC_BEN',alltrim((tTabClient)->CLI_NOME))
//			         	oView:GetViewObj('PRAA802DOC')[3]:EvalWhen()
		         endif
		      Else 
		         //valida cnpj ou cpf informado
		         if(PRAA802ValidaCPFCNPJ(AllTrim(oModelGEN:GetValue('TMP_CLI_CG')),'') == .T.)
		         
			         if((idCliente == '') .or. (idCliente == nil))
			             if(MsgYesNo('O Cliente não foi encontrado no sistema.' + chr(13) + 'Deseja cadastrar?','Aviso'))
				              PRAA808A(AllTrim(oModelGEN:GetValue('TMP_CLI_CG')),'C','A')
				              
				              cli_cgc_tmp := AllTrim(oModelGEN:GetValue('TMP_CLI_CG'))
				              
				              oModelGEN:LoadValue('TMP_CLI_CG','')
				              oView:refresh()
				              
				              (tTabClient)->(DbCloseArea())
				              
				              cQuery := "   		select a.cli_id,a.cli_cgc,a.cli_nome  "
							  cQuery += "			from tab_clientes a                   "
							  cQuery += "			  inner join rel_tipo_cliente b  "
							  cQuery += "			    on a.cli_id = b.cli_id  "
							  cQuery += "			where b.tcli_id = 1    "
				
				
						      if cEmpPai <> SGetTerm()
									cQuery += " and exists (select 1            "
						            cQuery += " from vw_portal_permissao_acesso "
						            cQuery += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "' and mnu_id = 'A'"
						            cQuery += " and cli_id_acesso_info = a.cli_id) "
							  endif
				
							  cQuery += " and a.cli_cgc = '" + cli_cgc_tmp + "'"
						      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabClient, .F., .T.)
						      
						      oModelGEN:loadvalue('TMP_ORI_DS',(tTabClient)->cli_nome)
		                      oModelGEN:LoadValue('TMP_CLI_CG',(tTabClient)->cli_cgc)
					          
					          If (tTabClient)->CLI_ID != oModelGEN:GetValue('TMP_CLI_ID')
					          	oModelGen:LoadValue('TMP_CLI_ID',AllTrim((tTabClient)->CLI_ID))
					         	 If !Empty(oView) .And. oView:lActivate
									oView:refresh()
								EndIf
					          EndIf
					          if  oModelDOC:getvalue('DOC_TPO_DC') = 'NF' .and. alltrim(oModelDOC:getvalue('DOC_BEN_CG')) = ''
						         	oModelDOC:loadvalue('DOC_BEN_ID',alltrim( (tTabClient)->cli_id ))
						         	oModelDOC:loadvalue('DOC_BEN_CG',alltrim( (tTabClient)->cli_cgc ))
						         	oModelDOC:loadvalue('DOC_BEN',alltrim((tTabClient)->CLI_NOME))
			//			         	oView:GetViewObj('PRAA802DOC')[3]:EvalWhen()
					          endif
					          
					          oView:refresh()
					          lResult := .T.
					     else 
					         return .F.
				         endif
			         else
			      	   oModel:SetErrorMessage('PRAA802','TMP_CLI_ID','','','3000',"Usuário sem permissão de acesso ao cliente: " + alltrim(oModelGEN:GetValue('TMP_CLI_CG')) + " - " + AllTrim((tTabClient)->CLI_NOME),"Verifique as permissões e tente novamente.",nil,nil)
			           return .F.
			         endif
			     else 
			        return .F.
			     endif
		      EndIf
		      (tTabClient)->(DbCloseArea())
		   ELSE
		    
		      oModelGEN:setvalue('TMP_ORI_DS','')
		      oModelGEN:setvalue('TMP_CLI_CG','')
		   EndIf


		   if validaRES <> ''
					   		  msginfo('Atenção. O campo Reserva deve ser atualizado no(s) grid(s): ' + alltrim(validaRES) + '.')
					   		  For nI := 1 To oModelDOC:Length()
								   oModelDOC:GoLine(nI)
								   oModelDOC:loadvalue('DOC_RES_ID','')
							       oModelDOC:loadvalue('DOC_RES_NU','')
								next nI
//								oView:GetViewObj('PRAA802DOC')[3]:EvalWhen()
								For nI := 1 To oModelCNT:Length()
									   oModelCNT:GoLine(nI)
									   oModelCNT:loadvalue('CNT_RES_ID','')
								       oModelCNT:loadvalue('CNT_RES_NU','')
								next nI
//								oView:GetViewObj('PRAA802CNT')[3]:EvalWhen()
								For nI := 1 To oModelITC:Length()
									   oModelITC:GoLine(nI)
									   oModelITC:loadvalue('ITC_RES_ID','')
								       oModelITC:loadvalue('ITC_RES_NU','')
								next nI
//								oView:GetViewObj('PRAA802ITC')[3]:EvalWhen()
			endif

	 elseif 'PRAA802DOC' = cModelo
		IF AllTrim(oModelGEN:GetValue('DOC_BEN_CG')) <> ''
		   cQuery := "   		select a.cli_id,a.cli_cgc,a.cli_nome  "
			cQuery += "			from tab_clientes a                    "
			cQuery += "			  inner join rel_tipo_cliente b  "
			cQuery += "			    on a.cli_id = b.cli_id  "
			cQuery += "			where b.tcli_id = 1    "


	      	if cEmpPai <> SGetTerm()
				cQuery += " and exists (select 1            "
	            cQuery += " from vw_portal_permissao_acesso "
	            cQuery += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "' and mnu_id = 'A'"
	            cQuery += " and cli_id_acesso_info = a.cli_id) "
		  	endif

		  cQuery += " and a.cli_cgc = '" + alltrim(oModelGEN:GetValue('DOC_BEN_CG'))+"'"

	      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabClient, .F., .T.)
	      IF AllTrim((tTabClient)->cli_nome) <> ''
	         oModelGEN:loadvalue('DOC_BEN',alltrim((tTabClient)->cli_nome))
	         oModelGEN:loadvalue('DOC_BEN_ID',alltrim((tTabClient)->cli_id))
	         oModelGEN:loadvalue('DOC_BEN_CG',alltrim((tTabClient)->cli_cgc))
	      Else
	         //valida cnpj ou cpf informado
		     if(PRAA802ValidaCPFCNPJ(AllTrim(oModelGEN:GetValue('TMP_CLI_CG')),'') == .T.)
		         if(MsgYesNo('Deseja cadastrar o cliente?','Aviso'))
		              PRAA808A(alltrim(oModelGEN:GetValue('TMP_CLI_CG')),'C','A')
		              (tTabClient)->(DbCloseArea())
		              
		              cQuery := "   		select a.cli_id,a.cli_cgc,a.cli_nome  "
					  cQuery += "			from tab_clientes a                    "
					  cQuery += "			  inner join rel_tipo_cliente b  "
					  cQuery += "			    on a.cli_id = b.cli_id  "
					  cQuery += "			where b.tcli_id = 1    "
		
		
			      	  if cEmpPai <> SGetTerm()
						  cQuery += " and exists (select 1            "
			              cQuery += " from vw_portal_permissao_acesso "
			              cQuery += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "' and mnu_id = 'A'"
			              cQuery += " and cli_id_acesso_info = a.cli_id) "
				  	  endif
		
				      cQuery += " and a.cli_cgc = '" + alltrim(oModelGEN:GetValue('DOC_BEN_CG'))+"'"
				              
		              dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabClient, .F., .T.)
				      IF AllTrim((tTabClient)->cli_nome) <> ''
				         oModelGEN:loadvalue('DOC_BEN',alltrim((tTabClient)->cli_nome))
				         oModelGEN:loadvalue('DOC_BEN_ID',alltrim((tTabClient)->cli_id))
				         oModelGEN:loadvalue('DOC_BEN_CG',alltrim((tTabClient)->cli_cgc))
				
				         lResult := .T.
				      Else
				          lResult := .F.
				      endif
			     else
		              return .F.
		         endif
		         
		         lResult := .F.
		     else 
		        return .F.
	         endif
	      EndIf
	      (tTabClient)->(DbCloseArea())
	   ELSE
	      oModelGEN:loadvalue('DOC_BEN','')
	      oModelGEN:loadvalue('DOC_BEN_ID','')
	      oModelGEN:loadvalue('DOC_BEN_CG','')
	      lResult := .T.
	   EndIf
	endif

//	oView:GetViewObj(cModelo)[3]:EvalWhen()

Return lResult

//-----------------------------------
/*{Protheus.doc}
Validacao campo Motorista

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao realizada para o campo Motorista
*/
//-----------------------------------
Static Function VAL_PES_ID()
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:GetModel('PRAA802')
	Local lResult := .T.
	Local tTabPessoa := GetNextAlias()

    IF AllTrim(oModelTMP:GetValue('TMP_PES_CG')) <> ''
      cQuery := ' select pes_id, pes_nome, pes_rg, pes_cpf, pes_cnh, pes_dt_cnh, pes_rg_uf, ustipo_descricao  from tab_pessoas, tab_usuario_tipo  where pes_id <> 0    and pes_funcao = ustipo_id '
      cQuery += " and pes_cpf = '" +    AllTrim(StrTran(StrTran(StrTran(oModelTMP:GetValue('TMP_PES_CG'),".",""),"-",""),"/","")) + "'"
      if cTipoModal == 'A'
         cQuery := cQuery +  ' and pes_funcao = 8'
      ELSE
      //   cQuery += "    AND B.USTIPO_DESCRICAO = 'COMANDANTE'"
      EndIf

      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabPessoa, .F., .T.)
      IF AllTrim((tTabPessoa)->PES_NOME) <> ''
         oModelTMP:setvalue('TMP_PES_DS',(tTabPessoa)->PES_NOME)
         oModelTMP:setvalue('TMP_PES_ID',allTrim(cValToChar((tTabPessoa)->pes_id)))
      Else
          if(PRAA802ValidaCPFCNPJ(AllTrim(oModelTMP:GetValue('TMP_PES_CG')),'M') == .T.)
			  if(MsgYesNo('O motorista não foi encontrado no sistema.' + chr(13) + 'Deseja cadastrar?','Aviso'))
				   PRAA808B(AllTrim(oModelTMP:GetValue('TMP_PES_CG')),cTipoModal)
				   (tTabPessoa)->(dbClosearea())
				   
				    cQuery := ' select pes_id, pes_nome, pes_rg, pes_cpf, pes_cnh, pes_dt_cnh, pes_rg_uf, ustipo_descricao  from tab_pessoas, tab_usuario_tipo  where pes_id <> 0    and pes_funcao = ustipo_id '
			        cQuery += " and pes_cpf = '" +    AllTrim(StrTran(StrTran(StrTran(oModelTMP:GetValue('TMP_PES_CG'),".",""),"-",""),"/","")) + "'"
			        if cTipoModal == 'A'
			            cQuery := cQuery +  ' and pes_funcao = 8'
			        ELSE
			            //   cQuery += "    AND B.USTIPO_DESCRICAO = 'COMANDANTE'"
			        EndIf
				   
				    dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabPessoa, .F., .T.)
				    IF AllTrim((tTabPessoa)->PES_NOME) <> ''
					   oModelTMP:setvalue('TMP_PES_DS',(tTabPessoa)->PES_NOME)
					   oModelTMP:setvalue('TMP_PES_ID',allTrim(cValToChar((tTabPessoa)->pes_id)))
					   lResult := .T.
					Else
						lResult := .F.
					EndIf
			  else
			      return .F.
			  endif
		  else 
		     return .F.
          endif
      EndIf
      (tTabPessoa)->(DbCloseArea())
   ELSE
      oModelTMP:setvalue('TMP_PES_DS','')
      oModelTMP:setvalue('TMP_PES_ID','')
   EndIf
Return lResult

//-----------------------------------
/*{Protheus.doc}
Validacao campo Evento

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao realizada para o campo Evento
*/
//-----------------------------------
Static Function VAL_EVE_ID()
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:GetModel('PRAA802')
	Local lResult := .T.
	Local tTabEvento := GetNextAlias()
	Local Modal := ''

   if cTipomodal == 'V'
      Modal := 'R'
   else
      Modal := cTipomodal
   EndIf
   IF AllTrim(oModelTMP:GetValue('TMP_EVE_ID')) <> ''
      IF AllTrim(oModelTMP:GetValue('TMP_REC_ID')) <> ''
         cQuery := " SELECT A.EVE_DESC "
         cQuery += " FROM TAB_AGEN_EVENTOS A,REL_USUARIO_RECINTO X, REL_USU_EVENTO Y "
         cQuery += " WHERE A.EVE_ID = "+oModelTMP:GetValue('TMP_EVE_ID')
         cQuery += " AND A.EVE_MODAL = '"+Modal+"'"
         cQuery += " AND X.REC_ID = "+oModelTMP:GetValue('TMP_REC_ID')
         cQuery += " AND X.USU_ID = '"+cUsuario+"'"
         cQuery += " AND Y.REL_ID = X.REL_ID "
         cQuery += " AND Y.EVE_ID = A.EVE_ID "

         dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabEvento, .F., .T.)
         IF AllTrim((tTabEvento)->EVE_DESC) <> ''
            oModelTMP:setvalue('TMP_EVE_DS',(tTabEvento)->EVE_DESC)
         Else
            lResult := .F.
         EndIf
         (tTabEvento)->(DbCloseArea())
      ELSE
         lResult := .F.
      EndIf
   ELSE
      oModelTMP:setvalue('TMP_EVE_DS','')
   EndIf
Return lResult

//-----------------------------------
/*{Protheus.doc}
Validacao campo Descricao Evento

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao realizada para o campo Descricao Evento
*/
//-----------------------------------
Static Function VAL_EVE_DS()
Local oModel    := FWModelActive()
Local oModelTMP := oModel:GetModel('PRAA802')
   //IF AllTrim(oModelTMP:GetValue('TMP_EVE_DS')) <> ''
      oModelTMP:setvalue('TMP_DT_EVE',Date())
      oModelTMP:setvalue('TMP_HR_EVE',SUBSTR(TIME(),1,5))
  // EndIf
Return .T.

//-----------------------------------
/*{Protheus.doc}
Validacao campo Transportadora

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao realizada para o campo Transportadora
*/
//-----------------------------------
Static Function VAL_TRA_ID()
	Local oView    := FWViewActive()
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:GetModel('PRAA802')
	Local lResult := .T.
	Local tTabTrans := GetNextAlias()
	Local cQuery := ""
	Local cCodTransp := AllTrim(oModelTMP:GetValue('TMP_TRA_CG'))
	Local cCodId := "5"
	Local idCliente

	idCliente := PRAA802VerificaCli(AllTrim(oModelTMP:GetValue('TMP_TRA_CG')))

    IF  cCodTransp <> ''
      If cTipoModal == 'F'
         cCodId := "12"
      ElseIf cTipoModal == 'V'
   	   	  cCodId := "5"
   	  ElseIf cTipoModal == 'M'
   	      cCodId := "14"
   	  ElseIf cTipoModal == 'A'
   	   	   cCodId := "11"
   	  EndIf
            
   	   	cQuery := " select d.trans_id,a.cli_nome, a.cli_cgc from tab_clientes a"
		cQuery += " inner join rel_tipo_cliente b on a.cli_id = b.cli_id"
		cQuery += " inner join tab_tipo_cliente c on b.tcli_id = c.tcli_id"
		cQuery += " inner join rel_trans_ben_com d on a.cli_id = d.ben_id"
		cQuery += " where c.tcli_id = " + cCodId
		cQuery += " and a.cli_cgc = '" + CCodTransp + "'"
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabTrans, .F., .T.)
		
		IF AllTrim((tTabTrans)->cli_nome) <> ''
            oModelTMP:loadvalue('TMP_TRA_DS',(tTabTrans)->cli_nome)
            oModelTMP:LoadValue('TMP_TRA_CG',(tTabTrans)->cli_cgc)
            oModelTMP:loadvalue('TMP_TRA_ID',allTrim(cValToChar((tTabTrans)->trans_id)))
            
            lResult := .T.
       Else
         if (PRAA802TipoCli(AllTrim(oModelTMP:GetValue('TMP_TRA_CG'))) != nil) .and.;
            (PRAA802TipoCli(AllTrim(oModelTMP:GetValue('TMP_TRA_CG'))) != 5)
		   
		   MsgStop("O CPF ou CNPJ informado não está cadastrado como transportador rodoviário.") 
		   
		   oModelTMP:LoadValue('TMP_TRA_CG','')
		   oView:Refresh()
		   
		   return .F.
		
         elseif(PRAA802ValidaCPFCNPJ(AllTrim(oModelTMP:GetValue('TMP_TRA_CG')),'') == .T.)
             if((idCliente == '') .or. (idCliente == nil))
		         if(msgyesno('A transportadora não foi encontrado no sistema.'+chr(13)+'Deseja cadastrar?','Aviso'))
		            
		              PRAA808A(AllTrim(oModelTMP:GetValue('TMP_TRA_CG')),'T','A')
		              
		              oModelTMP:LoadValue('TMP_TRA_CG','')
		              oView:Refresh()
		              
		              (tTabTrans)->(DbCloseArea())
		              
		              cQuery := " select d.trans_id,a.cli_nome, a.cli_cgc from tab_clientes a"
					  cQuery += " inner join rel_tipo_cliente b on a.cli_id = b.cli_id"
					  cQuery += " inner join tab_tipo_cliente c on b.tcli_id = c.tcli_id"
				  	  cQuery += " inner join rel_trans_ben_com d on a.cli_id = d.ben_id"
					  cQuery += " where c.tcli_id = " + cCodId
					  cQuery += " and a.cli_cgc = '" + CCodTransp + "'"
					  dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabTrans, .F., .T.)
		
		              oModelTMP:loadvalue('TMP_TRA_DS',(tTabTrans)->cli_nome)
		              oModelTMP:LoadValue('TMP_TRA_CG',(tTabTrans)->cli_cgc)
                      oModelTMP:loadvalue('TMP_TRA_ID',allTrim(cValToChar((tTabTrans)->trans_id))) 
                      
                      oView:Refresh()
                      
		              lResult := .T.
		         else
		            oModelTMP:LoadValue('TMP_TRA_CG','')
		            oView:Refresh()
		            lResult := .F.
		         endif
		      
			 endif
	     else 
	        oModelTMP:loadvalue('TMP_TRA_CG','')
	        oView:Refresh()
	        return .F.
         endif
       EndIf
      (tTabTrans)->(DbCloseArea())
   ELSE
      oModelTMP:loadvalue('TMP_TRA_DS','')
      oModelTMP:loadvalue('TMP_TRA_ID','')
      oModelTMP:LoadValue('TMP_TRA_CG','')
	  oView:Refresh()  
   EndIf
Return lResult

//-----------------------------------
/*{Protheus.doc}
Validacao campo Origem da carga

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao realizada para o campo Origem da carga
*/
//-----------------------------------
Static Function VAL_ORI_ID()
   Local oModel    := FWModelActive()
   Local oModelTMP := oModel:GetModel('PRAA802')
   Local lResult := .T.
   Local tTabClient := GetNextAlias()
   IF AllTrim(oModelTMP:GetValue('TMP_CLI_RE')) <> ''
      cQuery := " SELECT CLI_NOME FROM TAB_CLIENTES WHERE CLI_ID = '"+oModelTMP:GetValue('TMP_CLI_RE')+"'"
      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabClient, .F., .T.)
      IF AllTrim((tTabClient)->CLI_NOME) <> ''
         oModelTMP:setvalue('TMP_ORI_DS',(tTabClient)->CLI_NOME)
      Else
         lResult := .F.
      EndIf
      (tTabClient)->(DbCloseArea())
   ELSE
      oModelTMP:setvalue('TMP_ORI_DS','')
   EndIf
Return lResult

//-----------------------------------
/*{Protheus.doc}
Validacao campo Destino da carga

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao realizada para o campo Destino da carga
*/
//-----------------------------------
Static Function VAL_DES_ID()
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:GetModel('PRAA802')
	Local lResult := .T.
	Local tTabClient := GetNextAlias()
    IF AllTrim(oModelTMP:GetValue('TMP_DES_ID')) <> ''
      cQuery := " SELECT CLI_NOME FROM TAB_CLIENTES WHERE CLI_ID = '"+oModelTMP:GetValue('TMP_DES_ID')+"'"
      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabClient, .F., .T.)
      IF AllTrim((tTabClient)->CLI_NOME) <> ''
         oModelTMP:setvalue('TMP_DES_DS',(tTabClient)->CLI_NOME)
      Else
         lResult := .F.
      EndIf
      (tTabClient)->(DbCloseArea())
   ELSE
      oModelTMP:setvalue('TMP_DES_DS','')
   EndIf
Return lResult

/*/{Protheus.doc} A802VeiBloqueado
	(long_description)
	Verifica se o veículo esta bloqueado ou não
	@type  Function
	@author MOHAMED S B DJALO
	@since 25/07/2022
	@version version
	@param PlacaVeiculo, param_type, param_descr
	@return lReturn, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function A802VeiBloqueado(PlacaVeiculo)
	Local lReturn := .T.	
	Local tabVeic := GetNextAlias()

    cQuery := "select                                   "
	cQuery += " vb_data_bloqueio as sai_dt_bloqueio,    "
	cQuery += "	vb_operacao as sai_operacao,            "
	cQuery += "	vb_motivo as sai_motivo,                "
	cQuery += "	vb_responsavel as sai_responsavel,      " 
	cQuery += "	vb_data_desbloqueio as dt_desbloqueio,  "
	cQuery += "	vb_acao as sai_acao,                    "
	cQuery += "	case when (vb_data_desbloqueio is null) " 
	cQuery += "		then 1                              "
	cQuery += "		else 0                              "
	cQuery += "	end as sai_bloqueado		            "
	cQuery += " from tab_veiculos_bloqueio              "
	cQuery += "		where vei_id = '"+AllTrim(PlacaVeiculo)+"'"
	cQuery += "		and vb_ordem = (                    "
	cQuery += "			select max(vb_ordem)            " 
	cQuery += "			from tab_veiculos_bloqueio      " 
	cQuery += "			where vei_id = '"+AllTrim(PlacaVeiculo)+"'"
	cQuery += "		)                                   "

	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tabVeic, .F., .T.)
    
	if(((tabVeic)->sai_bloqueado == 1) .and. ((tabVeic)->sai_operacao == 0))
		if ((tabVeic)->sai_acao == 0 )
			lReturn := .F.
		ENDIF
	ENDIF

	(tabVeic)->(DbCloseArea())
	
Return lReturn

//-----------------------------------
/*{Protheus.doc}
Validacao campo Veiculo

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao realizada para o campo Veiculo
*/
//-----------------------------------
Static Function VAL_VEI_ID()
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:GetModel('PRAA802')
	Local lResult := .T.
	Local tTabVei := GetNextAlias()
	Local tTabVei2 := GetNextAlias()
	Local Tipo := "5"
	Local cIdVeic := AllTrim(oModelTMP:GetValue('TMP_VEI_ID'))
	Local ntara := 0
	Local nmarca := nil
	Local nmodel := nil
	Local cMsgErro := '' 
	
    IF cIdVeic <> ''

        	//valida o valor digitado    

			If(IsNumeric(substr(cIdVeic,1,1))) .Or. (IsNumeric(substr(cIdVeic,2,1))) .Or. (IsNumeric(substr(cIdVeic,3,1)))
				lResult := .F.
				cMsgErro := 'Os três primeiros digitos da placa devem ser letras! '
			Else 
				If (cModal == 'V')
					If (len(cIdVeic) < 7) .Or. (len(cIdVeic) > 7)
						cMsgErro := 'Para veículo rodoviário, a placa deve possuir sete digitos! '
						lResult := .F.
					EndIf
				EndIf
				
				If (cModal == 'F')
					If (len(cIdVeic) < 10)
						cMsgErro := 'Para veículo ferroviário, a placa deve possuir no minimo dez digitos! ' 
						lResult := .F.
					EndIf
				EndIf
			EndIf
			
			If (cMsgErro <> '')
				oModel:SetErrorMessage('PRAA802', 'TMP_VEI_ID',,,,cMsgErro)
				cMsgErro := ''
			EndIf  
			
			If lResult
				If cTipoModal == "F" // Validação exclusiva do veículo para modal ferroviario
					If !A802VALDG(cIdVeic)[1]
						lResult := .F.
						oModel:SetErrorMessage('PRAA802', 'TMP_VEI_ID',,,,"O digito verificador incorreto."+CRLF+"O correto é " + cValToChar(A802VALDG(cIdVeic)[2]))
						Return lResult
					EndIf
		
					cQuery := "select vei_id from tab_veiculos where vei_id = '" + cIdVeic + "'"
					dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabVei, .F., .T.)
					(tTabVei)->(dbGotop())
					If (tTabVei)->(Eof()) .Or. Empty((tTabVei)->vei_id)
						lResult := MsgYesNo("Vagão não está cadastrado, deseja cadastrá-lo?")
						If !lResult
							oModelTMP:LoadValue('TMP_VEI_ID','')
							(tTabVei)->(dbCloseArea())
							Return .T.
						EndIf
						nTara := A802TaraVag(cIdVeic)
						nTara := StrTran(cValToChar(nTara),",",".")
						nmarca := cValToChar(A802MarVag(cIdVeic))
						nmodel := cValToChar(A802ModVag(cIdVeic))
						cQuery := " insert tab_veiculos(vei_id,modelo_id,marca_id,vei_status,vei_tara,tipo_id,vei_frota,vei_modal) "
						cQuery += "              values('"+cIdVeic+"',"+If(Empty(nmodel),"null",nmodel)+","+If(Empty(nmarca),"null",nmarca)+",0,"+If(Empty(nTara),"null",nTara)
						cQuery += "              ,( select tipo_id from tab_tipo_veiculo where tipo_descricao = 'LOCOMOTIVA/VAGAO'),0,'F')"
						IF (TcSqlExec(cQuery)< 0)
					oModel:SetErrorMessage('PRAA802', 'TMP_VEI_ID',,,,STR0122+Chr(13)+AllTrim(TCSQLError()))
					Return .F.
					EndIF
		
						Return .T.
					Else
						(tTabVei)->(dbCloseArea())
						Return .T.
					EndIf
			EndIf // Validação exclusiva do veículo para modal ferroviario

			cQuery := " SELECT VEI_ID,TIPO_ID "
			cQuery += " FROM TAB_VEICULOS "
			cQuery += " WHERE VEI_ID = '"+RTRIM(oModelTMP:GetValue('TMP_VEI_ID'))+"'"
			cQuery += "   AND VEI_MODAL = '"+cTipomodal+"'"
			dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabVei, .F., .T.)
		
			IF AllTrim((tTabVei)->VEI_ID) == ''
				IF MsgYesNo(STR0119+Chr(13)+STR0120,STR0121)
					IF cTipomodal == 'A'
					Tipo := '11'
					EndIf
		
					IF cTipomodal == 'V'
					Tipo := '5'
					EndIf
					IF (TcSqlExec("INSERT INTO TAB_VEICULOS (VEI_ID, VEI_MODELO, VEI_MARCA, VEI_STATUS, VEI_FROTA, TIPO_ID, VEI_MODAL) VALUES ('"+AllTrim(oModelTMP:GetValue('TMP_VEI_ID'))+"','OUTROS','OUTROS',0,0,"+Tipo+",'"+cTipomodal+"')")< 0)
					oModel:SetErrorMessage('PRAA802', 'TMP_VEI_ID',,,,STR0122+Chr(13)+AllTrim(TCSQLError()))
					lResult := .F.
					EndIF
				ELSE
					lResult := .F.
				EndIf
			Else
				IF (tTabVei)->TIPO_ID = 8
					lResult := .F.
				EndIf
			EndIf
			(tTabVei)->(DbCloseArea())
		
			if alltrim(oModelTMP:GetValue('TMP_VEI_ID')) <> ''
				cQuery := '	select a.cesv_id,a.trans_id, a.pes_id, b.trans_cgc, b.trans_nome, c.pes_cpf, c.pes_nome from tab_cesv a '
				cQuery +=		  '			left join tab_transportadora b '
				cQuery +=			  '				on b.trans_id = a.trans_id '
				cQuery +=			 '			left join tab_pessoas c '
				cQuery +=		 '			on c.pes_id = a.pes_id '
				cQuery +=		 "		where a.vei_id = '" + alltrim(oModelTMP:GetValue('TMP_VEI_ID')) + "'"
				cquery += ' order by  a.cesv_dt_saida desc '
		
				dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabVei2, .F., .T.)
				dbselectarea(tTabVei2)
		
				if alltrim((tTabVei2)->trans_nome) <> ''
					IF MsgYesNo('Deseja utilizar a transportadora ' + alltrim((tTabVei2)->trans_nome) + ' e o motorista ' + alltrim((tTabVei2)->pes_nome) + '?')
						oModelTMP:loadvalue('TMP_TRA_ID',alltrim(str((tTabVei2)->trans_id)))
						oModelTMP:loadvalue('TMP_TRA_CG',alltrim((tTabVei2)->trans_cgc))
						oModelTMP:loadvalue('TMP_TRA_DS',alltrim((tTabVei2)->trans_nome))
						oModelTMP:loadvalue('TMP_PES_ID',alltrim(str((tTabVei2)->pes_id)))
						oModelTMP:loadvalue('TMP_PES_CG',alltrim((tTabVei2)->pes_cpf))
						oModelTMP:loadvalue('TMP_PES_DS',alltrim((tTabVei2)->pes_nome))
					endif
				endif
			endif
      EndIf 
    EndIf
Return lResult

//-----------------------------------
/*{Protheus.doc}
Validacao campo Veiculo relacionado

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao realizada para o campo Veiculo relacionado
*/
//-----------------------------------
Static Function VAL_VEI_RE()
	Local lResult := .T.
	Local oModel    := FWModelActive()
	Local oModelTMP := oModel:GetModel('PRAA802')
	Local tTabSubope := GetNextAlias()
	Local tTabModulo := GetNextAlias()
	Local tTabProMar := GetNextAlias()
	Local tTabProgra := GetNextAlias()
	Local cUsaMaritimo
	Local cModalRel
    If RTRIM(oModelTMP:GetValue('TMP_VEI_RE')) <> ''
      If ((AllTrim(oModelTMP:GetValue('TMP_SUB_ID')) <> '') .AND. (AllTrim(oModelTMP:GetValue('TMP_REC_ID')) <> ''))
         cQuery := " SELECT CAST(MOD_LIBERADO AS VARCHAR(1)) AS MOD_LIBERADO FROM TAB_MODULO WHERE MOD_ID = 'SARA_MAR'"
         dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabModulo, .F., .T.)
         cUsaMaritimo := AllTrim((tTabModulo)->MOD_LIBERADO)
         (tTabModulo)->(DbCloseArea())

         cQuery := " SELECT REL_CESV_MODAL FROM TAB_SUB_OPERACAO WHERE SUB_ID = "+oModelTMP:GetValue('TMP_SUB_ID')
         dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabSubope, .F., .T.)
         cModalRel := AllTrim((tTabSubope)->REL_CESV_MODAL)
         (tTabSubope)->(DbCloseArea())

         IF ((cUsaMaritimo == '1') .AND. (cModalRel == 'M'))
            cQuery := " SELECT A.VEI_ID FROM TAB_PROG_MARITIMA P "
            cQuery += " LEFT OUTER JOIN TAB_CESV B ON (P.CESV_ID = B.CESV_ID), "
            cQuery += " TAB_VIAGEM A "
            cQuery += " LEFT OUTER JOIN TAB_NAVIOS C ON (A.VEI_ID = C.NAV_ID) "
            cQuery += " WHERE B.CESV_DT_SAIDA IS NULL "
            cQuery += "   AND B.CESV_CANCELADA IS NULL "
            cQuery += "   AND A.VGM_ID = P.VGM_ID "
            cQuery += "   AND A.REC_ID  = "+AllTrim(oModelTMP:GetValue('TMP_REC_ID'))
            cQuery += "   AND A.VEI_ID  = '"+RTRIM(oModelTMP:GetValue('TMP_VEI_RE'))+"'"
            dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabProMar, .F., .T.)
            IF RTRIM((tTabProMar)->VEI_ID) == ''
               lResult := .F.
            EndIf
            (tTabProMar)->(DbCloseArea())
         ELSE
            cQuery := " SELECT A.VEI_ID FROM TAB_CESV  A, "
            cQuery += " REL_CESV_RECINTOS B "
            cQuery += " WHERE SUBSTRING(A.CESV_ID,5,1) = '"+cModalRel+"'"
            cQuery += "   AND A.CESV_DT_SAIDA IS NULL "
            cQuery += "   AND A.CESV_CANCELADA IS NULL  "
            cQuery += "   AND A.CESV_ID = B.CESV_ID "
            cQuery += "   AND B.REC_ID  = "+AllTrim(oModelTMP:GetValue('TMP_REC_ID'))
            cQuery += "   AND A.VEI_ID  = '"+RTRIM(oModelTMP:GetValue('TMP_VEI_RE'))+"'"
            dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabProgra, .F., .T.)
            IF RTRIM((tTabProgra)->VEI_ID) == ''
               lResult := .F.
            EndIf
            (tTabProgra)->(DbCloseArea())
         EndIf
      ELSE
         lResult := .F.
      EndIf
   EndIf
Return lResult

//-----------------------------------
/*{Protheus.doc}
Validacao campo Reboque

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao realizada para o campo Reboque
*/
//-----------------------------------
Static Function VAL_REB_ID()
	Local oModel    := FWModelActive()
	Local oModelREB := oModel:GetModel('PRAA802REB')
	Local lResult := .T.
	Local tTabVei := GetNextAlias()

    IF cTipoModal == 'V' .And. AllTrim(oModelREB:GetValue('REB_REB_ID')) <> ''
      cQuery := " SELECT VEI_ID,TIPO_ID "
      cQuery += " FROM TAB_VEICULOS "
      cQuery += " WHERE VEI_ID = '"+RTRIM(oModelREB:GetValue('REB_REB_ID'))+"'"
      cQuery += "   AND VEI_MODAL = '"+cTipomodal+"'"
      //cQuery += "   AND TIPO_ID = 8 "
      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabVei, .F., .T.)

      IF AllTrim((tTabVei)->VEI_ID) == ''
         IF MsgYesNo(STR0119+Chr(13)+STR0120,STR0121)
            IF (TcSqlExec("INSERT INTO TAB_VEICULOS (VEI_ID, VEI_STATUS, VEI_FROTA, TIPO_ID, VEI_MODAL) VALUES ('"+RTRIM(oModelREB:GetValue('REB_REB_ID'))+"',0,0,8,'"+cTipomodal+"')")< 0)
               oModel:SetErrorMessage('PRAA802REB', 'REB_REB_ID',,,,STR0122+Chr(13)+AllTrim(TCSQLError()))
               lResult := .F.
		  	  EndIf
         ELSE
            lResult := .F.
         EndIf
      Else
         IF (tTabVei)->TIPO_ID <> 8
            lResult := .F.
         EndIf
      EndIf
      (tTabVei)->(DbCloseArea())
   EndIf
   DbSelectArea(cAliasTMP)
Return lResult

//-----------------------------------
/*{Protheus.doc}
Validacao campo Tipo documento (E/S)

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao realizada para o campo Tipo Documento(E/S)
*/
//-----------------------------------

Static Function VAL_TPO_ES()
	Local oModel    := FWModelActive()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local oModelTMP := oModel:GetModel('PRAA802')
	If !Empty(oModelTMP:GetValue('TMP_OPE_ID'))
		if cValToChar(Val(oModelTMP:GetValue('TMP_OPE_ID'))) = '1' .and. alltrim(oModelDOC:getvalue('DOC_TPO_ES')) = 'E'
			oModel:SetErrorMessage('PRAA802DOC','DOC_TPO_ES','','','3080', 'Para operação de carga o documento deve ser de saída.','Insira um documento de saída.',nil,nil)
			return .F.
		elseif cValToChar(Val(oModelTMP:GetValue('TMP_OPE_ID'))) = '2' .and. alltrim(oModelDOC:getvalue('DOC_TPO_ES')) = 'S'
			oModel:SetErrorMessage('PRAA802DOC','DOC_TPO_ES','','','3081', 'Para operação de descarga o documento deve ser de entrada.','Insira um documento de entrada.',nil,nil)
			return .F.
		endif
	EndIf

	A802DELREGS()

    oModelDOC:setvalue('DOC_DOC_ID','')
    oModelDOC:setvalue('DOC_TPO_DC','')
    oModelDOC:setvalue('DOC_NUM_DC','')
    oModelDOC:loadvalue('DOC_SER_DC','')
    oModelDOC:loadvalue('DOC_PRC_DC','')
//    oModelDOC:setvalue('DOC_RES_ID','')
    oModelDOC:setvalue('DOC_CFOP','.')
    oModelDOC:setvalue('DOC_CFOP_D','')
    if alltrim(oModelDOC:getvalue('DOC_TPO_DC')) = 'NF'
	    oModelDOC:loadvalue('DOC_BEN_ID','')
	    oModelDOC:loadvalue('DOC_BEN_CG','')
	    oModelDOC:loadvalue('DOC_BEN','')
    endif

//    oView:GetViewObj('PRAA802DOC')[3]:EvalWhen()
Return .T.

static function A802DELREGS()
	Local oModel    := FWModelActive()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local oModelITC := oModel:GetModel('PRAA802ITC')
	Local oModelITD := oModel:GetModel('PRAA802ITD')
	Local nI := 0


		    For nI := 1 To oModelITC:Length()
		         oModelITC:goline(nI)
		      	  if alltrim(oModelITC:getvalue('ITC_DP_DS')) =  alltrim(oModelDOC:getvalue('DOC_DOC_ID'))
					 oModelITC:loadvalue('ITC_DP_ID','')
				     oModelITC:loadvalue('ITC_DP_DS','')
			      endif
		    next nI

			For nI := 1 To oModelITD:Length()
		         oModelITD:goline(nI)
		      	  if alltrim(oModelITD:getvalue('ITD_DP_DS')) =  alltrim(oModelDOC:getvalue('DOC_DOC_ID'))
		      	     oModelITD:loadvalue('ITD_DP_ID','')
				     oModelITD:loadvalue('ITD_DP_DS','')
			      endif
		    next nI

//	oView:GetViewObj('PRAA802ITC')[3]:EvalWhen()
//	oView:GetViewObj('PRAA802ITD')[3]:EvalWhen()

return .T.

//-----------------------------------
/*{Protheus.doc}
Validacao campo Tipo Documento

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao realizada para o campo Tipo Documento
*/
//-----------------------------------
Static Function VAL_TPO_DC()
Local oModel    := FWModelActive()
Local oModelDOC := oModel:GetModel('PRAA802DOC')
Local oModelTMP := oModel:GetModel('PRAA802')
Local lResult := .T.
Local tTabDocum := GetNextAlias()
Local cDocTipo
   IF AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) <> ''
      IF AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) <> ''
         IF AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) == 'E'
            cDocTipo := '(1,3)'
         ELSE
            cDocTipo := '(2,3)'
         EndIf
         cQuery := " SELECT DOC_ID FROM TAB_DOCUMENTOS WHERE DOC_ID = '"+oModelDOC:GetValue('DOC_TPO_DC')+"' AND DOC_TIPO IN"+cDocTipo
         dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabDocum, .F., .T.)
         IF AllTrim((tTabDocum)->DOC_ID) == ''
            lResult := .F.
         EndIf
         (tTabDocum)->(DbCloseArea())

         if AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) = 'NF'
	     	oModelDOC:loadValue('DOC_BEN_ID',alltrim(oModelTMP:getvalue('TMP_CLI_ID')) )
	     	oModelDOC:loadValue('DOC_BEN_CG',alltrim(oModelTMP:getvalue('TMP_CLI_CG')) )
	     	oModelDOC:loadValue('DOC_BEN',alltrim(oModelTMP:getvalue('TMP_ORI_DS')) )
	     	oModelDOC:loadValue('DOC_PRC_DC','NAC')
//	     	oView:GetViewObj('PRAA802DOC')[3]:EvalWhen()
	     else
		    oModelDOC:loadValue('DOC_BEN_ID','')
		    oModelDOC:loadValue('DOC_BEN_CG','')
		    oModelDOC:loadValue('DOC_BEN','')
		    //oModelDOC:loadValue('DOC_PRC_DC','')
		    oModelDOC:loadValue('DOC_SER_DC','')
		    oModelDOC:setvalue('DOC_CFOP','.')
    		 oModelDOC:setvalue('DOC_CFOP_D','')
//	     	 oView:GetViewObj('PRAA802DOC')[3]:EvalWhen()
	     endif
	     oModelDOC:setValue('DOC_DOC_ID','')
	     A802DELREGS()
      Else
         lResult := .F.
      EndIf
   EndIf
   If Type("cAliasTMP") == "C" .And. !Empty(cAliasTMP)
   DbSelectArea(cAliasTMP)
   EndIf
Return lResult

//-----------------------------------
/*
{Protheus.doc}
Validacao se os numeros(quantidade) dos container estão corretos

@author Fernando da Cruz Pinheiro
@version P12
@Since	31/01/2014
@obs Validacao se os numeros(quantidade) dos container estão corretos
*/
//-----------------------------------
static function PST_VAL_DOC_NUM()
	Local oModel    := FWModelActive()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local lResult := .T.	

	IF AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = '' .or. AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) = ''
		//oModel:SetErrorMessage('PRAA802DOC', 'DOC_NUM_DC',,,'Defina se o documento é de entrada ou saída',)
		oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3082', STR0279,'',nil,nil)

		lResult := .F.
	else
	    IF (AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = 'S')			
			if (len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) > 9)
				oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3083', STR0281,'',nil,nil)
				lResult := .F.
			endif
		else
			if (UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF')
                 if (len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) > 13)
					oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3084', STR0282,'',nil,nil)
					lResult := .F.
				endif
			else
				if (len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) > 16)
					oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3085', STR0283,'',nil,nil)
					lResult := .F.
				endif
			endif
		endif
		
		If (alltrim(oModelDOC:getvalue('DOC_NUM_DC')) == '') .And. (alltrim(oModelDOC:getvalue('DOC_RES_NU')) <> '') .And. lResult
			oModel:SetErrorMessage('PRAA802',,,,'3086' ,'A reserva ' + alltrim(oModelDOC:getvalue('DOC_RES_NU')) + ' não possui documento relacionado.','Selecione o documento.', nil, nil)
			lResult := .F.
		endif	
	endif

	if lResult = .T.
		oModelDOC:setValue('DOC_DOC_ID','')
	endif

return lResult

//-----------------------------------
/*
{Protheus.doc}
Validacao se os numeros(quantidade) dos container estão corretos

@author Fernando da Cruz Pinheiro
@version P12
@Since	31/01/2014
@obs Validacao se os numeros(quantidade) dos container estão corretos
*/
//-----------------------------------
static function VAL_DOC_NUM()
	Local oModel    := FWModelActive()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local oModelTMP := oModel:GetModel('PRAA802')
	Local lResult   := .T.
	Local cAlsDOC   := GetNextAlias()
	Local cSqlDOC   := '' 
	
	if (cSubOpCntCheio == '')
		StaticCall(PRAA802,VAL_SUB_ID)      
    EndIf
	
	if (AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) <> '')
		if !(cSubOpCntCheio == '1') .And. !(cSubOpMercSolta == '1')
        		oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3087', 'Sub operação '+alltrim(oModelTMP:getvalue('TMP_SUB_DS'))+' permite apenas a operação com contêineres vazios.','',nil,nil)
        		cSubOpCntCheio  := ''
			    cSubOpCntVazio  := ''
			    cSubOpMercSolta := ''
        		lResult := .F.	
         endif
	endif 	

	IF (AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = '' .or. AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) = '') .And.;
	AllTrim(oModelDOC:GetValue('DOC_RES_NU')) = ''
		//oModel:SetErrorMessage('PRAA802DOC', 'DOC_NUM_DC',,,'Defina se o documento é de entrada ou saída',)
		oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3088', STR0279,'',nil,nil)
		lResult := .F.
	else
	    IF (AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = 'S')
			if (len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) > 9)
				oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3089', STR0281,'',nil,nil)
				lResult := .F.
			endif
		else
			if (UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF')
                 if (len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) > 13)
					oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3090', STR0282,'',nil,nil)
					lResult := .F.
				endif
			else
				if (len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) > 16)
					oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3091', STR0283,'',nil,nil)
					lResult := .F.
				endif
			endif
		endif
	endif
	
	if  (AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) == 'S')
		 cSqlDOC := SQLSel003TabDocSaida(alltrim(oModelDOC:getvalue('DOC_RES_ID')), AllTrim(oModelDOC:GetValue('DOC_NUM_DC')))
		 
		 dbUseArea(.T., 'TOPCONN', TCGenQry(,,cSqlDOC),cAlsDOC, .F., .T.)
		 IF (AllTrim((cAlsDOC)->cli_id) <> '')
			 oModelDOC:loadvalue('DOC_BEN',    AllTrim((cAlsDOC)->cli_nome))
			 oModelDOC:loadvalue('DOC_BEN_ID', AllTrim((cAlsDOC)->cli_id)  )
			 oModelDOC:loadvalue('DOC_BEN_CG', AllTrim((cAlsDOC)->cli_cgc) )
		 EndIf
		 
		 (cAlsDOC)->(dbCloseArea())
	 
	EndIf

	if lResult = .T.
		a802delregs()
		oModelDOC:setValue('DOC_DOC_ID','')
	endif

return lResult


//-----------------------------------
/*
{Protheus.doc}
Validacao se os numeros(quantidade) dos container estão corretos

@author Fernando da Cruz Pinheiro
@version P12
@Since	31/01/2014
@obs Validacao se os numeros(quantidade) dos container estão corretos
*/
//-----------------------------------
static function VAL_DOC2()
	Local oModel    := FWModelActive()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local lResult := ''

	IF AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = '' .or. AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) = ''
		//oModel:SetErrorMessage('PRAA802DOC', 'DOC_NUM_DC',,,'Defina se o documento é de entrada ou saída',)
		//oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3000', STR0279,'',nil,nil)

		lResult := 'ERROR' + STR0279 + " (DOC_NUM_DC)"
	else
	    IF (AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = 'S')
			if (UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF')
                 if (len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) > 9)
					//oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3000', STR0280,'',nil,nil)
					//lResult := .F.
					lResult := 'ERROR' + STR0280 + " (DOC_NUM_DC)"
				endif
			else
				if (len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) > 9)
					//oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3000', STR0281,'',nil,nil)
					//lResult := .F.
					lResult := 'ERROR' + STR0281 + " (DOC_NUM_DC)"
				endif
			endif
		else
			if (UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF')
                 if (len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) > 13)
					//oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3000', STR0282,'',nil,nil)
					//lResult := .F.
					lResult := 'ERROR' + STR0282 + " (DOC_NUM_DC)"
				endif
			else
				if (len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) > 16)
					//oModel:SetErrorMessage('PRAA802DOC','DOC_NUM_DC','','','3000', STR0283,'',nil,nil)
					//lResult := .F.
					lResult := 'ERROR' + STR0283 + " (DOC_NUM_DC)"
				endif
			endif
		endif
	endif

return lResult

//-----------------------------------
/*
{Protheus.doc}
Validacao campo Nr Documento

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Validacao realizada para o campo Nr Documento
*/
//-----------------------------------

Static Function VAL_NUM_DC()
	Local oModel    := FWModelActive()
	Local oModelDOC := oModel:GetModel('PRAA802DOC')
	Local result := alltrim(oModelDOC:GetValue('DOC_NUM_DC'))
    IF AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) <> ''
      IF AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) <> ''
         IF AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) == 'S'
            IF UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF'
	            IF Len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) < 9
	               result := STRZERO(0,9-Len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))))+AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))
	            EndIF
	        else
	            IF UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'DDE'
		            IF Len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) < 8
		               result := STRZERO(0,9-Len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))))+AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))
		            EndIF
	            Else 
		        	IF Len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) < 9
		               result := STRZERO(0,9-Len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))))+AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))
		            EndIf
		        EndIf
            endif
         ELSE
            IF UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF'
               IF Len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) < 13
                  result := STRZERO(0,13-Len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))))+AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))
               EndIF
            ELSE
               IF Len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) < 16
                  result := STRZERO(0,16-Len(AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))))+AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))
               EndIF
            EndIF
         EndIF
      ELSE
         result := 'ERROR'
      EndIF
   EndIF

Return result

//-----------------------------------
/*{Protheus.doc}
Mudar a mascara do campo Nr Documento

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Muda a mascara do campo Nr Documento em tempo de execucao
*/
//-----------------------------------
Static Function PICVAR_DOC()
   Local Retorno
   Local oModel    := FWModelActive()
   Local oModelDOC := oModel:GetModel('PRAA802DOC')

   IF AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) <> ''
      IF AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) == 'S'
         Retorno := '9999999'
      ELSE
         IF UPPER(AllTrim(oModelDOC:GetValue('DOC_TPO_DC'))) == 'NF'
            Retorno := '999999999999'
         ELSE
            Retorno := '9999999999999999'
         EndIF
      EndIF
   ELSE
      Retorno := '9999999'
   EndIF
Return Retorno

//-----------------------------------
/*{Protheus.doc}
Habilitar/desabilitar campos

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Habilita/Desabilita campos em tempo de execucao
*/
//-----------------------------------
Static Function WHEN_ALTER()

Return .T.


//-----------------------------------
/*{Protheus.doc}
Zoom dos campos

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Funcao que monta zoom para os campos (Funcao infomada no dicionario de dados)
*/
//-----------------------------------
Function LOOKUPSARA(nTipoCon)
	Local aZoom := {}
	Local aRetZoom := {}
	Local lRet := .T.
	Local oModel    := FWModelActive()
	Local oModelTMP
	Local oModelDOC
	Local oModelITC
	Local cTipoMod

	If ValType(oModel) != "U" .And. oModel:lActivate
		oModelTMP := oModel:GetModel('PRAA802')
		oModelDOC := oModel:GetModel('PRAA802DOC')
		oModelITC := oModel:GetModel('PRAA802ITC')
	EndIf

	If Type("cTipoModal") == "C"
		cTipoMod := cTipoModal
	EndIf
   cRetLkSara := ''

   if nTipoCon == 'OP'
      aZoom := SZoomOP()
   EndIF

   if nTipoCon == 'VE'
      aZoom := SZoomVE(cTipoModal,.F.)
   EndIF
   if nTipoCon == 'EV'
      aZoom := SZoomEV(cTipoModal,oModelTMP:GetValue('TMP_REC_ID'))
   EndIF
   if nTipoCon == 'TR'
      aZoom := SZoomTR(cTipoModal)
   EndIF
   if nTipoCon == 'PE'
      aZoom := SZoomPE(cTipoModal)
   EndIF
   if nTipoCon == 'RC'
      aZoom := SZoomRC()
   EndIF
   if nTipoCon == 'SO'
      aZoom := SZoomSO(cTipoModal,oModelTMP:GetValue('TMP_OPE_ID'))
   EndIF
   if nTipoCon == 'VR'
      aZoom := SZoomVR(oModelTMP:GetValue('TMP_SUB_ID'), oModelTMP:GetValue('TMP_REC_ID'))
   EndIF
   if nTipoCon == 'CL'
      aZoom := SZoomCL()
   EndIF
   if nTipoCon == 'RB'
      aZoom := SZoomVE(cTipoModal,.T.)
   EndIF
   if nTipoCon == 'TD'
      aZoom := SZoomTD(If (!Empty(oModelDOC),oModelDOC:GetValue('DOC_TPO_ES'),""))
   EndIF

   if nTipoCon == 'BK'
      aZoom := SZoomBK('PRAA802CNT')
   EndIF

	if nTipoCon == 'BKD'
      aZoom := SZoomBK('PRAA802DOC')
   EndIF

   if nTipoCon == 'BKPER'
      aZoom := SZoomBK('PRAA802DOC',cEmpPai)
   EndIF

   if nTipoCon == 'BKI'
      aZoom := SZoomBK('PRAA802ITC')
   EndIF

   if nTipoCon == 'DE'
   	 aZoom := SZoomDENT()[1]
   EndIF

   if nTipoCon == 'DEC'
   	 aZoom := SZoomDEC()
   EndIF

   if nTipoCon == 'DECNT'
   	  aZoom := SZoomDECNT()
   endif

   if nTipoCon == 'CT'
      aZoom := SZoomCNT()
   EndIF

   If nTipoCon == 'SRPCNT'
		aZoom := SZoomCNT(2,MV_PAR05,MV_PAR01)
   EndIf
	
   if nTipoCon == 'ES'
      aZoom := SZoomESP(alltrim(oModelITD:getvalue('ITD_ESP_ID')))
   EndIF

   if nTipoCon == 'FA'
      aZoom := SZoomFAM(alltrim(oModelITC:getvalue('ITE_FAM_ID')))
   EndIF

   if nTipoCon == 'LT'
      aZoom := SZoomLT()
   EndIF

   if nTipoCon == 'LI'
      aZoom := SZoomLI()
   EndIF

   if nTipoCon == 'CFOP'
      aZoom := SZoomCFOP()
   EndIF

   if nTipoCon == 'SRCFOP'
      aZoom := A806sZCFOP()
   EndIF

   if nTipoCon == 'ISO'
      aZoom := SZoomISO()
   EndIF

   if nTipoCon == 'OPE'
   	   aZoom := A804SZoomOPE(cTipoMod)
   EndIf

   if nTipoCon == 'VIAFE'
      aZoom := SZoomVIAFE()
   EndIF

   if nTipoCon == 'SARRES'
      aZoom := A806sZRes()
   EndIF
   
    if nTipoCon == 'SARNCM'
      aZoom := A806sZNCM()
   EndIF
   
    if nTipoCon == 'SARVOL'
      aZoom := A806sZVOL()
   EndIF
   
   If nTipoCon == 'SARIMO'
   		aZoom := A807SZIMO()
   EndIf
   
   If nTipoCon == 'SRTRID'
   		aZoom := A807SZTRID()
   EndIf

   If nTipoCon == 'DC'  
   	 	aZoom := SZoomDOC()
   EndIf
   
   If nTipoCon == 'ARMAD'  
   	 	aZoom := SZoomARMAD()
   EndIf
   	
   //aRetZoom := PRAC938(aZoom, '', @lRet)
   if SEmpty(aZoom)
       cRetLkSara := ''
       return .T.
       /*
       if nTipoCon = 'BKD' .or. nTipoCon = 'BD' .or. nTipoCon = 'BKI'
       	return ''
       else
   			return .T.
   		endif
   		*/
   else
        If ((nTipoCon == "DECNT") .And. !Len(aZoom[2]))
           return .T.
        EndIf
		aRetZoom := PRAC938(aZoom, '', @lRet)
   endif


   if !SEmpty(aRetZoom)
      cRetLkSara := STransType(aRetZoom[1],"C")
      
      If (nTipoCon == 'DC') 
      		if oModelDOC:getvalue('DOC_TPO_ES') == 'E'
      			PRAA802001RetornaCamposPesquisa(oModelDOC, aRetZoom)
      		else
      			PRAA802002RetornaPesqDocSaida(oModelDOC, aRetZoom)	
      		endif		
      EndIf 
      
      
      If nTipoCon == 'OPE' .Or. nTipoCon == 'PE'
      	cRetLkSara := AllTrim(StrTran(StrTran(StrTran(cRetLkSara,".",""),"-",""),"/",""))
      EndIf
      /*
      if ntipocon = 'CL' .and. alltrim(cRetLkSara) =  AllTrim(oModelTMP:GetValue('TMP_CLI_ID'))
      		return cRetLkSara
      endif
      */
   else
      cRetLkSara := ''         
   endif

//   if ((nTipoCon == 'RB') .or. (nTipoCon == 'TD'))
//      DbSelectArea(cAliasTMP)
//   EndIf
	DbSelectArea('SA1')
Return lRet

static function SZoomFAM(familia)
	Local aRet := {}
   Local aFields := {}
   Local cSql := ''

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

   cSql :=  " select fam_id, fam_desc_gen from tab_familias "

   //if  alltrim(familia) <> ''
   	//	cSQl += " WHERE fam_id = '" + familia + "'"
   //	endif

   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY fam_id')

              //aFields,   cCampo           ,  cDesc      , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "fam_id"           , 'Código'      , "C"  , 8      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "fam_desc_gen"     , 'Família'     , "C"  , 20      , 0        , ""      , .T.     , .F.)

   Aadd(aRet, aFields)

return aRet

static function SZoomESP(especie)
	Local aRet := {}
	Local aFields := {}
	Local cSql := ''

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

   cSql :=  " select esp_id, esp_descricao from tab_especie "

   //if  alltrim(especie) <> ''
   //		cSQl += " WHERE esp_id = '" + especie + "'"
   //	endif

   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY esp_id')

              //aFields,   cCampo           ,  cDesc      , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "esp_id"           , 'Código'      , "C"  , 2      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "esp_descricao"    , 'Espécie'     , "C"  , 20      , 0        , ""      , .T.     , .F.)

   Aadd(aRet, aFields)

return aRet



static function SZoomCNT(nTipo,cCliId,cResNu,cNrDc)
   Local aRet := {}
   Local aFields := {}
   Local oModel    := FWModelActive()
   Local oModelCNT 
   Local oModelTMP 
   Local nI := 0
   Local cQuery := ''
   Local cQueryAux := ''
   Local nQuantCNT := 0
   Local cResId := ""
   Local cOpId  :="1"
   Default nTipo :=1
   Default cCliId :=""
   Default cResNu :=""
   Default cNrDc  :=""
   
   If nTipo == 1
   		oModelCNT := oModel:GetModel('PRAA802CNT')
		oModelTMP := oModel:GetModel('PRAA802')
		cCliId := omodelTMP:getvalue('TMP_CLI_ID')
		cResNu := omodelCNT:getvalue('CNT_RES_NU')
		cResId := omodelCNT:getvalue('CNT_RES_ID')
		cNrDc  := omodelCNT:getvalue('CNT_DP_DS')
		cOpId  := oModelTMP:GetValue('TMP_OPE_ID')
	EndIf
	

	if (oModelCNT:GetValue('CNT_TPO_ES') == 'S') .Or. (AllTrim(oModelCNT:GetValue('CNT_TPO_ES')) == 'SAIDA')
   		Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

   		if alltrim(cCliId) = '' .And. nTipo == 1
	   	   alert('Operação negada. É preciso informar o cliente de carga para pesquisar o container.')
	   	   return .F.
	    endif

   		if alltrim(cResNu) = ''
							   	cQuery := 		   "	select DISTINCT isnull(a.cnt_id,'') as cnt_id,  "
								cQuery += 			"   isnull(a.tiso_id,'') as tiso_id, "
								cQuery += 			"				       b.cnt_tipo "
								cQuery += 			"				       from vw_inventario_container a "
								cQuery += 			"				       left join tab_container b "
								cQuery += 			"				       on b.cnt_id  = a.cnt_id "
								If !Empty(cCliId)
									cQuery +=         "                where a.cli_id = '" +alltrim(cCliId)+ "'"
								EndIf

		else
								cQuery := 		   "	select DISTINCT isnull(a.cnt_id,'') as cnt_id, "
								cQuery += 			"		    isnull(a.tiso_id,'') as tiso_id, "
								cQuery += 			"			       c.cnt_tipo "
								cQuery += 			"			       from vw_inventario_container a "
								cQuery += 			"			       inner join tab_reserva_doc_cnt b "
								cQuery += 			"			         on  b.mcnt_id = a.mcnt_id "
								cQuery += 			"			       left join tab_container c "
								cQuery += 			"			         on c.cnt_id = a.cnt_id "
								If !Empty(cResId)
									cQuery +=        "                 where b.res_id = " + alltrim(cResId)
								Else
									cQuery +=        "             left join tab_reserva e on  "
									cQuery +=        "             e.res_id = b.res_id  " 
									cQuery +=        "                 where e.res_numero = '" + alltrim(cResNu) + "'"
								EndIf
		endif

		if alltrim(cNrDc) <> ''
				cQuery +=		' and exists (select 1    '
				cQuery +=      '   from tab_di_item c  '
				cQuery +=      '     inner join tab_lote_atual d '
				cQuery +=      '       on d.latu_lote = c.latu_lote '
				cQuery +=      '       and d.latu_item = c.latu_item '
			   cQuery +=      '       and d.cnt_id = a.cnt_id '
			   cQuery +=      '       and d.latu_qt_saldo > 0 '
			   cQuery +=      "       and c.dsai_id = '"  + alltrim(cNrDc) +  "')"
		endif

	If nTipo == 1
		cQueryAux := " and a.cnt_id not in ("

		For nI := 1 To oModelCNT:Length()
		   If (AllTrim(oModelCNT:GetValue('CNT_CNT_ID',nI)) <> '') .and. (.Not. oModelCNT:IsDeleted(nI));
			   		.and.  AllTrim(oModelCNT:GetValue('CNT_TISO_I',nI)) <> ''  .and.  AllTrim(oModelCNT:GetValue('CNT_QTD_CN',nI)) <> ''

		   	  If nQuantCNT > 0
		   	  	 cQueryAux +=","
		   	  EndIf
		   	  nQuantCNT++
         	 cQueryAux += "'" + AllTrim(oModelCNT:GetValue('CNT_CNT_ID',nI)) + "'"

		   EndIf
		Next nI
		cQueryAux += ")"

		if nQuantCNT > 0
			cQuery := cQuery + cQueryAux
		endif

	EndIf
       Aadd(aRet, cQuery)
		Aadd(aRet, 'ORDER BY cnt_id')

		SAddPField(@aFields , "cnt_id"           , 'Container'      , "C"  , 11      , 0        , ""      , .T.     , .T., .T., 1)
		SAddPField(@aFields , "tiso_id"          , 'Tipo iso'       , "C"  , 10      , 0        , ""      , .T.     , .F.)

	   	Aadd(aRet, aFields)
	else
		if (oModelCNT:GetValue('CNT_TPO_ES') == 'E') .Or. (AllTrim(oModelCNT:GetValue('CNT_TPO_ES')) == 'ENTRADA')
			Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)  
			
			 
		  if !Empty(alltrim(cNrDc)) 
			cQuery := 		   "	select "
			cQuery += 			"		DISTINCT isnull(d.cnt_id,'') as cnt_id,   isnull(d.tiso_id,'') as tiso_id, 	d.cnt_tipo "
			cQuery += 			"	from "
			cQuery += 			"		tab_reserva a "
			cQuery += 			"		join tab_reserva_rateio_cnt b on a.res_id = b.res_id "
			cQuery += 			"		join tab_reserva_container c on b.rcnt_id = c.rcnt_id "
			cQuery += 			"		join tab_container d on c.cnt_id = d.cnt_id "
			cQuery +=        "   where a.res_numero = '" + alltrim(cResNu) + "'"		
			cQuery +=        "   and b.dent_id = '" + alltrim(cNrDc) + "'"			
   		  else	
           cQuery := "select "+; 		
					   "	 DISTINCT isnull(d.cnt_id,'') as cnt_id,   isnull(d.tiso_id,'') as tiso_id, 	d.cnt_tipo "+;  	
                    "from "+;  
    	             "	tab_reserva_container a "+;           
		             "	inner join tab_reserva_programacao b on b.trp_id = a.trp_id "+;            
		             "	inner join tab_reserva c on c.res_id = b.res_id "+;   
                    "	join tab_container d on a.cnt_id = d.cnt_id "+;         
      				   "where c.res_numero = '" + alltrim(cResNu) + "'"+;	
      				   "   and b.trp_cnt_cheio = 0 " //CNT Vazio        
          endif 
   
			Aadd(aRet, cQuery)
			Aadd(aRet, 'ORDER BY cnt_id')

			SAddPField(@aFields , "cnt_id"           , 'Container'      , "C"  , 11      , 0        , ""      , .T.     , .T., .T., 1)
			SAddPField(@aFields , "tiso_id"          , 'Tipo iso'       , "C"  , 10      , 0        , ""      , .T.     , .F.)

	   		Aadd(aRet, aFields)
		Endif
   EndIf
return aRet

static function SZoomDECNT()
   Local aData := {}
   Local aRet := {}
   Local aFields := {}
   Local cSql := ''
   Local oModel    := FWModelActive()
   Local oModelCNT := oModel:GetModel('PRAA802CNT')
   Local oModelTMP := oModel:GetModel('PRAA802')
   Local tQuery := GetNextAlias()
   Local cTpoDoc := ""
   Local cAnoDoc := ""
   Local Retorno := ""
   Local cSerDoc := ""
   Local cNumDoc := ""
   Local cSQLIn
   Local aSQLIn
   Local nI
   Local nX
   Local aRetDoc
   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_ARRAY)
   
   if (alltrim(oModelCNT:GetValue('CNT_TPO_ES')) = '')
   	   		alert('Operação negada. É preciso informar o tipo de operação( Entrada / Saída).')
   	   		return {}
   	endif

   //if alltrim(FwFldGet("TMP_OPE_ID")) == '2' //Descarga
   If (oModelCNT:GetValue('CNT_TPO_ES') == "E")
   
		if alltrim(oModelCNT:getvalue('CNT_RES_ID')) = ''
	   		if alltrim(omodelTMP:getvalue('TMP_CLI_ID')) = ''
	   	   		alert('Operação negada. É preciso informar o cliente de carga para pesquisar o documento.')
	   	   		return {}
	   		endif		
	   		cSql :=  		  "     select distinct isnull(a.dsai_id,'') as dsai_id "
			cSql +=		  "		from tab_di_item a "
			cSql +=		  "	  inner join vw_inventario_armazem b "
			cSql +=		  "	    on b.latu_lote = a.latu_lote and "
			cSql +=			"	    b.latu_item = a.latu_item "
			cSql +=			"	  inner join tab_doc_saida c "
			cSql +=			"	    on c.dsai_id = a.dsai_id "
			cSql +=			"	  inner join tab_clientes d "
			cSql +=			"	    on d.cli_id = c.ben_id  "
		   	cSql +=         " where d.cli_id = '" + alltrim(omodelTMP:getvalue('TMP_CLI_ID')) + "'"
   		else
			cSql :=  		     "	   	  select distinct isnull(a.dsai_id,'') as dsai_id         "
			cSql +=		  	  "			from tab_di_item a "
			cSql +=		  	  "			  inner join vw_inventario_armazem b "
			cSql +=		  	  "			    on b.latu_lote = a.latu_lote and "
			cSql +=		  	  "			       b.latu_item = a.latu_item "
			cSql +=		  	  "			  inner join tab_reserva_doc_cnt c "
			cSql +=		  	  "			    on c.dent_id = b.dent_id "
			cSql +=		  	  "			where c.res_id = " +  alltrim(oModelCNT:getvalue('CNT_RES_ID'))
   		endif
   		
   	else
		  if alltrim(oModelCNT:getvalue('CNT_RES_ID')) = ''   
		  	 if alltrim(omodelTMP:getvalue('TMP_CLI_ID')) = ''
	   	   		alert('Operação negada. É preciso informar o cliente de carga para pesquisar o documento.')
	   	   		return {}
	   		endif		
			cSql := " select  distinct isnull(e.dsai_id,'') as dsai_id         "+;
			"from tab_reserva_doc_cnt a "+; 
			"inner join rel_dent_cnt b "+; 
			"  on b.dent_id = a.dent_id "+; 
			"inner join tab_di_item c "+;  
			"  on c.latu_lote = b.lote_id "+;    
			"inner join tab_doc_saida e "+; 
			"  on e.dsai_id = c.dsai_id "+;  
			"where e.ben_id = " + "'" +  alltrim(omodelTMP:getvalue('TMP_CLI_ID')) + "'"			    		
   		  else
			cSql := " select  distinct isnull(e.dsai_id,'') as dsai_id         "+;
			"from tab_reserva_doc_cnt a "+; 
			"inner join rel_dent_cnt b "+; 
			"  on b.dent_id = a.dent_id "+; 
			"inner join tab_di_item c "+;  
			"  on c.latu_lote = b.lote_id "+;    
			"inner join tab_doc_saida e "+; 
			"  on e.dsai_id = c.dsai_id "+;  
			"where a.res_id = " + "'" + alltrim(oModelCNT:getvalue('CNT_RES_ID')) + "'"      		  
   		  endif
   	endif
   		
		aSQLIn := SMGrdtoArr(omodel:getmodel('PRAA802DOC'),'DOC_DOC_ID','pst_tabd2()')
		cSQLIn := "'',"
		For nX := 1 To Len(aSQLIn)
			cSQLIn += "'" + alltrim(aSQLIn[nX]) + "',"
		Next nX
		cSQLIn := SubStr(cSQLIn, 0, len(cSQLIn) - 1)
		
		if (oModelCNT:GetValue('CNT_TPO_ES') == "E") //Entrada / Descarga
			cSql += " and a.dsai_id IN ("+cSQLIn+")"
		else	
			cSql += " and c.dsai_id IN ("+cSQLIn+")"
		endif		
		
		
		dbUseArea(.T., 'TOPCONN', TCGenQry(,,cSql),tQuery, .F., .T.)
		(tQuery)->(dbGoTop())
		While !(tQuery)->(Eof())
			cTpoDoc := AllTrim(GetDocId(SUBSTR(AllTrim((tQuery)->dsai_id),5,1)))
	
			DbSelectArea(tQuery)
			cAnoDoc := SUBSTR(AllTrim((tQuery)->dsai_id),1,4)
	
			if alltrim(FwFldGet("TMP_OPE_ID")) == '2' //Descarga			
				Retorno := SUBSTR(AllTrim((tQuery)->dsai_id),15,6)
								
				IF UPPER(cTpoDoc) == 'NF'
					cSerDoc := SUBSTR(AllTrim((tQuery)->dsai_id),6,3)
					cNumDoc := SUBSTR(AllTrim((tQuery)->dsai_id),9,9)
				else
					cSerDoc := ''
					cNumDoc := SUBSTR(AllTrim((tQuery)->dsai_id),6,9)
				endif
			else
				IF UPPER(cTpoDoc) == 'NF'
					Retorno := SUBSTR(AllTrim((tQuery)->dsai_id),9,9)
					cSerDoc := SUBSTR(AllTrim((tQuery)->dsai_id),6,3)
					cNumDoc := SUBSTR(AllTrim((tQuery)->dsai_id),9,9)					
				else
					Retorno := SUBSTR(AllTrim((tQuery)->dsai_id),6,15)
					cSerDoc := ''
					cNumDoc := SUBSTR(AllTrim((tQuery)->dsai_id),6,15)					
				endif		 
			endif
		

			//EndIf
	
			cPrcDoc := ''
			aAdd(aData,{(tQuery)->dsai_id,cTpoDoc,cAnoDoc,cNumDoc,cSerDoc,cPrcDoc})
			(tQuery)->(dbSkip())
		EndDo
		aRetDoc := SZoomDENT()[2]
    	For nI := 1 to Len(aRetDoc)
	    	//Adiciona os documentos ainda não adicionados
	    	If (AllTrim(aRetDoc[nI][1]) == "E") .Or. (AllTrim(aRetDoc[nI][1]) == "S")
	    	Else  
	    		If !aScan(aData,{|x| AllTrim(x[1]) == AllTrim(aRetDoc[nI][1])}) > 0
		    		aAdd(aData,{aRetDoc[nI][1],aRetDoc[nI][2],aRetDoc[nI][3],aRetDoc[nI][4],aRetDoc[nI][5],aRetDoc[nI][6]})
	    		EndIf
    		EndIf
    	Next nI
	
	  	Aadd(aRet, aData) //Instrucao ou Array com os dados
		Aadd(aRet, nil)
   					//aFields, cCampo        ,  cDesc    , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   		SAddPField(@aFields, "Documento"  	, "Documento"			, "C",	30, 0, "", .F., .T. ) //Monta a estrutura de campos
   		SAddPField(@aFields, "Tp. Doc."   	, "Tp. Doc."			, "C", 10, 0, "", .T., .F.) //Monta a estrutura de campos
   		SAddPField(@aFields, "Ano"   		, "Ano"				, "C",	04, 0, "", .T., .F.) //Monta a estrutura de campos
   		SAddPField(@aFields, "Nr. Doc."   	, "Nr. Doc."			, "C", 30, 0, "", .T., .F.) //Monta a estrutura de campos
   		SAddPField(@aFields, "Série"   		, "Série"				, "C", 03, 0, "", .T., .F.) //Monta a estrutura de campos
   		SAddPField(@aFields, "Procedência"	, "Procedência"		, "C", 30, 0, "", .T., .F.) //Monta a estrutura de campos
		
	Aadd(aRet, aFields)

return aRet

static function SZoomDOC()
    Local aRet := {}
    Local aFields := {}
    Local oModel    := FWModelActive()
    Local oModelDOC := oModel:GetModel('PRAA802DOC')     

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)
   
	//if alltrim(FwFldGet("TMP_OPE_ID")) == '2' //Descarga
	If (AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = 'E')
   		Aadd(aRet, SQLSel001TabDocEntrada(alltrim(oModelDOC:getvalue('DOC_RES_NU'))) )  		
   		Aadd(aRet, 'ORDER BY 1')

   		//aFields, cCampo        ,  cDesc    , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   		//SAddPField(@aFields, "Documento"  	, "Documento"			, "C",	30, 0, "", .F., .F. ) //Monta a estrutura de campos
   		SAddPField(@aFields, "Nr. Doc2."   	, "Nr. Doc2."			, "C", 30, 0, "", .F., .T.) //Monta a estrutura de campos
   		SAddPField(@aFields, "Tp. Doc."   	, "Tp. Doc."			, "C", 10, 0, "", .T., .T.) //Monta a estrutura de campos
		SAddPField(@aFields, "Ano"   		, "Ano"				, "C",	04, 0, "", .T., .T.) //Monta a estrutura de campos
	 	SAddPField(@aFields, "Nr. Doc."   	, "Nr. Doc."			, "C", 30, 0, "", .T., .F.) //Monta a estrutura de campos
   		SAddPField(@aFields, "Série"   		, "Série"				, "C", 03, 0, "", .T., .T.) //Monta a estrutura de campos
   		SAddPField(@aFields, "Procedência"	, "Procedência"		, "C", 30, 0, "", .T., .T.) //Monta a estrutura de campos
		SAddPField(@aFields, "Reserva"	   , "Reserva"		    , "C", 30, 0, "", .F., .T.) //Monta a estrutura de campos
   		SAddPField(@aFields, "cfop_id"	   , "cfop_id"		    , "C", 30, 0, "", .F., .T.) //Monta a estrutura de campos
   		SAddPField(@aFields, "cli_cgc"	   , "cli_cgc"		        , "C", 30, 0, "", .F., .T.) //Monta a estrutura de campos	
	else //Carga
   		Aadd(aRet, SQLSel003TabDocSaida(alltrim(oModelDOC:getvalue('DOC_RES_ID')), AllTrim(oModelDOC:GetValue('DOC_NUM_DC'))) ) 		
   		Aadd(aRet, 'ORDER BY 1')

   		//aFields, cCampo        ,  cDesc    , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
	 	SAddPField(@aFields, "numero"   	, "Nr. Doc."			, "C", 30, 0, "", .T., .T.) //Monta a estrutura de campos   		  		
   		SAddPField(@aFields, "tipo_doc"   	, "Tp. Doc."			, "C", 10, 0, "", .T., .T.) //Monta a estrutura de campos
		SAddPField(@aFields, "ano"   		, "Ano"				, "C",	04, 0, "", .T., .T.) //Monta a estrutura de campos		
   		SAddPField(@aFields, "serie"   		, "Série"				, "C", 03, 0, "", .T., .T.) //Monta a estrutura de campos
   		SAddPField(@aFields, "procedencia"	, "Procedência"		, "C", 30, 0, "", .T., .T.) //Monta a estrutura de campos
   		SAddPField(@aFields, "cfop_id"	   , "cfop_id"		    , "C", 30, 0, "", .F., .T.) //Monta a estrutura de campos		
   		SAddPField(@aFields, "cli_cgc"	   , "cli_cgc"		    , "C", 30, 0, "", .F., .T.) //Monta a estrutura de campos   		   		     	
	endif
   		

   Aadd(aRet, aFields)

return aRet 

static function SZoomARMAD()
   Local aRet := {}
   Local aFields := {}
   Local cSql := ''

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

   cSql := " select a.cli_id, a.cli_nome   "
   cSql += " from tab_clientes a           "
   cSql += " inner join rel_tipo_cliente b "
   cSql += "   on b.cli_id = a.cli_id      "
   cSql += " where b.tcli_id = 14          "
   
   if cEmpPai <> SGetTerm()
		cSql += " and exists (select 1            "
        cSql += " from vw_portal_permissao_acesso "
        cSql += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "' and mnu_id = 'A'"
        cSql += " and cli_id_acesso_info = a.cli_id) "
   endif

   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY a.cli_id')

              //aFields,   cCampo           ,  cDesc      , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "cli_id"           , STR0238      , "C"  , 10      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "cli_nome"         , STR0239  , "C"  , 30      , 0        , ""      , .T.     , .F.)

   Aadd(aRet, aFields)

return aRet

Static Function A802ARMDESC()
   Local cSql      := ''
   Local oModel    := FWModelActive()
   Local oModelCNT := oModel:GetModel('PRAA802CNT')
   Local cArm_ID   := ''
   Local tQuery    := GetNextAlias()

   if A802VLDARMAD('PRAA802CNT') == .F.
       Return .F.
   EndIf
   
   If lTemDepot
       cArm_ID := Trim(oModelCNT:GetValue('CNT_ARMADO'))
   EndIf
   
   If !Empty(cArm_ID)
   	   cSql := " select cli_nome from tab_clientes "
	   cSql += " where cli_id = " + cArm_ID
	   
	   dbUseArea(.T., 'TOPCONN', TCGenQry(,,cSql),tQuery, .F., .T.)
	   
	   (tQuery)->(dbGoTop())
		
	   If Trim((tQuery)->cli_nome) <> ''
	        oModelCNT:loadvalue('CNT_ARM_DS',alltrim((tQuery)->cli_nome))
	   EndIf
	   
	   (tQuery)->(dbCloseArea())
   EndIf
     
Return .T. 

static function SZoomDEC()
   Local aRet := {}
   Local aFields := {}
   Local cSql := ''
   Local oModel    := FWModelActive()
   Local oModelITC := oModel:GetModel('PRAA802ITC')
   Local aData := {}
   Local oModelTMP := oModel:GetModel('PRAA802')
   Local tQuery := GetNextAlias()
   Local lITCRESID := alltrim(oModelITC:getvalue('ITC_RES_ID')) == ''
   Local cSQLIn
   Local aSQLIn
   Local nX
   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_ARRAY)

   if lITCRESID
	   if alltrim(omodelTMP:getvalue('TMP_CLI_ID')) = ''
	   	   alert('Operação negada. É preciso informar o cliente de carga para pesquisar o documento.')
	   	   return .F.
	   endif

	   cSql :=  		  "     select distinct isnull(a.dsai_id,'') as dsai_id, "
	   cSql +=		  	  "	       isnull(d.cli_id,'') as cli_id, "
		cSql +=		  "		    isnull(d.cli_nome,'') as cli_nome  "
		cSql +=		  "		from tab_di_item a "
		cSql +=		  "	  inner join vw_inventario_armazem b "
		cSql +=		  "	    on b.latu_lote = a.latu_lote and "
		cSql +=			"	    b.latu_item = a.latu_item "
		cSql +=			"	  inner join tab_doc_saida c "
		cSql +=			"	    on c.dsai_id = a.dsai_id "
		cSql +=			"	  inner join tab_clientes d "
		cSql +=			"	    on d.cli_id = c.ben_id  "
	   cSql +=         " where 1 = 1 "
   else
		cSql :=  		     "	   	  select distinct isnull(a.dsai_id,'') as dsai_id         "
		cSql +=		  	  "			from tab_di_item a "
		cSql +=		  	  "			  inner join vw_inventario_armazem b "
		cSql +=		  	  "			    on b.latu_lote = a.latu_lote and "
		cSql +=		  	  "			       b.latu_item = a.latu_item "
		cSql +=		  	  "			  inner join tab_reserva_doc_cnt c "
		cSql +=		  	  "			    on c.dent_id = b.dent_id "
		cSql +=		  	  "			where res_id = " +  alltrim(oModelITC:getvalue('ITC_RES_ID'))
   endif

	aSQLIn := SMGrdtoArr(omodel:getmodel('PRAA802DOC'),'DOC_DOC_ID','pst_tabd2()')
	cSQLIn := "'',"
	For nX := 1 To Len(aSQLIn)
		cSQLIn += "'" + alltrim(aSQLIn[nX]) + "',"
	Next nX
	cSQLIn := SubStr(cSQLIn, 0, len(cSQLIn) - 1)
	cSql += " and a.dsai_id IN ("+cSQLIn+")"
	cSql := ChangeQuery(cSql)
   dbUseArea(.T., 'TOPCONN', TCGenQry(,,cSql),tQuery, .F., .T.)
	(tQuery)->(dbGoTop())
	While !(tQuery)->(Eof())
		cTpoDoc := AllTrim(GetDocId(SUBSTR(AllTrim((tQuery)->dsai_id),5,1)))

		DbSelectArea(tQuery)
		cAnoDoc := SUBSTR(AllTrim((tQuery)->dsai_id),1,4)

		Retorno := SUBSTR(AllTrim((tQuery)->dsai_id),15,6)

		IF UPPER(cTpoDoc) == 'NF'
			cSerDoc := SUBSTR(AllTrim((tQuery)->dsai_id),6,3)
			cNumDoc := SUBSTR(AllTrim((tQuery)->dsai_id),9,9)
		else
			cSerDoc := ''
			cNumDoc := SUBSTR(AllTrim((tQuery)->dsai_id),6,9)
		endif

		cPrcDoc := ''
		if lITCRESID
			aAdd(aData,{(tQuery)->dsai_id,cTpoDoc,cAnoDoc,cNumDoc,cSerDoc,cPrcDoc,(tQuery)->cli_id,(tQuery)->cli_nome})
		Else
			aAdd(aData,{(tQuery)->dsai_id,cTpoDoc,cAnoDoc,cNumDoc,cSerDoc,cPrcDoc})
		EndIf
		(tQuery)->(dbSkip())
	EndDo
	(tQuery)->(dbCloseArea())


  	Aadd(aRet, aData) //Instrucao ou Array com os dados
	Aadd(aRet, nil)
   				//aFields, cCampo        ,  cDesc    , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields, "Documento"  	, "Documento"			, "C",	30, 0, "", .F., .T. ) //Monta a estrutura de campos
   SAddPField(@aFields, "Tp. Doc."   	, "Tp. Doc."			, "C", 10, 0, "", .T., .F.) //Monta a estrutura de campos
   SAddPField(@aFields, "Ano"   		, "Ano"				, "C",	04, 0, "", .T., .F.) //Monta a estrutura de campos
   SAddPField(@aFields, "Nr. Doc."   	, "Nr. Doc."			, "C", 30, 0, "", .T., .F.) //Monta a estrutura de campos
   SAddPField(@aFields, "Série"   		, "Série"				, "C", 03, 0, "", .T., .F.) //Monta a estrutura de campos
   SAddPField(@aFields, "Procedência"	, "Procedência"		, "C", 30, 0, "", .T., .F.) //Monta a estrutura de campos

	if lITCRESID
	   SAddPField(@aFields , "cli_id"    			, 'Cód. cliente', "C"  ,15      , 0        , ""      , .T.     , .F.)
	   SAddPField(@aFields , "cli_nome"  		  , 'Cliente'     , "C"  , 50      , 0        , ""      , .T.     , .F.)
	 endif


   Aadd(aRet, aFields)

return aRet


static function SZoomDENT()
   Local aRet := {}
   Local aFields := {}
   Local oModel    := FWModelActive()
   Local oModelDOC := oModel:GetModel('PRAA802DOC')
   Local nI := 0
   Local nX := 0
   Local nY := 0
   Local aData := {}
   Local aResultado := {}
   Local aDataFields := {}
   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_ARRAY)
   For nI := 1 To oModelDOC:Length()
	   oModelDOC:GoLine(nI)
	   If !(oModelDOC:IsDeleted())
//	      if AllTrim(oModelDOC:GetValue('DOC_DOC_ID')) = ''

	      	   if(AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = '')
	          		alert("No grid 'Documentos', o campo 'Tipo e/s' dos documentos deve ser preenchido")
	          		return {aRet,aData}
	          elseif(AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) = '')
	          		alert("No grid 'Documentos', o campo 'Nr. doc.' dos documentos deve ser preenchido")
	          		return {aRet,aData}
	          elseif(AllTrim(oModelDOC:GetValue('DOC_ANO_DC')) = '')
	          		alert("No grid 'Documentos', o campo 'Ano' dos documentos deve ser preenchido")
	          		return {aRet,aData}
	          elseif(AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) = '')
          			alert("No grid 'Documentos', o campo 'Tp. doc.' dos documentos deve ser preenchido")
	          		return {aRet,aData}
	          endif
	          aResultado := {}
		   	  resultado :=  pst_tabd2(@aResultado)
		      if(substr(resultado,1,5) = 'ERROR')
		      	  if AllTrim(oModelDOC:GetValue('DOC_TPO_ES')) = 'E'
			   	  	  alert('Erro no documento de entrada de tipo ' + AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) + ' e de Número ' + AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) + '.' + chr(13)  + 'Erro: ' + substr(resultado,6,len(resultado)))
			   	  else
			   	      alert('Erro no documento de saida de tipo ' + AllTrim(oModelDOC:GetValue('DOC_TPO_DC')) + ' e de Número ' + AllTrim(oModelDOC:GetValue('DOC_NUM_DC')) + '.' + chr(13)  + 'Erro: ' + substr(resultado,6,len(resultado)))
			   	  endif

			   	  return {aRet,aData}
			   else
			        If(Len(aResultado) > 0)
				   		oModelDOC:setvalue('DOC_DOC_ID',alltrim(aResultado[1]))
				   		nX := Aadd(aData, {})
						For nY := 1 To Len(aResultado)
							aAdd(nX,aResultado[nY])
						Next nY
				   		aAdd(aResultado,oModelDOC:GetValue('DOC_TPO_ES'))
	//			   		aDataFields := {}
			       	    Aadd(aDataFields,aResultado)
		       	    EndIf
		       endif
//		   else
//		   	  aDataFields := {}
//		   	  Aadd(aDataFields,AllTrim(oModelDOC:GetValue('DOC_DOC_ID')))
//		   	  Aadd(aData, aDataFields)
//	      endif
	   EndIf
	Next nI


	Aadd(aRet, aData) //Instrucao ou Array com os dados
	Aadd(aRet, nil)
   				//aFields, cCampo        ,  cDesc    , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields, "Documento"  	, "Documento"			, "C",	30, 0, "", .F., .T. ) //Monta a estrutura de campos
   SAddPField(@aFields, "Tp. Doc."   	, "Tp. Doc."			, "C", 10, 0, "", .T., .F.) //Monta a estrutura de campos
   SAddPField(@aFields, "Ano"   		, "Ano"				, "C",	04, 0, "", .T., .F.) //Monta a estrutura de campos
   SAddPField(@aFields, "Nr. Doc."   	, "Nr. Doc."			, "C", 30, 0, "", .T., .F.) //Monta a estrutura de campos
   SAddPField(@aFields, "Série"   		, "Série"				, "C", 03, 0, "", .T., .F.) //Monta a estrutura de campos
   SAddPField(@aFields, "Procedência"	, "Procedência"		, "C", 30, 0, "", .T., .F.) //Monta a estrutura de campos

   Aadd(aRet, aFields)
return {aRet,aDataFields}

//-----------------------------------
/*{Protheus.doc}
Zoom campo operacao

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Monta zoom campo operacao
*/
//-----------------------------------
static function SZoomOP()
   Local aRet := {}
   Local aFields := {}
   Local cSql := ''

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

   cSql :=  "SELECT OP_ID, OP_DESCRICAO FROM TAB_OPERACAO "

   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY OP_ID')

              //aFields,   cCampo           ,  cDesc      , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "OP_ID"           , STR0238      , "C"  , 10      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "OP_DESCRICAO"    , STR0239  , "C"  , 30      , 0        , ""      , .T.     , .F.)

   Aadd(aRet, aFields)

return aRet



//-----------------------------------
/*{Protheus.doc}
Zoom campo veiculo

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Monta zoom campo veiculo
*/
//-----------------------------------
static Function SZoomVE(cModal,lReboque)
   Local aRet := {}
   Local aFields := {}
   Local cSql



   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

   cSql :=  "SELECT VEI_ID, VEI_MODELO, VEI_ANO, VEI_MARCA, VEI_COR FROM TAB_VEICULOS "
   cSql +=  "WHERE VEI_MODAL = '"+cModal+"' "
   if lReboque == .T.
      cSql +=  "AND TIPO_ID = 8 "
   Else
   	  cSql +=  "AND TIPO_ID != 8 "
   EndIf
   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY VEI_ID')

              //aFields,   cCampo           ,  cDesc      , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "VEI_ID"           , STR0002      , "C"  , 10      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "VEI_MODELO"       , STR0124     , "C"  , 10      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "VEI_ANO"          , STR0063     , "C"  , 10      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "VEI_MARCA"        , STR0125     , "C"  , 15      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "VEI_COR"          , STR0126     , "C"  , 10      , 0        , ""      , .T.     , .F.)

   Aadd(aRet, aFields)

return aRet

//-----------------------------------
/*{Protheus.doc}
Zoom campo evento

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Monta zoom campo evento
*/
//-----------------------------------
static Function SZoomEV(cModal, cRecID)
   Local aRet := {}
   Local aFields := {}
   Local cSql

   if cModal == 'V'
      cModal := 'R'
   EndIf

   IF AllTrim(cRecID) == ''
      cRecID := '-1'
   EndIf

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

   cSql := " SELECT A.EVE_ID, A.EVE_SEQ, A.EVE_DESC, CASE WHEN A.EVE_OBRIGATORIO = 0 THEN 'NAO' ELSE 'SIM' END AS EVE_OBRIGATORIO"
   cSql += "   FROM TAB_AGEN_EVENTOS A,REL_USUARIO_RECINTO X "
   cSql += "  WHERE A.EVE_MODAL = '"+cModal+"'"
   cSql += "    AND A.EVE_ID = 1 "
   cSql += "    AND Y.REL_ID = X.REL_ID "
   cSql += "    AND Y.EVE_ID = A.EVE_ID "
   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY A.EVE_SEQ')

              //aFields,   cCampo           ,  cDesc        , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "EVE_ID"           , STR0011        , "N"  , 10      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "EVE_SEQ"          , STR0067        , "N"  , 10      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "EVE_DESC"         , STR0123        , "C"  , 50      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "EVE_OBRIGATORIO" , STR0127        , "C"  , 3       , 0        , ""      , .T.     , .F.)

	Aadd(aRet, aFields)

return aRet

//-----------------------------------
/*{Protheus.doc}
Zoom campo Transportadora

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Monta zoom campo Transportadora
*/
//-----------------------------------
static Function SZoomTR(cModal)
   Local aRet := {}
   Local aFields := {}
   Local cSql

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cSql :=  " SELECT CASE LEN(A.TRANS_CGC) "
   cSql +=  "      WHEN 14 then "
   cSql +=  "         SUBSTRING(A.TRANS_CGC,1,2)++'.'++SUBSTRING(A.TRANS_CGC,3,3)++'.'++SUBSTRING(A.TRANS_CGC,6,3)++'/'++SUBSTRING(A.TRANS_CGC,9,4)++'-'++SUBSTRING(A.TRANS_CGC,13,2) "
   cSql +=  "      WHEN 11 then "
   cSql +=  "         SUBSTRING(A.TRANS_CGC,1,3)++'.'++SUBSTRING(A.TRANS_CGC,4,3)++'.'++SUBSTRING(A.TRANS_CGC,7,3)++'-'++SUBSTRING(A.TRANS_CGC,10,2) "
   cSql +=  "      ELSE "
   cSql +=  "         A.TRANS_CGC "
   cSql +=  " END AS TRANS_CGC, A.TRANS_NOME, A.TRANS_ID "
   cSql +=  " FROM TAB_TRANSPORTADORA A, REL_TRANS_MODAL B  "
   cSql +=  " WHERE A.TRANS_ID = B.TRANS_ID "
   cSql +=  "   AND B.MODAL = '"+cModal+"' "
   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY A.TRANS_ID')

              //aFields,   cCampo           ,  cDesc          , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   
   SAddPField(@aFields , "TRANS_CGC"        , STR0240       , "C"  , 20      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "TRANS_NOME"       , STR0018          , "C"  , 50      , 0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "TRANS_ID"         , STR0016          , "N"  , 10      , 0        , ""      , .T.      , .F.)
	Aadd(aRet, aFields)

return aRet

//-----------------------------------
/*{Protheus.doc}
Zoom campo Motorista

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Monta zoom campo Motorista
*/
//-----------------------------------
static Function SZoomPE(cModal)
   Local aRet := {}
   Local aFields := {}
   Local cSql

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

   cSql :=  "SELECT CASE LEN(A.PES_CPF) "
   cSql +=  "      WHEN 11 then "
   cSql +=  "         SUBSTRING(A.PES_CPF,1,3)++'.'++SUBSTRING(A.PES_CPF,4,3)++'.'++SUBSTRING(A.PES_CPF,7,3)++'-'++SUBSTRING(A.PES_CPF,10,2) "
   cSql +=  "      ELSE "
   cSql +=  "         A.PES_CPF "
   cSql +=  " END AS PES_CPF ,"
   cSql +=  " A.PES_NOME, A.PES_CNH, CONVERT(VARCHAR(10),A.PES_DT_CNH,103) AS PES_DT_CNH, A.PES_ID  "
   cSql +=  "  FROM TAB_PESSOAS A LEFT JOIN TAB_USUARIO_TIPO B ON A.PES_FUNCAO = B.USTIPO_ID "
   cSql +=  " WHERE (A.PES_BLOQUEIO = 0 OR A.PES_BLOQUEIO IS NULL) "
   if cModal == 'V'
      cSql += "    AND B.USTIPO_DESCRICAO = 'MOTORISTA' AND PES_CNH IS NOT NULL "
   ELSEIF cModal == 'F'
      cSql += "    AND B.USTIPO_DESCRICAO = 'MAQUINISTA'"   
   ELSE
      cSql += "    AND B.USTIPO_DESCRICAO = 'COMANDANTE'"
   EndIf
   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY A.PES_ID')

              //aFields,   cCampo         ,  cDesc        , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "PES_CPF"        , STR0242          , "C"  , 14      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "PES_NOME"       , cNomPes       , "C"  , 50      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "PES_CNH"        , STR0241          , "C"  , 25      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "PES_DT_CNH"     , STR0128       , "C"  , 10      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "PES_ID"         , cCodPes        , "N"  , 10      , 0        , ""      , .T.     , .F.)
   

	Aadd(aRet, aFields)

return aRet

//-----------------------------------
/*{Protheus.doc}
Zoom campo recinto

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Monta zoom campo recinto
*/
//-----------------------------------
static Function SZoomRC()
   Local aRet := {}
   Local aFields := {}
   Local cSql

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

   cSql :=  " SELECT A.REC_ID, A.REC_NOME "
//   cSql +=  "   FROM TAB_RECINTOS A, REL_USUARIO_RECINTO X "
	cSql +=  "   FROM TAB_RECINTOS A "
//   cSql +=  "  WHERE A.REC_ID = X.REC_ID "
//   cSql +=  "    AND X.USU_ID = '"+cUsuario+"'"
   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY A.REC_ID')

              //aFields, cCampo           ,  cDesc          , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "REC_ID"         , STR0003          , "N"  , 10      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "REC_NOME"       , STR0005          , "C"  , 50      , 0        , ""      , .T.     , .F.)
   Aadd(aRet, aFields)

return aRet

Function SZoomCL()
   Local aRet := {}
   Local aFields := {}
   Local cSql := ''
   Local lcgc := .T.
   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	If lcgc
		cSql := "   		select convert(varchar(15),a.cli_cgc) as cli_cgc,convert(varchar(32),a.cli_nome) as cli_nome,convert(varchar(6),a.cli_id) as cli_id"
	Else
		cSql := "   		select convert(varchar(6),a.cli_id) as cli_id,convert(varchar(32),a.cli_nome) as cli_nome,convert(varchar(15),a.cli_cgc) as cli_cgc "
	EndIf
	cSql += "			from tab_clientes a                    "
	cSql += "			  inner join rel_tipo_cliente b  "
	cSql += "			    on a.cli_id = b.cli_id  "
	cSql += "			where b.tcli_id = 1    "

   if cEmpPai <> SGetTerm()
		cSql += " and exists (select 1  "
   		cSql += " from vw_portal_permissao_acesso "
       cSql += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "'"
       cSql += " and cli_id_acesso_info = a.cli_id) "
	endif

	Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY CLI_ID')

              //aFields,   cCampo         ,  cDesc          , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   If lcgc
   	   SAddPField(@aFields , "CLI_CGC"        , STR0262          , "C"  , 15     , 0        , ""      , .T.     , .T., .T., 1)
	   SAddPField(@aFields , "CLI_NOME"       , STR0130          , "C"  , 32      , 0        , ""      , .T.     , .F.)
	   SAddPField(@aFields , "CLI_ID"         , STR0129          , "C"  , 6       , 0        , ""      , .T.      , .F.)
   Else
   SAddPField(@aFields , "CLI_ID"         , STR0129          , "C"  , 6       , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "CLI_NOME"       , STR0130          , "C"  , 32      , 0        , ""      , .T.     , .F.)
	   SAddPField(@aFields , "CLI_CGC"        , STR0262          , "C"  , 15     , 0        , ""      , .T.     , .T.)
   EndIf
   Aadd(aRet, aFields)

return aRet

static Function SZoomBK(cModelo,cCli_Id)
    Local aRet := {}
    Local aFields := {}
    Local cSql

	cSql := "   select convert(varchar(6),a.res_id) as res_id, "+;
		    "   a.res_numero, "+;
		    "   c.vei_id, "+;
		    "   e.nav_n2, "+;
		    "   b.vgm_numero, "+;
		    "   d.cli_id, "+;
		    "   d.cli_nome   "+;
			"	from tab_reserva a "+;
			"	  left outer join tab_viagem b "+;
			"	    on b.vgm_id = a.vgm_id "+;
			"	  left outer join tab_veiculos c "+;
			"	    on c.vei_id = b.vei_id   "+;
			"	  left outer join tab_clientes d "+;
			"	    on d.cli_id = a.cli_id   " +;
			"     left outer join tab_navios e "+;
            "          on e.nav_id = c.vei_id "+;
            "  where 1=1 "           

	cSql += "	and a.res_dt_fechamento is null and a.res_dt_cancelamento is null "

    Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)
    Aadd(aRet, cSql)
    Aadd(aRet, 'ORDER BY res_id')
    
              //aFields,   cCampo         ,  cDesc             , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
    SAddPField(@aFields , "res_id"         , 'Código'          , "C"  , 6       , 0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "res_numero"     , 'Reserva'         , "C"  , 20      , 0        , ""      , .T.     , .T., .T., 1)
	SAddPField(@aFields , "vei_id"         , 'IMO'             , "C"  , 11      , 0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "nav_n2"         , 'Navio'           , "C"  , 50      , 0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "vgm_numero"     , 'Viagem'          , "C"  , 10      , 0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "cli_id"         , 'Cód. do cliente' , "C"  , 6       , 0        , ""      , .T.     , .F.)
	SAddPField(@aFields , "cli_nome"       , 'Cliente'         , "C"  , 30      , 0        , ""      , .T.     , .F.)

	Aadd(aRet, aFields)

return aRet


static function SZoomCFOP()
   Local aRet := {}
   Local aFields := {}
   Local cSql := ''
   Local oModel    := FWModelActive()
   Local omodelDOC := oModel:GetModel('PRAA802DOC')

	cSql := "	select a.cfop_id, "+;
			 "	       a.cfop_descricao "+;
			 "	from tab_cfop a       "+;
			"	  inner join rel_cfop_doc b "+;
			"	    on b.cfop_id = a.cfop_id "


	if alltrim(omodelDOC:getvalue('DOC_TPO_DC')) <> ''
   		cSql += "	where b.doc_id = '" + alltrim(omodelDOC:getvalue('DOC_TPO_DC'))+"'"
	else
		return aRet
   endif


   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)
   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY cfop_id')

              //aFields,   cCampo         ,  cDesc          , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "cfop_id"         , 'Código'          , "C"  , 6       , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "cfop_descricao"  , 'Descrição'      , "C"  , 100      , 0        , ""      , .T.     , .F.)

	Aadd(aRet, aFields)

return aRet

//-----------------------------------
/*{Protheus.doc}
Zoom campo sub-operacao

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Monta zoom campo sub-operacao
*/
//-----------------------------------
static Function SZoomSO(cModal,cOperacao)
   Local aRet := {}
   Local aFields := {}
   Local cSql

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)
   if AllTrim(cOperacao) == ""
      cOperacao := "-1"
   EndIf

   cSql :=  " SELECT SUB_ID, SUB_DESCRICAO "
   cSql +=  "  FROM TAB_SUB_OPERACAO "
   cSql +=  " WHERE SUB_MODAL = '"+cModal+"' "
   cSql +=  " AND OP_ID = "+cOperacao


   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY SUB_ID')
              //aFields, cCampo           ,  cDesc          , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "SUB_ID"         , STR0037          , "N"  , 10      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "SUB_DESCRICAO" , STR0039          , "C"  , 50      , 0        , ""      , .T.     , .F.)

	Aadd(aRet, aFields)

return aRet

//-----------------------------------
/*{Protheus.doc}
Zoom campo veiculo relacionado

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Monta zoom campo veiculo relacionado
*/
//-----------------------------------
static Function SZoomVR(cSubOp, cRecinto)
   Local aRet := {}
   Local aFields := {}
   Local cSql
   Local tTabSubope := GetNextAlias()
   Local tTabModulo := GetNextAlias()
   Local cUsaMaritimo
   Local cModalRel

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)
   if AllTrim(cSubOp) == ""
      cSubOp := "-1"
   EndIf
   if AllTrim(cRecinto) == ""
      cRecinto := "-1"
   EndIf

   cQuery := " SELECT CAST(MOD_LIBERADO AS VARCHAR(1)) AS MOD_LIBERADO FROM TAB_MODULO WHERE MOD_ID = 'SARA_MAR'"
   dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabModulo, .F., .T.)
   cUsaMaritimo := AllTrim((tTabModulo)->MOD_LIBERADO)
   (tTabModulo)->(DbCloseArea())

   cQuery := " SELECT REL_CESV_MODAL FROM TAB_SUB_OPERACAO WHERE SUB_ID = "+cSubOp
   dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),tTabSubope, .F., .T.)
   cModalRel := AllTrim((tTabSubope)->REL_CESV_MODAL)
   (tTabSubope)->(DbCloseArea())

   IF ((cUsaMaritimo == '1') .AND. (cModalRel == 'M'))
      cSql := " SELECT A.VEI_ID FROM TAB_PROG_MARITIMA P "
      cSql += " LEFT OUTER JOIN TAB_CESV B ON (P.CESV_ID = B.CESV_ID), "
      cSql += " TAB_VIAGEM A "
      cSql += " LEFT OUTER JOIN TAB_NAVIOS C ON (A.VEI_ID = C.NAV_ID) "
      cSql += " WHERE B.CESV_DT_SAIDA IS NULL "
      cSql += "   AND B.CESV_CANCELADA IS NULL "
      cSql += "   AND A.VGM_ID = P.VGM_ID "
      cSql += "   AND A.REC_ID  = "+cRecinto
   ELSE
      cSql := " SELECT A.VEI_ID FROM TAB_CESV  A, "
      cSql += " REL_CESV_RECINTOS B "
      cSql += " WHERE SUBSTRING(A.CESV_ID,5,1) = '"+cModalRel+"'"
      cSql += "   AND A.CESV_DT_SAIDA IS NULL "
      cSql += "   AND A.CESV_CANCELADA IS NULL  "
      cSql += "   AND A.CESV_ID = B.CESV_ID "
      cSql += "   AND B.REC_ID  = "+cRecinto
   EndIf
   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY A.VEI_ID')

              //aFields, cCampo           ,  cDesc          , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "VEI_ID"         , STR0002       , "C"  , 10      , 0        , ""      , .T.     , .T., .T., 1)
	Aadd(aRet, aFields)

return aRet

//-----------------------------------
/*{Protheus.doc}
Zoom campo tipo documento

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Monta zoom campo tipo documento
*/
//-----------------------------------
static Function SZoomTD(cEntradaSaida)
   Local aRet := {}
   Local aFields := {}
   Local cSql
   Local cTipoDoc := '(999)'

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

   if AllTrim(cEntradaSaida) == 'E'
      cTipoDoc := '(1,3)'
   EndIf
   if AllTrim(cEntradaSaida) == 'S'
      cTipoDoc := '(2,3)'
   EndIf
   If Empty(cEntradaSaida)
      cTipoDoc := '(1,2,3)'
   EndIf

   cSql :=  "SELECT DOC_ID, DOC_NOME FROM TAB_DOCUMENTOS "
   cSql +=  "WHERE DOC_TIPO IN"+cTipoDoc
   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY DOC_ID')

              //aFields,   cCampo           ,  cDesc             , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "DOC_ID"           , STR0062              , "C"  , 10      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "DOC_NOME"         , STR0123              , "C"  , 50      , 0        , ""      , .T.     , .F.)

   Aadd(aRet, aFields)

return aRet

//-----------------------------------
/*{Protheus.doc}
Zoom campo tipo documento

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Monta zoom campo tipo documento
*/
//-----------------------------------
static Function SZoomLI()
   Local aRet := {}
   Local aFields := {}
   Local oModel := FWModelActivate()
   Local oModelITC := omodel:getmodel('PRAA802ITC')
   Local cQuery := ''

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	   if alltrim(oModelITC:getvalue('ITC_LOT_ID')) <> ''
	   		cQuery := " select convert(varchar(16),a.latu_item) as num_item, "
			cQuery += "				       convert(varchar(16),a.loclo_qt) as qtde, "
			cQuery += "				       a.esp_id + " + "' - '" + " + c.esp_descricao as embalagem, "
			cQuery += "				      convert(varchar(16),a.loclo_m3_saldo) as m3, "
			cQuery += "				       a.latu_descricao        "
			cQuery += "				from vw_inventario_armazem a "
			cQuery += "				  inner join tab_clientes b "
			cQuery += "				    on a.ben_id = b.cli_id "
			cQuery += "				  inner join tab_especie c "
			cQuery += "				    on c.esp_id = a.esp_id   "
			cQuery += "				where loclo_qt > 0 "
	   		cQuery += " 				and a.latu_lote = '" + alltrim(oModelITC:getvalue('ITC_LOT_ID')) + "'"
	   		cQuery += "               and a.esp_id not in ('CC','OE') "
	   else
			return aRet
		endif



	Aadd(aRet, cQuery)
	Aadd(aRet, 'ORDER BY num_item')

   SAddPField(@aFields , "num_item"           , 'Item'         ,"C"  , 5      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "qtde"      			, 'Quantidade'    ,"C"  , 6      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "embalagem"      	, 'Embalagem'     ,"C"  , 40      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "m3"     				, 'Metros cúbico' ,"C"  , 10      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "latu_descricao"     , 'Descrição'    ,"C"  , 50      , 0        , ""      , .T.     , .F.)

   Aadd(aRet, aFields)

return aRet
//-----------------------------------
/*{Protheus.doc}
Zoom campo tipo documento

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Monta zoom campo tipo documento
*/
//-----------------------------------


static Function SZoomLT()
   Local aRet := {}
   Local aFields := {}
   Local oModel := FWModelActivate()
   Local oModelITC := omodel:getmodel('PRAA802ITC')
   Local oModelTMP := omodel:getmodel('PRAA802')
   Local cQuery := ''

	Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)


		if alltrim(oModelITC:getvalue('ITC_RES_NU')) <> ''
				cQuery := "			select distinct 							"
				cQuery += "			       a.latu_lote as num_lote,       "
				cQuery += "			       a.late_conhec as doc_lote,       "
				cQuery += "			       a.dent_format as doc_entrada,    "
				cQuery += "			       b.cli_id, "
				cQuery += "			       b.cli_nome, "
				cQuery += "			       c.res_id "
				cQuery += "			from vw_inventario_armazem a "
				cQuery += "			  inner join tab_clientes b "
				cQuery += "			    on a.ben_id = b.cli_id "
				cQuery += "			  inner join tab_reserva_doc_cnt c "
				cQuery += "			    on c.dent_id = a.dent_id "
				cQuery += "			where loclo_qt > 0   "
				cQuery += "			and b.cli_id = '" + alltrim(oModelTMP:getvalue('TMP_CLI_ID')) + "'"
				cQuery += "			and c.res_id = " +  alltrim(oModelITC:getvalue('ITC_RES_ID'))
				cQuery += "          and a.esp_id not in ('CC','OE')  "

				if alltrim(oModelITC:getvalue('ITC_DP_DS')) <> ''
					cQuery += "		and exists (select 1  "
					cQuery += "		            from tab_di_item c "
					cQuery += "		            where c.latu_lote = a.latu_lote "
					cQuery += "		            and c.latu_item = a.latu_item "
					cQuery += "		            and c.dsai_id = '" + alltrim(oModelITC:getvalue('ITC_DP_DS')) + "')"
				endif

				Aadd(aRet, cQuery)



				Aadd(aRet, 'ORDER BY num_lote')

			   SAddPField(@aFields , "num_lote"          , 'Lote'                    , "C"  , 15      , 0        , ""      , .T.     , .T., .T., 1)
			   SAddPField(@aFields , "doc_lote"        , 'Documento'                 , "C"  , 15      , 0        , ""      , .T.     , .F.)
			   SAddPField(@aFields , "doc_entrada"        , 'Documento de entrada'   , "C"  , 30      , 0        , ""      , .T.     , .F.)
			   SAddPField(@aFields , "cli_id"        , 'Código do cliente'           , "C"  ,6        , 0        , ""      , .T.     , .F.)
			   SAddPField(@aFields , "cli_nome"        , 'Cliente'                   , "C"  , 50      , 0        , ""      , .T.     , .F.)

			   Aadd(aRet, aFields)


	    else
	    		if alltrim(oModelTMP:getvalue('TMP_CLI_ID')) = ''
	    			alert('Operação negada. Preencha o cliente de carga para pesquisar o lote.')
	    			return aret
	    		endif

	    		cQuery := "			select distinct  "
				cQuery += "					       a.latu_lote as num_lote,   "
				cQuery += "					       a.late_conhec as doc_lote,  "
				cQuery += "					       a.dent_format as doc_entrada, "
				cQuery += "					       b.cli_id, "
				cQuery += "					       b.cli_nome "
				cQuery += "					from vw_inventario_armazem a "
				cQuery += "					  inner join tab_clientes b "
				cQuery += "					    on a.ben_id = b.cli_id "
				cQuery += "                   where loclo_qt > 0 "
				//cQuery += "			and b.cli_id = '" + alltrim(oModelTMP:getvalue('TMP_CLI_ID')) + "'"
				cQuery += "          and a.esp_id not in ('CC','OE')  "

				if alltrim(oModelITC:getvalue('ITC_DP_DS')) <> ''
					cQuery += "		and exists (select 1  "
					cQuery += "		            from tab_di_item c "
					cQuery += "		            where c.latu_lote = a.latu_lote "
					cQuery += "		            and c.latu_item = a.latu_item "
					cQuery += "		            and c.dsai_id = '" + alltrim(oModelITC:getvalue('ITC_DP_DS')) + "')"
				endif



				Aadd(aRet, cQuery)
				Aadd(aRet, 'ORDER BY num_lote')
			   SAddPField(@aFields , "num_lote"          , 'Lote'        				, "C"  , 15      , 0        , ""      , .T.     , .T., .T., 1)
			   SAddPField(@aFields , "doc_lote"        , 'Documento'   				   , "C"  , 15      , 0        , ""      , .T.     , .F.)
			   SAddPField(@aFields , "doc_entrada"        , 'Documento de entrada'   , "C"  , 30      , 0        , ""      , .T.     , .F.)
			   SAddPField(@aFields , "cli_id"        , 'Código do cliente'   			, "C"  , 6      , 0        , ""      , .T.     , .F.)
			   SAddPField(@aFields , "cli_nome"        , 'Cliente'   					, "C"  , 50     , 0        , ""      , .T.     , .F.)

			   Aadd(aRet, aFields)
		endif

return aRet

Static Function SZoomISO()
   Local aRet := {}
   Local aFields := {}
   Local cSql := ""

   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cSql += "select a.tiso_id,"
	cSql += "       a.tiso_tamanho tiso_ta,"
	cSql += "       b.mc_descricao mc_desc,"
	cSql += "       a.tiso_descricao tiso_de"
	cSql += " from tab_tipo_iso a"
	cSql += "  inner join tab_modelo_container b"
	cSql += "    on b.mc_id = a.mc_id"

   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY a.tiso_id')

              //aFields,   cCampo           ,  cDesc             , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "tiso_id"     , "Tipo ISO"             , "C"  , 4      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "tiso_ta"     , "Tamanho"              , "C"  , 2      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "mc_desc"     , "Modelo Container"     , "C"  , 50      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "tiso_de"   , "Descrição"            , "C"  , 50      , 0        , ""      , .T.     , .F.)

   Aadd(aRet, aFields)
Return aRet

Static Function SZoomVIAFE()
   Local aRet := {}
   Local aFields := {}
   Local cSql := ""
	Local oModel := FWModelActive()
   Aadd(aRet, INFO_ZOOM_TIPO_EXECUCAO_SQL)

	cSql += "SELECT"
	cSql += "    a.vf_id ZZ1_VIAGEM,"
	cSql += "    CONVERT(VARCHAR, a.vf_dt_prev_chegada, 103) ZZ1_DTCHEG,"
	cSql += "    CONVERT(VARCHAR, a.vf_dt_prev_chegada, 108) ZZ1_HRCHEG,"
	cSql += "    c.cli_nome ZZ1_DSOPFE,"
	cSql += "    e.rec_nome ZZ1_NMREOR,"
	cSql += "    a.vf_nr_vagao_cheio + a.vf_nr_vagao_vazio ZZ1_VAGPRE"

	cSql += "    FROM tab_viagem_ferroviaria a"

	cSql += "    INNER JOIN rel_trans_ben_com g"
	cSql += "    ON g.trans_id = a.cli_operador"

	cSql += "    INNER JOIN tab_clientes c"
	cSql += "    ON c.cli_id = g.ben_id"

	cSql += "    LEFT JOIN tab_recintos e "
	cSql += "    ON a.rec_origem = e.rec_id"

	cSql += "    WHERE a.vf_tipo_viagem  = 'E'"
	
	if(MV_PAR04 == 1)
	    cSql += "    AND a.vf_situacao <> 'F' 
	    cSql += "    AND a.vf_dt_cancelamento is null 
	else

		If ValType(oModel) != "U" .And. oModel:lActivate
			cSql += "    AND a.vf_situacao <> 'F'
		EndIf
	
	endif
	
	cSql += "    AND a.vf_dt_liberacao is not null "


   Aadd(aRet, cSql)
   Aadd(aRet, 'ORDER BY a.vf_id')

              //aFields,   cCampo           ,  cDesc             , cTipo, nTamanho, nPrecisao, cMascara, lVisivel, lRetorna
   SAddPField(@aFields , "ZZ1_VIAGEM"     , "Código viagem"        , "C"  , 8      , 0        , ""      , .T.     , .T., .T., 1)
   SAddPField(@aFields , "ZZ1_DTCHEG"     , "Previsão chegada"     , "C"  , 10      , 0        , ""      , .T.     , .F.)
   SAddPField(@aFields , "ZZ1_HRCHEG"     , "Previsão chegada"     , "C"  , 5      , 0        , "@E 99:99"      , .T.     , .F.)
   SAddPField(@aFields , "ZZ1_DSOPFE"     , "Operador ferroviário" , "C"  , 50     , 0        , ""      , .T.     , .T., .F.)
   SAddPField(@aFields , "ZZ1_NMREOR"     , "Terminal origem"      , "C"  , 8      , 0        , ""      , .T.     , .T., .F.)
   SAddPField(@aFields , "ZZ1_VAGPRE"     , "Vagões previstos"     , "N"  , 11      , 0        , "99999999999"      , .T.     , .T., .F.)

   Aadd(aRet, aFields)
Return aRet

//-----------------------------------
/*{Protheus.doc}
Zoom campo anexo

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Monta zoom campo anexo
*/
//-----------------------------------
Function PRAA802ARQ()
   cRetLkSara := cGetFile( STR0131+" (*.*) | *.* |" , , 0, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_NETWORKDRIVE ),.T., .T. )
Return .T.

Function WMSA802ARQ()
   cRetLkSara := cGetFile( STR0131+" (*.*) | *.* |" , , 0, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_NETWORKDRIVE ),.T., .T. )
Return .T.

//-----------------------------------
/*{Protheus.doc}
Criar botao abrir anexo

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Cria o botao para abrir anexo
*/
//-----------------------------------
Static Function BTN_ABRARQ( oPanel )
	DEFINE SBUTTON FROM 10, 4 TYPE 14 ACTION ABRARQ() STATUS ENABLE OF oPanel
Return NIL

//-----------------------------------
/*{Protheus.doc}
Abrir anexo

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Abrir anexo selecionado
*/
//-----------------------------------
Static Function ABRARQ()
Local oModel    := FWModelActive()
Local oModelANE := oModel:GetModel('PRAA802ANE')
Local NomeArquivo
Local cDirOpen := GetMV("MV_WMSANEP")
Local cArquivo := ""
   NomeArquivo := AllTrim(oModelANE:GetValue('ANE_ARQUIV'))

   IF NomeArquivo <> ''
      IF File(NomeArquivo, 1 ,.T.)
         ShellExecute( "open" , NomeArquivo , " " , " " , 1 )
      Else
         cArquivo := cDirOpen
         IF IsSrvUnix()
            IF right(cDirOpen,1) != "/"
               cDirOpen += "/"
            EndIf
         ELSE
            IF right(cDirOpen,1) != "\"
               cDirOpen += "\"
            EndIf
         EndIf

         IF IsSrvUnix()
            cArquivo += "/"
         ELSE
            cArquivo += "\"
         EndIf
	      cArquivo += NomeArquivo

         IF GetRemoteType() == 5 //Verifica se é WEB ou Desktop
            IF CPYS2TW(cArquivo, .T.) <> 0 //WEB
               MsgInfo(STR0132)
            EndIf
         ELSE
            CpyS2T(cDirOpen+NomeArquivo, GetTempPath(), .F. ) //Desktop
            shellExecute( "Open", GetTempPath()+NomeArquivo, "", cDirOpen,1)
         EndIf
      EndIf
   ELSE
      MsgInfo(STR0133)
   EndIf
Return .T.

//-----------------------------------
/*{Protheus.doc}
Atualizar registros do Browse

@author Marcelo Nunes
@version P12
@Since	12/04/13
@obs Atualizar registros do Browse
*/
//-----------------------------------
Function PRAA802ATU()
   dbSelectArea(cAliasTMP)
   ZAP
   dbSelectArea(cAliTMPEve)
   ZAP
   dbSelectArea(cAliTMPReb)
   ZAP
   dbSelectArea(cAliTMPDoc)
   ZAP
   dbSelectArea(cAliTMPAne)
   ZAP
   dbSelectArea(cAliTMPP)
   ZAP
   CAR_TABTMP(.T.)
Return .T.

Static Function SMGrdtoArr(oModel,cField,cBlock)
	Local aArray := {}
	Local nX
	Local uValue
	Local nLine

	Default cBlock := ""

	If Type("oModel:Length()") == "UI"
		nLine := oModel:nLine
		For nX := 1 to oModel:Length()

			If !oModel:IsDeleted(nX)

				If Empty(cBlock)
					uValue :=  oModel:GetValue(cField,nX)
				Else
					oModel:GoLine(nX)
					uValue := &(cBlock)
				EndIf

				If !Empty(uValue) .And. aScan(aArray,{|x|x == uValue}) == 0
					aAdd(aArray,uValue)
				EndIf

			EndIf
		Next nX
		oModel:GoLine(nLine)
	EndIf
Return aArray

Function A802VALEXEC(cOp,nOp)
	If IsInCallStack("EXECUTEMDEF")//Verifica se a chamada é pelo menu principal
//		MsgStop("Execute esta ação pelo menu príncipal.")
		lKill := .T.
//		Return
	EndIf
	If "VIEWDEF." $ cOp
		If nOp == 2
			FwExecView("Visualizar","PRAA802")
			CAR_TABTMP(.T.)
		ElseIf nOp == 3
		    vQtdReg := oBrowse:LogicLen()
			FwExecView("Incluir","PRAA802",nOp)			
			CAR_TABTMP(.T.)		
			oBrowse:refresh()
			if vQtdReg <> oBrowse:LogicLen()		    
			  oBrowse:GoBottom()
			endIf
			  	       		
		ElseIf nOp == 4
			FwExecView("Alterar","PRAA802",nOp)
			CAR_TABTMP(.T.)
		ElseIf nOp == 8
			FwExecView("Imprimir","PRAA802",nOp)
		EndIf
	Else
		//Macrosubstituição
		&(cOp)
	EndIf
Return

static function MenuDef()
   local aRotina := {}
   Local i := 1
   Local xRet := {}

   Default cTipomodal := ""

   ADD OPTION aRotina TITLE STR0079   ACTION 'A802VALEXEC("VIEWDEF.PRAA802",2)' OPERATION 2 ACCESS 0 DISABLE MENU  // 'Visualizar'
   ADD OPTION aRotina TITLE STR0080   ACTION 'A802VALEXEC("VIEWDEF.PRAA802",3)' OPERATION 3 ACCESS 0   // 'Incluir'
   ADD OPTION aRotina TITLE STR0081   ACTION 'A802VALEXEC("VIEWDEF.PRAA802",4)' OPERATION 4 ACCESS 0 DISABLE MENU   // 'Alterar'
   ADD OPTION aRotina TITLE STR0083   ACTION 'VIEWDEF.PRAA802' OPERATION 8 ACCESS 0 DISABLE MENU   // 'Imprimir'
   ADD OPTION aRotina TITLE STR0152   ACTION 'A802VALEXEC("A802EV()")' OPERATION 1 ACCESS 0 DISABLE MENU   // 'Eventos'
   ADD OPTION aRotina TITLE 'Cancelar/Estonar ag.'   ACTION 'A802VALEXEC("A802CANP()"),A802VALEXEC("A802REFR()")'OPERATION 1 ACCESS 0 DISABLE MENU   // Atualizar Tela
   ADD OPTION aRotina TITLE 'Liberar/Estornar ag.'   ACTION 'A802VALEXEC("A802LIB()")'  OPERATION 1 ACCESS 0 DISABLE MENU   // Liberar Programacao
   ADD OPTION aRotina TITLE STR0264   ACTION 'A802VALEXEC("A802REFR()")'  OPERATION 3 ACCESS 0 DISABLE MENU   // Atualizar grid
   ADD OPTION aRotina TITLE "Parâmetros"   ACTION 'A802VALEXEC("A802PARA()")'  OPERATION 3 ACCESS 0 DISABLE MENU   // Atualizar grid
   If Type("cTipoModal") == "C" .And. cTipoModal == "F"
   		ADD OPTION aRotina TITLE "Visualizar viagem"   ACTION  'A804VISVIAGEM((cAliasTMP)->TMP_VIAGEM)'  OPERATION 1 ACCESS 0 DISABLE MENU   // Liberar Programacao
   EndIf
   If Type("cTipoModal") == "C" .And. cTipoModal == "V"
      ADD OPTION aRotina TITLE "Minuta de Agendamento"   ACTION 'A802VALEXEC("A802MinutaAgendamento()")'  OPERATION 3 ACCESS 0 DISABLE MENU   // Atualizar grid   
   endif 
	if ExistBlock('A802MNU')
		xRet := ExecBlock('A802MNU')
		if ValType(xRet) = 'A'
			for i := 1 to Len(xRet)
				AAdd(aRotina, xRet[i])
			next
		endif
	endif

return aRotina

function A802REFR()
	If Type("cAliasTMP") != "C"
		Return
	EndIf
	Pergunte('PRAA802',.F.)
	CAR_TABTMP(.T.)
	oBrowse:refresh()
return

function A802PARA()
	Local nModalAtivo := MV_PAR01
	If Type("cAliasTMP") != "C"
		Return
	EndIf
	If !Pergunte('PRAA802',.T.,'Filtro do agendamento')
		MV_PAR01 := nModalAtivo
		A802CARPAR()
		Return
	EndIf
	A802CARPAR()
	If nModalAtivo != MV_PAR01 .Or. (MV_PAR01 == 2 .And. !Empty(MV_PAR05) .And. !A802VALVIG(MV_PAR05,'F', .F.) )
		If nModalAtivo != MV_PAR01
			MsgAlert("Não é possível alterar o Modal de Transporte")
		Else
			MsgAlert("Viagem Ferroviária inválida.")
		EndIf
		If !Pergunte('PRAA802',.T.,'Filtro do agendamento')
			MV_PAR01 := nModalAtivo
			A802CARPAR()
			Return
		EndIf
	EndIf
	MV_PAR01 := nModalAtivo
	If Empty(MV_PAR05)
		cVigCli  :=  ""
		cVigOp   :=  ""
		cVigTr   :=  ""
		cVigTrCgc := ""
	EndIf
	A802CARPAR()

	CAR_TABTMP(.T.)
	oBrowse:refresh()
Return

Function A802CARPAR()
	lTemDepot := A802DEPOT()

	if MV_PAR01 == 1
		cModal := 'V'
		cTipomodal := "V"
		cDescModal := STR0141
		cTipoPessoa := STR0070
		cCodPes := 'Motorista (CPF)'
		cCdPes2 := 'Motorista (CPF)'
		cNomPes := STR0022
		cNmPes2 := STR0023
		cCadPes := STR0073
	EndIF

	if MV_PAR01 == 2
		cModal := 'F'
		cTipomodal := "F"
		cDescModal := STR0142
		cTipoPessoa := STR0071
		cCodPes := 'Maquinista (CPF)'
		cCdPes2 := 'Maquinista (CPF)'
		cNomPes := STR0026
		cNmPes2 := STR0027
		cCadPes := STR0074
		cVigPar	:= MV_PAR05
		If Empty(cVigPar)
			cVigCli := cVigOp := cVigTr := cVigTrCgc := ""
		EndIf
	EndIF

	if MV_PAR01 == 3
		cModal := 'A'
		cTipomodal := "A"
		cDescModal := STR0143
		cTipoPessoa := STR0072
		cCodPes := 'Comandante (CPF)'
		cCdPes2 := 'Comandante (CPF)'
		cNomPes := STR0030
		cNmPes2 := STR0031
		cCadPes := STR0075
	EndIF
Return

static Function MntCargDad(cAliasTab,arrayDados, arrayCampos)

	Local nCont := 0
	Local nCont1   := 0

	//-------------------------------------------------------------------
	// Limpa tabela temporária
	//-------------------------------------------------------------------
	dbSelectArea(cAliasTab)
	(cAliasTab)->( dbSetOrder(1) )
	ZAP

	//-------------------------------------------------------------------
	// Carga de dados
	//-------------------------------------------------------------------
	For nCont := 1 To Len(arrayDados)
		RecLock(cAliasTab,.T.)
		For nCont1 := 1 To Len(arrayCampos)
			(cAliasTab)->&(arrayCampo[nCont1,1]) := arrayDados[nCont,nCont1]
		Next
		MsUnLock(cAliasTab)
	Next
	dbGoTop()
Return cAliasTab

Static Function GetStrAbox(aBox,cVal)
	Local aArr2 := {}
	Local nCont,nPos,cRet:=""
	For nCont :=1 to Len(aBox)
		If !Empty(aBox[ncont])
			aAdd(aArr2,STRTOKARR(aBox[ncont],"="))
		EndIf
	Next nCont
	If Len(aArr2) > 0
		nPos := aScan(aArr2,{|x|x[1]==cVal})
		If nPos > 0
			cRet := aArr2[nPos][2]
		EndIf
	EndIf
Return cRet

Static Function CarDocId()
	Local aArray := {{'',''}}
	Local cSql := " SELECT DOC_ID, DOC_ORDEM1 FROM TAB_DOCUMENTOS"
	Local tTabDocum := GetNextAlias()
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cSql),tTabDocum, .F., .T.)
	(tTabDocum)->(DbGoTop())
	While !(tTabDocum)->(Eof())
		aAdd(aArray,{AllTrim((tTabDocum)->DOC_ID),AllTrim((tTabDocum)->DOC_ORDEM1)})
		(tTabDocum)->(dbSkip())
	EndDo
	(tTabDocum)->(DbCloseArea())
Return aArray

Static Function GetDocId(cDocOrdem1)
	Local nX
	Local cRet := ''
	cDocOrdem1 := AllTrim(cDocOrdem1)
	If Type("aDocId") == "U"
		aDocId := CarDocId()
	EndIf
	nX := aScan(aDocId,{|x|x[2] == cDocOrdem1})
	If nX >0
		cRet := aDocId[nX][1]
	EndIf
Return cRet
// cParam, código do parametro
// uDefault, opcional, retorno se eof
// uDefault2, opcional, retorno se empty
Function GetSParam(cParam,uDefault,uDefault2,lMsg,lKill)
	Local uValue
	Local cQuery := "select param_valor pam from tab_parametro where param_desc = '" + cParam + "'"
	Local cAliasT := GetNextAlias()
	Default lMsg := .F.
	Default lKill := .F.
	cQuery := ChangeQuery(cQuery)
	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasT,.F.,.T.)
	If  (cAliasT)->(Eof())
		uValue := uDefault
		If lMsg .Or. lKill
			If lKill
				Final("Parâmetro " + cParam +  " não cadastrado.","Informe ao administrador do sistema.")
			Else
				MsgAlert("Parâmetro " + cParam +  " não cadastrado, informe ao administrador do sistema.")
			EndIf
		EndIf
	ElseIf Empty((cAliasT)->pam)
		uValue := uDefault2
		If lMsg .Or. lKill
			If lKill
				Final("Não foi informado nenhum valor para o parâmetro " + cParam +  ".","Informe ao administrador do sistema.")
			Else
				MsgAlert("Não foi informado nenhum valor para o parâmetro " + cParam +  ", informe ao administrador do sistema.")
			EndIf
		EndIf
	Else
		uValue := (cAliasT)->pam
	EndIf
	(cAliasT)->(dbCloseArea())
Return AllTrim(uValue)

Static Function GetCodViagem()
	If Type("cVigPar") == "C"
		Return cVigPar
	EndIf
Return ""

Static Function GetDsOpFerr()
	If Type("cVigCli") == "C"
		Return cVigCli
	EndIf
Return ""

Static Function GetDsOpVg()
	If Type("cVigOp") == "C"
		Return cVigOp
	EndIf
Return ""

Static Function GetDsTr()
	If Type("cVigTr") == "C"
		Return cVigTr
	EndIf
Return ""

Static Function GetTrCgc()
	If Type("cVigTrCgc") == "C"
		Return cVigTrCgc
	EndIf
Return ""

Static Function GetDpId(cPRG_ID,cDP_DS,cDP_ID)
	Local cAlias
	Local cQuery
	Local nDpId  := 0
	If !Empty(cDP_ID)
		Return Val(AllTrim(cDP_ID))
	EndIf
	cAlias := GetNextAlias()
	cQuery := "Select dp_id from rel_dent_programacao where prog_id =" + AllTrim(cPRG_ID) +  " and dent_id = '" + alltrim(cDP_DS) + "'"

	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQuery)),cAlias,.F.,.T.)
	If !(cAlias)->(Eof()) .And. !Empty((cAlias)->dp_id)
		nDpId := (cAlias)->dp_id
	EndIf
	(cAlias)->(dbCloseArea())
Return nDpId

Static Function GetCodTr(cCampo)
	If Type("cVigPar") == "C" .And. !Empty(cVigPar)
		    Return A802ATUTR(cVigPar,"",cCampo,.T.)
	EndIf
Return ""

Function A802VALVIG(cVig,cMod,lLimpa)
    //Local oView      := FWViewActive()
    Local oModel     := FWModelActive()
	Local oModGeral	
	Local lRet := .T.
	Local cQuery
	Local cAliasT
	Local cOperAg
	Local cOperVg
	
	Default lLimpa := .T.
	
	If !(Empty(M->TMP_VIAGEM))
	    cVig := M->TMP_VIAGEM
	EndIf

	If ValType(oModel) != "U" .And. Empty(cVig)
		oModGeral := oModel:GetModel("PRAA802")
		cVig := oModGeral:GetValue("TMP_VIAGEM")
	EndIf

	If cMod == "F"
		If Empty(cVig)
			If ValType(oModel) != "U"
				oModel:SetErrorMessage('PRAA802', 'TMP_VIAGEM',,,,"O código da viagem ferroviária deve estar preenchida quando o modal for ferroviário")
			EndIf
//			Help(,,'HELP',,"O código da viagem ferroviária deve estar preenchida quando o modal for ferroviário",1,0)
			lRet := .F.
		Else
			cQuery := "select a.vf_id ,b.cli_nome,g.cli_cgc cli_cgctr, g.cli_nome cli_nometr, c.op_descricao OPDESCR,CAST(a.op_id AS VARCHAR(10)) op_id"
			cQuery += " from tab_viagem_ferroviaria a"
			cQuery += " left JOIN rel_trans_ben_com d On d.trans_id = a.cli_operador"
   			cQuery += " left JOIN tab_clientes b ON b.cli_id = d.ben_id"
   			cQuery += " left JOIN rel_trans_ben_com f On f.trans_id = a.cli_transportador"
   			cQuery += " left JOIN tab_clientes g ON g.cli_id = f.ben_id"
   			cQuery += " LEFT JOIN TAB_OPERACAO c ON c.OP_ID = a.OP_ID"
			cQuery += " where a.vf_id = '" + cVig + "' and a.vf_tipo_viagem  = 'E' "
			If ValType(oModel) != "U" .And. oModel:lActivate
				cQuery += " and a.vf_situacao <> 'F'"
			EndIf
			cAliasT := GetNextAlias()
			cQuery := ChangeQuery(cQuery)
			DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasT,.F.,.T.)

			(cAliasT)->(dbGotop())
			If (cAliasT)->(Eof()) .Or. Empty((cAliasT)->vf_id)
				If ValType(oModel) != "U" .And. oModel:lActivate
					oModel:SetErrorMessage('PRAA802', 'TMP_VIAGEM',,,,"O código da viagem ferroviária não é valido")
					lRet := .F.
				EndIf
//				Help(,,'HELP',,"O código da viagem ferroviária é inválido",1,0)
			ElseIf ValType(oModel) != "U" .And. oModel:lActivate .And. lLimpa
				oModel:GetModel('PRAA802'):LoadValue('TMP_CLIFER',(cAliasT)->cli_nome)
				oModel:GetModel('PRAA802'):LoadValue('TMP_OPFER',(cAliasT)->OPDESCR)
			ElseIf ValType(oModel) != "U" .And. oModel:lActivate //Validação do Post do Model
				cOperAg := cValToChar(Val(oModel:GetModel('PRAA802'):GetValue("TMP_OPE_ID"))) //Operação Agendamento
				cOperVg := AllTrim((cAliasT)->op_id) //Operação viagem ferroviário
				If cOperVg $ "1;2;3"
					If !(cOperAg $ "1;2;3") .Or. (cOperAg != cOperVg .And. cOperAg != "3" .And. cOperVg != "3")
						oModel:SetErrorMessage('PRAA802', 'TMP_VIAGEM',,,,"A operação da viagem é incompatível com a operação do agendamento")
						lRet := .F.
					EndIf
				EndIf
			ElseIf Type("cVigPar") == "C" .And. !Empty(cVigPar) // Validação do pergunte
				cVigCli := (cAliasT)->cli_nome // Armazena o operador da viagem digitada no parâmetro
   				cVigOp  := (cAliasT)->OPDESCR // Armazena o cliente da viagem digitada no parâmetro
   				cVigTr  := (cAliasT)->cli_nometr // Armazena o cliente da viagem digitada no parâmetro
   				cVigTrCgc := (cAliasT)->cli_cgctr
			EndIf
			(cAliasT)->(dbCloseArea())
		EndIf

		if lLimpa .And. !(lRet)
			A802LC()
		endif
	EndiF

Return lRet

//Valida o digito verificador da identificação do vaão
Function A802VALDG(cPlaca)
	Local lRet := .T.
	Local nDigito := 0
	Local cPlc := SubStr(cPlaca,4)
      nDigito := (Val(substr(cPlc, 1, 1)) * 7) + (Val(substr(cPlc, 2, 1)) * 6) + (Val(substr(cPlc, 3, 1)) * 5) +;
                (Val(substr(cPlc, 4, 1)) * 4) + (Val(substr(cPlc, 5, 1)) * 3) + (Val(substr(cPlc, 6, 1)) * 2)

      nDigito := 11 - mod(nDigito,11)

      if nDigito == 10
        nDigito := 0
      elseif nDigito == 11
        nDigito := 1
	  EndIf
      if nDigito <>  Val(substr(cPlc, 7, 1))
      	lRet := .F.
      EndIf

Return {lRet,nDigito}

//Retorna a tara do veículo conforme o a placa
Function A802TaraVag(cIdVeic)
	Local nTara := 0
	Local cCodTar := SubStr(cIdVeic,3,1)
	If !Empty(cCodTar)
		if cCodTar == 'A'
	     nTara := 30
	   elseif cCodTar == 'B' .Or. cCodTar == 'P'
	     nTara := 47
	   elseif cCodTar == 'C' .Or. cCodTar == 'Q'
	     nTara := 64.5
	   elseif cCodTar == 'D' .Or. cCodTar == 'R'
	     nTara := 80
	   elseif cCodTar == 'E' .Or. cCodTar == 'S'
	     nTara := 100
	   elseif cCodTar == 'F' .Or. cCodTar == 'T'
	     nTara := 119.5
	   elseif cCodTar == 'G' .Or. cCodTar == 'U'
	     nTara := 143
	   elseif cCodTar == 'H'
	       nTara := 143
	   EndIf

	EndIf
Return nTara

//Retorna a marca do veículo conforme o a placa
Function A802MarVag(cIdVeic)
	Local nMarca := Nil
	Local cAliasT
	Local cQuery := "select marca_id from tab_marca_veiculo where marca_tipo_vagao = "

	If !Empty(SubStr(cIdVeic,1,1))
		cAliasT := GetNextAlias()
		cQuery += "'" + SubStr(cIdVeic,1,1) + "'"
		cQuery := ChangeQuery(cQuery)
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasT,.F.,.T.)
		(cAliasT)->(dbGoTop())
		If !(cAliasT)->(Eof()) .And. !Empty((cAliasT)->marca_id)
			nMarca := (cAliasT)->marca_id
		EndIf
		(cAliasT)->(dbCloseArea())
	EndIf

Return nMarca

//Retorna o modelo do veículo conforme o a placa
Function A802ModVag(cIdVeic)
	Local nModel := Nil
	Local cAliasT
	Local cQuery := "select modelo_id, modelo_descricao from tab_modelo_veiculo where modelo_vagao = "

	If !Empty(SubStr(cIdVeic,2,1))
		cAliasT := GetNextAlias()
		cQuery += "'" + SubStr(cIdVeic,2,1) + "'"
		cQuery := ChangeQuery(cQuery)
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasT,.F.,.T.)
		(cAliasT)->(dbGoTop())
		If !(cAliasT)->(Eof()) .And. !Empty((cAliasT)->modelo_id)
			nModel := (cAliasT)->modelo_id
		EndIf
		(cAliasT)->(dbCloseArea())
	EndIf
Return nModel
//Atualiza o transportador dos dados
Static Function A802ATUTR(cViagem,cTrp,cCampo,lInit)
	Local oModel := FwModelActive()
	Local cTransp := cTrp
	Local cQuery := ""
	Local cAliasT := GetNextAlias()
	Default lInit := .F.
	If ValType(oModel) != "U" .And. !lInit
		oModGeral := oModel:GetModel("PRAA802")
		cViagem := oModGeral:GetValue("TMP_VIAGEM")
	EndIf
	If Empty(cViagem)
		If lInit
			Return ""
		Else
			Return 
		EndIf
	EndIf
	
	/*
	adicionar ,"cli_Fer_nome")}) (cAliasT)->cli_nome
,"cli_Oper_nome")}) (cAliasT)->OPDESCR

	cQuery := "select a.vf_id ,b.cli_nome,g.cli_cgc cli_cgctr, g.cli_nome cli_nometr, c.op_descricao OPDESCR,CAST(a.op_id AS VARCHAR(10)) op_id"
			cQuery += " from tab_viagem_ferroviaria a"
			cQuery += " left JOIN rel_trans_ben_com d On d.trans_id = a.cli_operador"
   			cQuery += " left JOIN tab_clientes b ON b.cli_id = d.ben_id"
   			cQuery += " left JOIN rel_trans_ben_com f On f.trans_id = a.cli_transportador"
   			cQuery += " left JOIN tab_clientes g ON g.cli_id = f.ben_id"
   			cQuery += " LEFT JOIN TAB_OPERACAO c ON c.OP_ID = a.OP_ID"
			cQuery += " where a.vf_id = '" + cVig + "' and a.vf_tipo_viagem  = 'E' "
			oModel:GetModel('PRAA802'):LoadValue('TMP_CLIFER',)
				oModel:GetModel('PRAA802'):LoadValue('TMP_OPFER',)
	
	*/
	cQuery := "select vf_id,cli_transportador trp,d.cli_nome,d.cli_cgc,b.cli_nome cli_Fer_nome, c.op_descricao cli_Oper_nome from tab_viagem_ferroviaria a"+;
					"    INNER JOIN rel_trans_ben_com h"+;	
					"    ON h.trans_id = a.cli_transportador"+;
					"    INNER JOIN tab_clientes d"+;
					"    ON d.cli_id = h.ben_id"
	cQuery += " left JOIN rel_trans_ben_com f On f.trans_id = a.cli_operador"
   	cQuery += " left JOIN tab_clientes b ON b.cli_id = f.ben_id"
   	cQuery += " LEFT JOIN TAB_OPERACAO c ON c.OP_ID = a.OP_ID"
	cQuery += " where vf_id = '" + cViagem + "' and vf_tipo_viagem  = 'E' and vf_situacao <> 'F'"

	cQuery := ChangeQuery(cQuery)

	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasT,.F.,.T.)
	(cAliasT)->(dbGoTop())

	If !(cAliasT)->(Eof()) .And. !Empty((cAliasT)->vf_id)
		cTransp := cValToChar((cAliasT)->(&(cCampo))) 
	EndIf
	(cAliasT)->(dbCloseArea())
Return cTransp

Static Function A802ATUD(cViagem)
	Local cQuery := ""
	Local cAliasT := GetNextAlias()
	Local cData := ''

	cQuery := "select vf_id, CONVERT(VARCHAR, vf_dt_prev_chegada , 103) dtc, "
	cQuery += "CONVERT(VARCHAR, vf_dt_prev_saida , 103) dts, vf_tipo_viagem tp "
	cQuery += "from tab_viagem_ferroviaria where vf_id = '" + cViagem + "' and vf_tipo_viagem  = 'E' and vf_situacao <> 'F'"

	cQuery := ChangeQuery(cQuery)

	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasT,.F.,.T.)
	(cAliasT)->(dbGoTop())

	If !(cAliasT)->(Eof()) .And. !Empty((cAliasT)->vf_id)
		if (cAliasT)->tp == 'S'
			cData := (cAliasT)->dts
		else
			cData := (cAliasT)->dtc
		endif
	EndIf
	(cAliasT)->(dbCloseArea())
Return AllTrim(cData)

Static Function A802ATUH(cViagem)
	Local cQuery := ""
	Local cAliasT := GetNextAlias()
	Local cHora := ''

	cQuery := "select vf_id, CONVERT(VARCHAR, vf_dt_prev_chegada , 108) hc, "
	cQuery += "CONVERT(VARCHAR, vf_dt_prev_saida , 108) hs, vf_tipo_viagem tp "
	cQuery += "from tab_viagem_ferroviaria where vf_id = '" + cViagem + "' and vf_tipo_viagem  = 'E' and vf_situacao <> 'F'"

	cQuery := ChangeQuery(cQuery)

	DBUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasT,.F.,.T.)
	(cAliasT)->(dbGoTop())

	If !(cAliasT)->(Eof()) .And. !Empty((cAliasT)->vf_id)
		if (cAliasT)->tp == 'S'
			cHora := (cAliasT)->hs
		else
			cHora := (cAliasT)->hc
		endif
	EndIf
	(cAliasT)->(dbCloseArea())
Return SubStr(cHora, 1, 5)

Function A802CANESTP()
	Local cQuery
	Local cAlias := GetNextAlias()
	Local cMsg	:= "Cancelamentos das programações estornados."

	cQuery := " SELECT prog_id FROM TAB_programacao WHERE not dt_cancelamento is null and vf_id = '" + (cAliasTMP)->TMP_VIAGEM + "' and cesv_id is null"
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

	While !(cAlias)->(eof()) .And. !Empty((cAlias)->prog_id)

		TCSQLExec(" update tab_programacao set dt_cancelamento = null where prog_id = " + cValToChar((cAlias)->prog_id) )
       tcsqlexec('delete tab_programacao_eventos where eve_prog_id = (select max(eve_prog_id) from tab_programacao_eventos where prog_id = ' + cValToChar((cAlias)->prog_id)  + ' and eve_id = 8 )')

		(cAlias)->(dbskip())
	EndDo

	(cAlias)->(dbCloseArea())
	cQuery := " SELECT prog_id FROM TAB_programacao WHERE not dt_cancelamento is null and vf_id = '" + (cAliasTMP)->TMP_VIAGEM + "'"
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
	IF !(cAlias)->(eof()) .And. !Empty((cAlias)->prog_id)
		cMsg += "Com exceção das abaixo: " + CRLF
		While !(cAlias)->(eof()) .And. !Empty((cAlias)->prog_id)
			If nCont > 1
				cMsg += ","
			EndIf
			cMsg += cValToChar((cAlias)->prog_id)
			nCont++
			(cAlias)->(dbskip())
		EndDo
		MsgAlert(cMsg)
	Else
		MsgInfo(cMsg)
	EndIf
	(cAlias)->(dbCloseArea())
Return

Function A802CANPBAT()
	Local cQuery
	Local cAlias := GetNextAlias()
	Local cMsg	:= "Programações canceladas."

	cQuery := " SELECT prog_id FROM TAB_programacao WHERE dt_cancelamento is null and vf_id = '" + (cAliasTMP)->TMP_VIAGEM + "' and cesv_id is null"
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)

	While !(cAlias)->(eof()) .And. !Empty((cAlias)->prog_id)

		TCSQLExec(" update tab_programacao set dt_cancelamento = '" + SDBDate(Date(),time())+ "' where prog_id = " + cValToChar((cAlias)->prog_id) )
		(cAlias)->(dbskip())
	EndDo

	(cAlias)->(dbCloseArea())
	cQuery := " SELECT prog_id FROM TAB_programacao WHERE dt_cancelamento is null and vf_id = '" + (cAliasTMP)->TMP_VIAGEM + "'"
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
	IF !(cAlias)->(eof()) .And. !Empty((cAlias)->prog_id)
		cMsg += "Com exceção das abaixo: " + CRLF
		While !(cAlias)->(eof()) .And. !Empty((cAlias)->prog_id)
			If nCont > 1
				cMsg += ","
			EndIf
			cMsg += cValToChar((cAlias)->prog_id)
			nCont++
			(cAlias)->(dbskip())
		EndDo
		MsgAlert(cMsg)
	Else
		MsgInfo(cMsg)
	EndIf
	(cAlias)->(dbCloseArea())
Return
Static Function A802PREVLD(oModel,cModel)
	Local oModelCNT := oModel:GetModel('PRAA802CNT')
	Local oModelCRGS:= oModel:GetModel('PRAA802ITC') // Carregamento
	Local oModelDRGS:= oModel:GetModel('PRAA802ITD') // Recebimento
	Local oModelGEN:= oModel:GetModel(cModel)
	Local lVazio := .T.
	Local nI, nY
	Local aData

	If oModelGEN:IsDeleted() //A linha está apagada
		Return .T.
	EndIf
	
	If alltrim(SGetParam('PLANEJAMENTO_OPERACIONAL_DESCARGA_CARGA')) != 'S'
		Return .T.
	EndIf
	
	If cModel == 'PRAA802CNT'
		If !oModelCRGS:IsEmpty()
			aData := oModelCRGS:GETDATA()
			For nI := 1 To oModelCRGS:Length()
				If !oModelCRGS:IsDeleted(nI)
					For nY := 1 to Len(aData[nI][1][1])
						If !Empty(aData[nI][1][1][nY])
							lVazio := .F.
							Exit
						EndIf
					Next nY
				EndIf
				If !lVazio
					Exit
				EndIf
			Next nI

			If !lVazio                        
				alert('Não é possível informar containers pois já existe um carregamento de carga solta informada no agendamento.')
				Return .F.
			EndIf
		EndIf
		
		If !oModelDRGS:IsEmpty()
			aData := oModelDRGS:GETDATA()
			For nI := 1 To oModelDRGS:Length()
				If !oModelDRGS:IsDeleted(nI)
					For nY := 1 to Len(aData[nI][1][1])
						If !Empty(aData[nI][1][1][nY])
							lVazio := .F.
							Exit
						EndIf
					Next nY
				EndIf
				If !lVazio
					Exit
				EndIf
			Next nI

			If !lVazio
				alert('Não é possível informar containers pois já existe um recebimento de carga solta informada no agendamento.')
				Return .F.
			EndIf
		EndIf

	ElseIf cModel == 'PRAA802ITC' .Or. cModel == 'PRAA802ITD'
		If !oModelCNT:IsEmpty()
			For nI := 1 To oModelCNT:Length()
				If !oModelCNT:IsDeleted(nI)
					lVazio := .F.
					Exit
				EndIf
			Next nI

			If !lVazio
				alert('Não é possível informar uma carga solta pois já existe um container informado no agendamento.')
				Return .F.
			EndIf
		EndIf
	EndIf

Return .T.

Function SGetTerm()
	Local cAliasT
	Static _SGetQry := "select cli_id from tab_clientes where cli_cgc in (select sis_cgc from tab_sistema)"
	Static _SGetRet := ""
	If Empty(_SGetRet)
		cAliasT := GetNextAlias()
		DBUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(_SGetQry)),cAliasT,.F.,.T.)
		If (cAliasT)->(Eof()) .Or. Empty((cAliasT)->cli_id)
			(cAliasT)->(dbCloseArea())
			Final("Não há um cadastro do terminal na tabela de clientes.","Cadastre o CGC do terminal em um cliente.")
			Return ""
		Else
			_SGetRet := (cAliasT)->cli_id
			(cAliasT)->(dbCloseArea())
		EndIf
	EndIf
Return _SGetRet

Function SCodUsr()
	Local __SUsrSara := ''
	__SUsrSara := strtokarr(__ccredential,';')[4]
Return __SUsrSara

Function PRAA802VerificaCli(CPFCNPJ)

      Local cAlias := SGetNAlias()
      Local cQuery := "select cli_id from tab_clientes where cli_cgc = '"+CPFCNPJ+"' or cli_cpf = '"+CPFCNPJ+"'"
      Local uRet := nil

      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
      if (cAlias)->(!EOF())
            uRet := (cAlias)->(FieldGet(1))
      endif
      (cAlias)->(dbCloseArea())

return uRet

Function PRAA802ValidaCPFCNPJ(CPFCNPJ,op)   
   if (CGC(CPFCNPJ,,.F.) == .F.)
       if(op == 'M')
           MsgStop("O CPF informado é inválido.", "Aviso")
       else
          MsgStop("O CPF ou CNPJ informado é inválido.", "Aviso") 
       endif
	   Return .F.
   endif 
   
return .T.

Function PRAA802TipoCli(CPFCNPJ)
      Local cAlias  := SGetNAlias()
      Local cQuery  := "select tcli_id from rel_tipo_cliente where cli_id = (select cli_id from tab_clientes where cli_cgc = '"+CPFCNPJ+"' or cli_cpf = '"+CPFCNPJ+"')"
      Local uRet    := nil

      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
      if (cAlias)->(!EOF())
            uRet := (cAlias)->(FieldGet(1))
      endif
      (cAlias)->(dbCloseArea())

return uRet

Function A802APCMID()
    Local cAlias := SGetNAlias()
    Local cQuery := ""

          cQuery += "select gru_id, cli_id, pcm_id from vw_portal_permissao_acesso "  
		  cQuery += " where usu_id = 'c"+SCodUsr()+"'"
		  cQuery += " and mod_id = 'SARA_WEB' "
		  cQuery += " and mnu_id = 'A'"

    dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
    if (cAlias)->(!EOF())
          cGRUID := (cAlias)->(FieldGet(1))
          cCLIID := (cAlias)->(FieldGet(2))
          cPCMID := (cAlias)->(FieldGet(3))
    endif
    (cAlias)->(dbCloseArea())
Return

Function A802APucID()
    Local cAlias := SGetNAlias()
    Local cQuery := ""

          cQuery += "select c.puc_id, c.pc_id from tab_portal_usuario_cliente c "
          cQuery += " inner join tab_portal_cliente p "
          cQuery += " on c.pc_id = p.pc_id "
		  cQuery += " where usu_id = 'c"+SCodUsr()+"'"

    dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
    if (cAlias)->(!EOF())
          cPUCID := (cAlias)->(FieldGet(1))
          cPCID := (cAlias)->(FieldGet(2))
    endif
    (cAlias)->(dbCloseArea())
Return


Function A802APAIID(idCliente)
    Local cAlias := SGetNAlias()
    Local cQuery := ""
          cQuery += "select pai_id from tab_portal_acesso_info where cli_id = '"+idCliente+"'"
    dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
    if (cAlias)->(!EOF())
          cPAIID := (cAlias)->(FieldGet(1))
    endif
    (cAlias)->(dbCloseArea())
    
return

Function PRAA802LD( oObj, lCopia,cAliasT )
	Local aArea   := GetArea() 
	Local aFields := {}
	Local aRet    := {} 
	Local cFields := 'R_E_C_N_O_'
	Local cTmp    := ''
	Local cQuery  := ''
	Local oGrid := oObj
	
	// Pega campos que fazem parte da estrutura do objeto, para otimizar retorno da query
	aFields := oGrid:GetStruct():GetFields()
	aEval( aFields, { |aX| IIf( !aX[MODEL_FIELD_VIRTUAL], cFields += ',' + aX[MODEL_FIELD_IDFIELD],) } )
	
	cTmp   := GetNextAlias() 
	cQuery := ""
	cQuery += "SELECT " + cFields + " FROM " + sGetRealName( cAliasT ) + " TAB"
	cQuery += " WHERE TAB.D_E_L_E_T_=' '"
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cTmp, .F., .T. ) 
	
	aRet := FWLoadByAlias( oGrid, cTmp ) 
	
	(cTmp)->( dbCloseArea() ) 
	
	RestArea( aArea ) 
Return aRet

static function PRAA802001RetornaCamposPesquisa(oModelDOC, aDados)
	local oview := FwViewActive()

   	if (alltrim(FwFldGet("TMP_OPE_ID")) == '1')
   		oModelDOC:setvalue('DOC_TPO_ES', 'S')
   	elseif (alltrim(FwFldGet("TMP_OPE_ID")) == '2')
   		oModelDOC:setvalue('DOC_TPO_ES', 'E')
   	endif

   oModelDOC:setvalue('DOC_RES_NU',alltrim(aDados[6]))
   oModelDOC:setvalue('DOC_ANO_DC',alltrim(aDados[3]))
   oModelDOC:setvalue('DOC_TPO_DC',alltrim(aDados[2]))   
   oModelDOC:setvalue('DOC_SER_DC',alltrim(aDados[4]))
   oModelDOC:setvalue('DOC_PRC_DC',alltrim(aDados[5]))
   oModelDOC:setvalue('DOC_CFOP',alltrim(aDados[7]))
   oModelDOC:setvalue('DOC_BEN_CG',alltrim(aDados[8]))
   
   if !Empty(oView) .And. oView:lActivate
   		oview:Refresh('PRAA802DOC')
   endIf

return .T.

static function PRAA802002RetornaPesqDocSaida(oModelDOC, aDados)
	local oview := FwViewActive()

   	if (alltrim(FwFldGet("TMP_OPE_ID")) == '1')
   		oModelDOC:setvalue('DOC_TPO_ES', 'S')
   	elseif (alltrim(FwFldGet("TMP_OPE_ID")) == '2')
   		oModelDOC:setvalue('DOC_TPO_ES', 'E')
   	endif

   oModelDOC:setvalue('DOC_ANO_DC',alltrim(aDados[2]))
   oModelDOC:setvalue('DOC_TPO_DC',alltrim(aDados[3]))   
   
   if alltrim(aDados[3]) == 'NF'
   		oModelDOC:setvalue('DOC_SER_DC',alltrim(aDados[4]))
   		oModelDOC:setvalue('DOC_PRC_DC',AllTrim(GETPSARA("PROC_NAC")))
   		oModelDOC:setvalue('DOC_CFOP',alltrim(aDados[5]))
  		oModelDOC:setvalue('DOC_BEN_CG',alltrim(aDados[7]))   
   endif
   
   if !Empty(oView) .And. oView:lActivate
   		oview:Refresh('PRAA802DOC')
   endIf

return .T.

//-----------------------------------
/*/{Protheus.doc} SQLSel001TabDocEntrada
@author Yuri Iuchi
@version P12
@Since	04072017
@obs Retorna SQL que lista os documentos relacionados a reserva
/*/
//-----------------------------------
Static function SQLSel001TabDocEntrada(cResId)
	Local cSql := ''
	cSql := "	select DISTINCT "
	cSql += "case when b.doc_id = 'NF' then "
   	cSql += "      substring(a.dent_id ,9 ,13) "
   	cSql += "  else "    
   	cSql += "     substring(a.dent_id ,6 ,16) " 
   	cSql += "  end as 'Nr. Doc2.', "
	cSql += " b.doc_id as 'Tp. Doc.', "           
	cSql += "     substring(a.dent_id ,1,4) as Ano, "
	cSql += "case when b.doc_id = 'NF' then "
   	cSql += "      substring(a.dent_id ,9 ,13) "
   	cSql += "  else "    
   	cSql += "     substring(a.dent_id ,6 ,16) " 
   	cSql += "  end as 'Nr. Doc.', "	 
   	cSql += "  case when b.doc_id = 'NF' then "
	cSql += "     substring(a.dent_id ,6 ,3) "
   	cSql += "  else "    
   	cSql += "     '' "
   	cSql += "  end as 'Série', "
   	cSql += "  c.proc_nome as 'Procedência', " 
   	cSql += "  d.res_numero as Reserva, "   
	cSql += "  a.cfop_id, " 
   	cSql += "  f.cli_cgc "      
   	cSql += "from " 
   	cSql += "  tab_tmp_doc_entrada a "
   	cSql += "  join tab_documentos b on substring(a.dent_id ,5,1) = b.doc_ordem1 "
   	cSql += "  join tab_procedencia c on substring(a.dent_id ,22,3) = c.proc_id "
	cSql += "  join tab_reserva d on a.res_id = d.res_id "  
	cSql += "  join tab_clientes f on a.ben_id = f.cli_id "	
	cSql += "where d.res_numero = " + "'" + cResId + "'"
return cSql

Static function SQLSel002DocEntrada(cNumRes)
	Local cSql := ''
	cSql := "	select 1"
	cSql := "   from tab_tmp_doc_entrada a   join tab_documentos b on substring(a.dent_id ,5,1) = b.doc_ordem1"
	cSql := "   join tab_reserva d on a.res_id = d.res_id 
    cSql := " where d.res_numero = '"+ cNumRes +"'"
    
    dbUseArea(.T., 'TOPCONN', TCGenQry(,,cSql),cAlias, .F., .T.)   
return cSql

//-----------------------------------
/*/{Protheus.doc} SQLSel003TabDocSaida
@author Rosiane de Avila
@version P12
@Since	16102017
@obs Retorna SQL que lista os documentos de saida relacionados a reserva
/*/
//-----------------------------------
Static function SQLSel003TabDocSaida(cResId,cNrDoc)
	Local cSql := ''
	
	Default cNrDoc := ''

	cSql := " select DISTINCT "+;
   			"    case when d.doc_id = 'NF' then "+; 
   			"      substring(c.dsai_id,9,9) "+;           
   			"    else "+; 
   			"      substring(c.dsai_id,6,15) "+; 
   			"    end as numero, "+;   	
			"    substring(c.dsai_id,1,4) as ano, "+; 
			"    d.doc_id as tipo_doc, "+; 
   			"    case when d.doc_id = 'NF' then "+; 
   			"         substring(c.dsai_id,6,3) "+; 
   			"    else "+; 
   			"         '''' "+;   
   			"    end as serie, "+;        
   			"    f.cfop_id, "+;
       	    "	  case when d.doc_id = 'NF' then "+;
        	"	   'NACIONAL' "+;      
        	"	  else "+;
        	"  		''''  "+;  
        	"	  end as procedendia, "+;
        	"  	  g.cli_cgc,  "+;
        	"  	  g.cli_id,   "+;
        	"  	  g.cli_nome  "+;		        
			"from tab_reserva_doc_cnt a "+; 
			"inner join rel_dent_cnt b "+; 
			"  on b.dent_id = a.dent_id "+; 
			"inner join tab_di_item c "+;  
			"  on c.latu_lote = b.lote_id "+;   
			"inner join tab_documentos d "+; 
			"  on d.doc_ordem1 = substring(c.dsai_id,5,1) "+;   
			"inner join tab_doc_saida e "+; 
			"  on e.dsai_id = c.dsai_id "+; 
			"left join tab_doc_saida_compl_nf f "+; 
			"  on e.dsai_id = f.dsai_id "+;   
			"left join tab_clientes g "+;  
			"  on e.ben_id = g.cli_id "+;     
			"where a.res_id = " + "'" + cResId + "'" 
			
	If !(Empty(cNrDoc))
	   cSql += " AND substring(c.dsai_id,6,15) = " + "'" + cNrDoc + "'"
	EndIf

return cSql

Static Function VAL0003ReservaPossuiPreCadastro(cNumRes)
Local cSql := ''
Local cAliasQry := GetNextAlias()
Local lRet

	cSql := "	select a.dent_id"
	cSql += "   from tab_tmp_doc_entrada a "
	cSql += "   join tab_reserva d on a.res_id = d.res_id 
	cSql += " where d.res_numero = '"+ ALLTRIM(cNumRes) +"'"
	
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
	
	If !(cAliasQry)->(Eof()) .Or. !Empty((cAliasQry)->dent_id)
		lRet := .T.
	Else
		lRet := .F.
	EndIf
	
	(cAliasQry)->(dbCloseArea())

return lRet


Static Function VAL0004PossuiRelReserva(cNumRes, cNumDoc, cNumCnt)
Local cSql := ''
Local cAliasQry := GetNextAlias()
Local lRet
    
	If cNumCnt == ''    
		cSql := "	select a.dent_id as id_doc"
		cSql += "   from tab_tmp_doc_entrada a   join tab_documentos b on substring(a.dent_id ,5,1) = b.doc_ordem1"
		cSql += "   join tab_reserva d on a.res_id = d.res_id 
		cSql += " where d.res_numero = '"+ ALLTRIM(cNumRes) +"'"
		cSql += " and a.dent_id = '"+ ALLTRIM(cNumDoc) +"'"
	Else
	    cSql := " select c.rcnt_id as id_doc  " 
		cSql += "	from tab_reserva a "   	
		cSql += "	inner join tab_reserva_programacao b on b.res_id = a.res_id " 
		cSql += "	inner join tab_reserva_container c on c.trp_id = b.trp_id " 
		cSql += "	left outer join tab_reserva_rateio_cnt d on d.rcnt_id = c.rcnt_id " 
		cSql += "	inner join tab_container e on e.cnt_id = c.cnt_id  " 
		cSql += "	where a.res_numero = '"+ ALLTRIM(cNumRes) +"' " 
		If !Empty(cNumDoc)	
			cSql += "	  and d.dent_id = '"+ alltrim(cNumDoc) +"'"
		EndIf 	
		cSql += "	and c.cnt_id  = '"+ ALLTRIM(cNumCnt) +"' "      
   EndIf                    
	
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
	
	If !(cAliasQry)->(Eof()) .Or. !Empty((cAliasQry)->id_doc)
		lRet := .T.
	Else
		lRet := .F.
	EndIf
	
	(cAliasQry)->(dbCloseArea())
return lRet

Static Function VAL0005RetornaCodTipoDoc(cTipoDoc)
Local cSql := ''
Local cAliasQry := GetNextAlias()
Local lRet

	cSql := " SELECT DOC_ORDEM1 FROM TAB_DOCUMENTOS WHERE DOC_ID = '"+AllTrim(cTipoDoc)+"'"
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cSql),cAliasQry, .F., .T.)
	lRet := AllTrim((cAliasQry)->DOC_ORDEM1)
	(cAliasQry)->(DbCloseArea())
	      
return lRet

Static function VAL0006ValidaProgramacaoCancelada(cProgId)
	Local lRet := .T.
	Local cQuery := ''
	Local cAliasCAN := GetNextAlias()

	cQuery := ' select CONVERT(VARCHAR,  dt_cancelamento, 103) as dt_cancelamento from tab_programacao where prog_id = ' + cProgId
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasCAN, .F., .T.)

	if alltrim((cAliasCAN)->dt_cancelamento) <> ''
	   lRet := .F.
	endif   

return lRet


Static Function VAL0007PossuiRelResSaida(cNumRes, cNumDoc, cNumCnt)
Local cSql := ''
Local cAliasQry := GetNextAlias()
Local lRet
    
	cSql := "select a.res_id "+;        
			 "from tab_reserva_doc_cnt a "+;
			 "inner join rel_dent_cnt b "+;
			 "  on b.dent_id = a.dent_id "+;
			 "inner join tab_di_item c "+;
			 "  on c.latu_lote = b.lote_id "+; 
			 "where c.dsai_id = '"+ ALLTRIM(cNumDoc) +"'"  

	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),cAliasQry,.F.,.T.)
	
	If !(cAliasQry)->(Eof()) .Or. !Empty((cAliasQry)->res_id)
		lRet := .T.
	Else
		lRet := .F.
	EndIf
	
	(cAliasQry)->(dbCloseArea())
return lRet

Static function STRVAL0001StringMenorIgual(oModelANE)
Local lFileName
	lFileName := AllTrim(oModelANE:GetValue('ANE_ARQUIV'))
	if len(lFileName) > 255
		alert('Caminho do arquivo muito grande! Tamanho deve ser menor ou igual a 255 caracteres!')
		//oModelANE:GetValue('ANE_ARQUIV'))
		oModelANE:setvalue('ANE_ARQUIV','')
	endif
return .T.

/*/{Protheus.doc} PRAA802CNT
//Esta função tem como objetivo de verificar se o campo documento na aba container não estiver
  vazio e preencher o campo container cheio para sim.
@author Mohamed S. B. Djalo
@since 23/10/2017
@version 12.1.17
@return .T.
@example
(examples)
@see (links_or_references)
/*/
Static Function PRAA802CNT()
	Local oModel    := FWModelActive()
	Local oModelCNT := oModel:GetModel('PRAA802CNT')
	Local lRet := .T.
	
	lRet := VALTPOPCNT(oModelCNT)
	
    If !Empty(alltrim(oModelCNT:getvalue('CNT_DP_DS'))) .And. lRet
        oModelCNT:loadvalue('CNT_CNTCHE','S')
    EndIf

Return lRet

/*/{Protheus.doc} A802CANP
@author Fernando da Cruz Pinheiro
@version P12
@Since	02/01/2014
@obs Realiza o cancelamento da programação.
/*/
function A802MinutaAgendamento()		
	Private cProg_ID := STransType((cAliasTMP)->TMP_PRG_ID,'C')

	if !VAL0006ValidaProgramacaoCancelada((cAliasTMP)->TMP_PRG_ID)
	   	Help(,,'HELP',,'A programação encontra-se cancelada e não pode impressa.',1,0)		
		return .F.	
	endif	

	PRAR802()

return

/*/{Protheus.doc} VALCNTTPES
//TODO Descrição auto-gerada.
Objetivo desta função é tratar o campo Tipo e/s na aba do container.
ao alterar o campo, 
@author Mohamed S. B. Djalo
@since 16/03/2018
@version undefined

@return lRet, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function VALCNTTPES()
    Local lRet      := .T.
    Local oModel    := FWModelActive()
	Local oModelCNT := oModel:GetModel('PRAA802CNT')
	
    oModelCNT:loadvalue('CNT_CNT_ID','')
	oModelCNT:loadvalue('CNT_TISO_I','')
	oModelCNT:loadvalue('CNT_TIS_TA','')
	oModelCNT:loadvalue('CNT_QTD_CN','')
	oModelCNT:loadvalue('CNT_DP_DS','')
	oModelCNT:loadvalue('CNT_DP_ID','')
		
Return lRet

/*/{Protheus.doc} VALTPOPCNT
//TODO Descrição auto-gerada.
Objetivo desta função é tratar o campo tipo de operação quando é informado o contêiner ou o tipo ISO
Se um desses campos for informado (Contêiner / Tipo ISO) o sistema deve obrigar o usuário informar o 
tipo de operação antes de prosseguir. A chamada desta função esta sendo feita em duas rotinas:
A802W_TISO_CNT() e PRAA802CNT()
@author Mohamed S. B. Djalo
@since 28/03/2018
@version undefined
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Function VALTPOPCNT(oModelCNT)
    Local lRet := .T.
    Local cMsg := 'É necessário selecionar o tipo de operação antes de prosseguir.'
	
    If(Empty(oModelCNT:GetValue('CNT_TPO_ES')))
        lRet := .F.
        Alert(cMsg)
    EndIf
	
Return lRet

Static Function A802DEPOT()
    Local lResult   := .F.
    Local cAlias    := SGetNAlias()
    Local cQuery    := "select reg_ativo from tab_regimes where reg_imp_exp = 'D' and reg_ativo = 1 "

    dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
    if (cAlias)->(!EOF())
           If ((cAlias)->reg_ativo == 1)
               lResult := .T.
           EndIf
    endif
    (cAlias)->(dbCloseArea())

return lResult

Static Function A802PROGRAM(cModelo)
    Local lResult   := A802Obriga(cModelo)
	Local oModel    := FWModelActive()
	Local oModelGEN := oModel:GetModel(cModelo)
    Local cAlias    := SGetNAlias() 
    Local cProg_ID  := ''
    Local cli_arma  := ''
    Local cQuery    := ''
    Local lCntDepot := 'N'
		  
    If lTemDepot
        lCntDepot := oModelGEN:GetValue('CNT_DEPOT')
        cProg_ID  := AllTrim(oModelGEN:GetValue('CNT_PROGRA'))
        cli_arma  := AllTrim(oModelGEN:GetValue('CNT_ARMADO'))
    EndIf
    
    If (AllTrim(lCntDepot) == 'S')	  
		If ((Empty(cProg_ID) .Or. (cProg_ID == '0')) .And. !lResult)
		    lResult := .T.
		Else 
		    If lTemDepot 
				If (oModelGEN:GetValue('CNT_DEPOT') == 'S')	  
				    If ((AllTrim(oModelGEN:GetValue('CNT_TPO_ES'))=='E') .Or. (AllTrim(oModelGEN:GetValue('CNT_TPO_ES'))=='ENTRADA'))
				        cQuery    += " select 1 as programacao          "                              
				        cQuery    += " from tab_prog_entrada_depot "
				        cQuery    += " where cli_armador = '" + cli_arma+ "' "
						cQuery    += " and ped_id = '" + cProg_ID + "'"
						cQuery    += " and ped_dt_fechamento is null "
					ElseIf((AllTrim(oModelGEN:GetValue('CNT_TPO_ES'))=='S') .Or. (AllTrim(oModelGEN:GetValue('CNT_TPO_ES'))=='SAIDA'))
					    cQuery    += " select 1 as programacao          "                              
				        cQuery    += " from tab_prog_saida_depot "
				        cQuery    += " where cli_armador = '" + cli_arma+ "' "
						cQuery    += " and psd_id = '" + cProg_ID + "'"
						cQuery    += " and psd_dt_fechamento is null "
				    EndIf
					    
					dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
					
				    If (cValToChar((cAlias)->programacao) == '1')
				        lResult := .T.
				    Else 
				        lResult := .F. 
				    EndIf
		
				    (cAlias)->(dbCloseArea())
				Else
				    lResult := .T.
				EndIf
			Else 
			    lResult := .T.
			EndIf
	    EndIf 
    EndIf
return lResult

Static Function A802Obriga(cModelo)

    Local lResult   := .F.
	Local oModel    := FWModelActive()
	Local oModelGEN := oModel:GetModel(cModelo)
	Local cAlias    := SGetNAlias() 
	Local lCntDepot := 'N'
    
    Local cQuery    := ''
    
    If lTemDepot
        lCntDepot := oModelGEN:GetValue('CNT_DEPOT')
    EndIf
    
    If (AllTrim(lCntDepot) == 'S')	 
	    cQuery := " select param_valor from tab_parametro where param_desc = 'DEPOT_REL_PROGRAMACAO_AGENDAMENTO_WEB_OBRIGATORIO' "
	    dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
	    If (AllTrim((cAlias)->param_valor) == '1')
	        lResult := .T.
	    EndIf
	    (cAlias)->(dbCloseArea())
    EndIf
    
return lResult

Static Function A802Clean(cModelo)
	Local oModel    := FWModelActive()
	Local oModelGEN := oModel:GetModel(cModelo)
	If lTemDepot 
		If( AllTrim(oModelGEN:GetValue('CNT_DEPOT')) == 'N' )
		    oModelGEN:LoadValue('CNT_ARMADO','')
		    oModelGEN:LoadValue('CNT_ARM_DS','')
		    oModelGEN:LoadValue('CNT_PROGRA','')		
		EndIf
	EndIf 
Return .T.

Static Function A802VLDARMAD(cModelo)
   Local oModel    := FWModelActive()
   Local oModelGEN := oModel:GetModel(cModelo)
   Local cSql      := ''
   Local lResult   := .F.
   Local cCodArmad := ''
   Local cAlias    := SGetNAlias() 
   
   If lTemDepot 
       cCodArmad := Trim(oModelGEN:GetValue('CNT_ARMADO'))
	   If (oModelGEN:GetValue('CNT_DEPOT') == 'S')
	  
		   If(!(Empty(cCodArmad))) 
		   
		       cSql := " select 1 as cod_armador from tab_armador b "
		       cSql += " inner join tab_clientes  a                 "
		       cSql += " on a.cli_id = b.cli_id                     "
		       cSql += " where b.cli_id = '" + cCodArmad + "'       "
			   
			   if cEmpPai <> SGetTerm()
					cSql += " and exists (select 1            "
			        cSql += " from vw_portal_permissao_acesso "
			        cSql += " where usu_id = '" + 'c' + alltrim(SCodUsr()) + "' and mnu_id = 'A'"
			        cSql += " and cli_id_acesso_info = a.cli_id) "
			   endif
			   
			   dbUseArea(.T., 'TOPCONN', TCGenQry(,,cSql),cAlias, .F., .T.)
			   If (AllTrim(cValToChar((cAlias)->cod_armador)) == '1')
			       lResult := .T.
			   Else 
			       lResult := .F.     
			   EndIf
			   
			   (cAlias)->(dbCloseArea())
		   
		   EndIf
	   Else
	       lResult   := .T.
	   EndIf
   Else 
       lResult := .T.
   EndIf
Return lResult

Static Function A802ISDEPOT(cModelo)
    Local oModel    := FWModelActive()
    Local oModelGEN := oModel:GetModel(cModelo)
    Local lResult   := .T.
    Local cCodArmad := ''
    
    If lTemDepot
        cCodArmad := Trim(oModelGEN:GetValue('CNT_ARMADO')) 
	    If oModelGEN:GetValue('CNT_DEPOT') == 'N'
	        MsgAlert("Para a operação Depot é necessário ativar o campo Operação Depot!")
	        lResult   := .F.
	    EndIf
	EndIf
     
Return lResult
