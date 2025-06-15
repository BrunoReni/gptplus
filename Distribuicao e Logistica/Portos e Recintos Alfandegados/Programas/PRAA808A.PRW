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

//---------------------------------
/*{Protheus.doc}
Agendamento ferroviário
@param
@author Mohamed
@version P11
@since 25/06/2014
*/
//---------------------------------

Function PRAA808A(cnpj_cpf,tipoCad,tpAgend) //opcao{agendamento veiculo ou ferroviario}
	Static cVarEmp
	Static cVarAdm 
	Static cDescEmp
	Static cDescAdm
	Static cEmpPai
	Static cPCId
	Static cCli_id
	Static cUsuario                                                
	Static lAbreTela
	Static cGRUID
	Static cCLIID
	Static cPCMID
	Static cPUCID
	Static cPCID
	Static cPAIID
	Private tpAgenda := ""
	Private cCgcExt := cnpj_cpf
	Private cCAD := tipoCad

	Default tpAgend := ""

	tpAgend := tpAgend
	
	CriaTab()
	
	if(cCAD == 'C')
	    FwExecView('Novo Cliente','PRAA808A',MODEL_OPERATION_INSERT)
	elseif(cCAD == 'T')
	    FwExecView('Nova Transportadora','PRAA808A',MODEL_OPERATION_INSERT)
	elseif(cCAD == 'O')
	    FwExecView('Novo Operador','PRAA808A',MODEL_OPERATION_INSERT)
	endif
Return Nil

Static Function CriaTab()

	Local aCampos := {	{'ZZ1_TIPO'		,'C',01,0},;
						{'ZZ1_CODIGO'	,'C',06,0},;
						{'ZZ1_RAZAO'	,'C',50,0},;
						{'ZZ1_FANTAS'	,'C',50,0},;
						{'ZZ1_CNPJ'	    ,'C',21,0},;
						{'ZZ1_IE'	    ,'C',25,0},;
						{'ZZ1_GRUPO1'	,'L',01,0},;
						{'ZZ1_GRUPO2'	,'L',01,0},;
						{'ZZ1_GRUPO3'	,'L',01,0},;
						{'ZZ1_GRUPO4'	,'L',01,0},;
						{'ZZ1_GRUPO5'	,'L',01,0}}

	If Select("ZZ1CLIENTE") == 0
		CriaTabTmp(aCampos,{'ZZ1_CODIGO'},"ZZ1CLIENTE")
		dbSelectArea("ZZ1CLIENTE")
	EndIf
	
Return 

Static Function ModelDef()
	Local oModel  	 := Nil
	Local oStructZZ1 := FWFormModelStruct():New()
	Default tpAgenda := ""
	
	oStructZZ1:AddTable("ZZ1CLIENTE", {'ZZ1_CODIGO'},"Cadastros")
	oStructZZ1:AddIndex(1,'01','ZZ1_CODIGO','Indice 1','','',.T.)
	
	oStructZZ1:AddField("Tipo"     ,"Tipo"		,'ZZ1_TIPO','C',1 ,0  ,{||.T.} ,{||.T.}  				 ,{'1=Física','2=Jurídica','3=Estrangeiro'}   ,.F.       , ,.F.,.F.,.F.)
	
	
	oStructZZ1:AddField("Nome Razão", "Nome Razão", "ZZ1_RAZAO", "C",  50, 0, {||.T.},{||.T./*BWHEN*/},/*aValues*/,.T./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Nome Fantasia", "Nome Fantasia", "ZZ1_FANTAS", "C",  50, 0, {||.T.},{||.T./*BWHEN*/},/*aValues*/,.T./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ1:AddField("Inscrição Estadual", "Inscrição Estadual",  "ZZ1_IE",   "C",  25, 0, {||.T.},{||.T./*BWHEN*/},/*aValues*/,.F./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	oStructZZ1:AddField("Cliente (CNPJ/ CPF)","Cliente (CNPJ/ CPF)", "ZZ1_CNPJ", "C",  21, 0, {||.T.},{||.T./*BWHEN*/},/*aValues*/,.T./*LOBRIGAT*/, /*{||bInit}*/,/*lkey*/,/*lNoUpd*/,/*lVirtual*/,/*cValid*/)
	
	oStructZZ1:AddField("Importador",               "Importador",                'ZZ1_GRUPO1','L',1 ,0  ,{||.T.} ,{||.T.} ,{} ,.F. , ,.F.,.F.,.F.)
	oStructZZ1:AddField("Exportador",               "Exportador",                'ZZ1_GRUPO2','L',1 ,0  ,{||.T.} ,{||.T.} ,{} ,.F. , ,.F.,.F.,.F.)
	
	if(tpAgenda == 'A') .and. (cCAD == 'T')
	    oStructZZ1:AddField("Transportador Rodoviário",   "Transportador Rodoviário",    'ZZ1_GRUPO3','L',1 ,0  ,{||.T.} ,{||.T.} ,{} ,.F. ,{||.T.},.F.,.F.,.F.)
	else 
	    oStructZZ1:AddField("Transportador Rodoviário",   "Transportador Rodoviário",    'ZZ1_GRUPO3','L',1 ,0  ,{||.T.} ,{||.T.} ,{} ,.F. , ,.F.,.F.,.F.)
	endif
	
	if(tpAgenda == 'B') .and. ((cCAD == 'T') .or. (cCAD == 'O'))
	    oStructZZ1:AddField("Transportador Ferroviário","Transportador Ferroviário", 'ZZ1_GRUPO4','L',1 ,0  ,{||.T.} ,{||.T.} ,{} ,.F. ,{||.T.},.F.,.F.,.F.)
	else 
	    oStructZZ1:AddField("Transportador Ferroviário","Transportador Ferroviário", 'ZZ1_GRUPO4','L',1 ,0  ,{||.T.} ,{||.T.} ,{} ,.F. , ,.F.,.F.,.F.)
	endif
	
	oStructZZ1:AddField("Transportador Aéreo",      "Transportador Aéreo",       'ZZ1_GRUPO5','L',1 ,0  ,{||.T.} ,{||.T.} ,{} ,.F. , ,.F.,.F.,.F.)

    oModel := MPFormModel():New('PRAA808B',,{|oModel|A808ABPOS(oModel)},{|oModel|A808ABCOMMIT(oModel)} ,{|| FWFORMCANCEL(SELF)})
	oModel:SetDescription("Cadastros")
	oModel:AddFields('PRAA808A', Nil, oStructZZ1,,,)
	oModel:GetModel('PRAA808A'):SetDescription("Registros")
	oModel:SetPrimaryKey({'ZZ1_CODIGO'})
	oModel:SetActivate({|oModel|A808ALOAD(oModel)})
   
Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel('PRAA808A')
	Local oStructZZ1	:= FWFormViewStruct():New()
	Local oView := Nil
    Private lChk := .F.
	
	oStructZZ1:AddField('ZZ1_TIPO',  '01','Tipo','Tipo ',                                          Nil,      'GET',"@!",                   Nil,Nil,.T.,Nil,Nil,{'2=Jurídica','1=Física','3=Estrangeiro'},Nil,nil,.F.,Nil,.T.)
	oStructZZ1:AddField("ZZ1_RAZAO", "02","Nome Razão", "Nome Razão",                              /*aHelp*/,"C",  "@!"/*PIC*/,            /*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.F./*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_FANTAS","03","Nome Fantasia", "Nome Fantasia",                        /*aHelp*/,"C",  "@!"/*PIC*/,            /*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_CNPJ",  "04","Cliente (CNPJ/ CPF)", "Cliente (CNPJ/ CPF)",            /*aHelp*/,"C",  "@R 99.999.999/9999-99",{||S_PICPES(FwFldGet("ZZ1_CNPJ")) },""/*LOOKUP*/,.F./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.F./*LINSERTLINE*/)
	oStructZZ1:AddField('ZZ1_IE',    '05','Inscrição Estadual','Inscrição Estadual',               Nil,      'GET',"@!",                   Nil,Nil,.T.,Nil,Nil,{},Nil,nil,.F.,Nil,.T.)
	oStructZZ1:AddField('ZZ1_GRUPO1','06','Importador','Importador ',                              Nil,      'GET',"@!",                   Nil,Nil,.T.,Nil,Nil,{},Nil,nil,.F.,Nil,.F.)
	oStructZZ1:AddField('ZZ1_GRUPO2','07','Exportador','Exportador ',                              Nil,      'GET',"@!",                   Nil,Nil,.T.,Nil,Nil,{},Nil,nil,.F.,Nil,.F.)
	
	if(tpAgenda == 'A') .and. (cCAD == 'T')
	     oStructZZ1:AddField('ZZ1_GRUPO3','08','Transportador Rodoviário','Transportador Rodoviário',       Nil,      'GET',"@!",                   Nil,Nil,.F.,Nil,Nil,{},Nil,nil,.F.,Nil,.T.)
	else 
	     oStructZZ1:AddField('ZZ1_GRUPO3','08','Transportador Rodoviário','Transportador Rodoviário',       Nil,      'GET',"@!",                   Nil,Nil,.T.,Nil,Nil,{},Nil,nil,.F.,Nil,.T.)
	endif
	
	if(tpAgenda == 'B') .and. ((cCAD == 'T') .or. (cCAD == 'O'))
	     oStructZZ1:AddField('ZZ1_GRUPO4','09','Transportador Ferroviário','Transportador Ferroviário', Nil,      'GET',"@!",                   Nil,Nil,.F.,Nil,Nil,{},Nil,nil,.F.,Nil,.T.)
	else
	     oStructZZ1:AddField('ZZ1_GRUPO4','09','Transportador Ferroviário','Transportador Ferroviário', Nil,      'GET',"@!",                   Nil,Nil,.T.,Nil,Nil,{},Nil,nil,.F.,Nil,.T.)
	endif
	oStructZZ1:AddField('ZZ1_GRUPO5','10','Transportador Aéreo','Transportador Aéreo',             Nil,      'GET',"@!",                   Nil,Nil,.T.,Nil,Nil,{},Nil,nil,.F.,Nil,.T.)
    	
	
    oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:CreateHorizontalBox( 'SUPERIOR' , 100,,,,)
	//TABELA PRINCIPAL
	oView:AddField('PRAA808A' , oStructZZ1)
	oView:SetOwnerView('PRAA808A', 'SUPERIOR')
	//Caso Alterar a situação, verificar se a nova faz parte do parâmetro de pesquisa
    //oView:SetCloseOnOk({|oModel|A804ViewClose(oModel)})
Return oView

//Validações do modelo de dados
Function A808ABPOS(oModel)
    Local oModelForm := oModel:GetModel("PRAA808A")
	Local lRet := .T.
	
	//valida cnpj/cpf
	//lRet := CGC(alltrim(oModel:getvalue("PRAA808A",'ZZ1_CNPJ')))
	
	if( PRAA808ACPFCNPJ(AllTrim(oModelForm:GetValue("ZZ1_CNPJ"))) == .F.)
		return .F.
	endif
		
Return lRet

Function A808ALOAD(oModel)
	Local oModelForm := oModel:GetModel("PRAA808A")
	
	oModelForm:LoadValue('ZZ1_CNPJ',cCgcExt)
Return .T.
//Gravação do modelo de daddos

Function A808ABCOMMIT(oModel)
	Local lRet := .T.
	Local aResult := {}
	Local cErro
	Local cCpf := ""
	Local cCnpj := ""
	Local idCliente
	
	A808APCMID() //
	A808APucID()
	
	If oModel:GetValue("PRAA808A","ZZ1_TIPO") == "1"
		cCpf := AllTrim(oModel:GetValue("PRAA808A","ZZ1_CNPJ"))
	ElseIf oModel:GetValue("PRAA808A","ZZ1_TIPO") == "2"
		cCnpj := AllTrim(oModel:GetValue("PRAA808A","ZZ1_CNPJ"))
	EndIf
	
	if(cCAD == 'T') .and. (tpAgenda == 'A') //Se é tranportador e perfil A
	    if(oModel:GetValue("PRAA808A","ZZ1_GRUPO3") == .F.)
	        oModel:SetErrorMessage('PRAA808A',,,,, "É obrigatório selecionar o campo transportador rodoviário!")
		    Return .F.
	    endif
	endif
	
	if((cCAD == 'T') .or. (cCAD == 'O')) .and. (tpAgenda == 'B') //Se é tranportador e perfil B
	    if(oModel:GetValue("PRAA808A","ZZ1_GRUPO4") == .F.)
	        oModel:SetErrorMessage('PRAA808A',,,,, "É obrigatório selecionar o campo transportador ferroviário!")
		    Return .F.
	    endif
	endif
	
	if(cCAD == 'C') //se for cliente obrigar selecionar ou importador ou exportador
	    if(oModel:GetValue("PRAA808A","ZZ1_GRUPO1") == .F.) .and. (oModel:GetValue("PRAA808A","ZZ1_GRUPO2") == .F.)
	        oModel:SetErrorMessage('PRAA808A',,,,, "É obrigatório selecionar o campo importador ou exportador!")
		    Return .F.
	    endif
	endif
	
	/*//obrigar selecionar pelo menos um tipo
	if(oModel:GetValue("PRAA808A","ZZ1_GRUPO1") == .F.) .and. (oModel:GetValue("PRAA808A","ZZ1_GRUPO2") == .F.) .and.;
	  (oModel:GetValue("PRAA808A","ZZ1_GRUPO3") == .F.) .and. (oModel:GetValue("PRAA808A","ZZ1_GRUPO4") == .F.) .and.;
	  (oModel:GetValue("PRAA808A","ZZ1_GRUPO5") == .F.)
	     oModel:SetErrorMessage('PRAA808A',,,,, "É obrigatório selecionar pelo menos um tipo!")
		 Return .F.
	endif*/
	
	BeginTran() 

    aResult := TCSPExec("proc_diu_clientes1_wx",;						
   						2,; // @w_operacao	int
						Space(1),; // @w_cli_id	char	6
						AllTrim(oModel:GetValue("PRAA808A","ZZ1_RAZAO")),; // @w_cli_nome	varchar	50
						cCnpj,; // @w_cli_cgc	char	14
						cCpf,; // @w_cli_cpf	char	12
						 AllTrim(oModel:GetValue("PRAA808A","ZZ1_IE")),; // @w_cli_ie	char	25
						'',; // @w_arma_id	char	4
						AllTrim(oModel:GetValue("PRAA808A","ZZ1_FANTAS")),; // @w_cli_nomefan	char	30
						''; // @w_gru_id	char	6
					)   
					         
	IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
		cErro := AllTrim(TCSQLError())
		oModel:SetErrorMessage('PRAA808A',,,,,cErro )
		DisarmTransaction()
		lRet := .F.
	EndIF
	
	If lRet
		idCliente  := PRAA808ARetorno(alltrim(oModel:getvalue("PRAA808A",'ZZ1_CNPJ')))
    
		if(oModel:GetValue("PRAA808A","ZZ1_GRUPO1") == .T.) 
			aResult := TCSPExec("proc_diu_tipo_cliente_wx",2,cvaltochar(idCliente),1,Space(1)) //importador
		endif
	
		IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
			cErro := AllTrim(TCSQLError())
			oModel:SetErrorMessage('PRAA808A',,,,,cErro )
			DisarmTransaction()
			lRet := .F.
		EndIF
	     
        If lRet
			if(oModel:GetValue("PRAA808A","ZZ1_GRUPO2") == .T.) 
				aResult := TCSPExec("proc_diu_tipo_cliente_wx",2,cvaltochar(idCliente),3,Space(1)) //exportador
			endif
	
			IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
				cErro := AllTrim(TCSQLError())
				oModel:SetErrorMessage('PRAA808A',,,,,cErro )
				DisarmTransaction()
				lRet := .F.
			EndIF
	
	        If lRet
				if(oModel:GetValue("PRAA808A","ZZ1_GRUPO3") == .T.) 
					aResult := TCSPExec("proc_diu_tipo_cliente_wx",2,cvaltochar(idCliente),5,Space(1)) //transportador rodoviario
				endif
	
				IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
					cErro := AllTrim(TCSQLError())
					oModel:SetErrorMessage('PRAA808A',,,,,cErro )
					DisarmTransaction()
					lRet := .F.
				EndIF
	
	            If lRet
					if(oModel:GetValue("PRAA808A","ZZ1_GRUPO4") == .T.) 
						aResult := TCSPExec("proc_diu_tipo_cliente_wx",2,cvaltochar(idCliente),12,Space(1)) //transportador ferroviario
					endif
	
					IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
						cErro := AllTrim(TCSQLError())
						oModel:SetErrorMessage('PRAA808A',,,,,cErro )
						DisarmTransaction()
						lRet := .F.
					EndIF
	
					If lRet
						if(oModel:GetValue("PRAA808A","ZZ1_GRUPO5") == .T.) 
							aResult := TCSPExec("proc_diu_tipo_cliente_wx",2,cvaltochar(idCliente),11,Space(1)) //transportador aereo
						endif
	
						IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
							cErro := AllTrim(TCSQLError())
							oModel:SetErrorMessage('PRAA808A',,,,,cErro )
							DisarmTransaction()
							lRet := .F.
						EndIF
	
						If lRet 
							//libera acesso deste cliente 
							aResult := TCSPExec("proc_diu_portal_acesso_info_wx",;
									   2,;                        //@w_operacao int
									   0,;                        //@w_pai_id   int = null output
									   cPCMID,;                   //@w_pcm_id   int
									   cGRUID,;                   //@w_gru_id   char(6) = null
									   idCliente,;                //@w_cli_id   char(6) = null
									   SDBDate(date(),time()),;   //@w_pai_dt_cadastro   datetime = null
									   0,;                        //@w_pai_bloqueado     int
									   space(1);                  //@w_pai_dt_bloqueio   datetime = null
									   )
	           
							IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
								cErro := AllTrim(TCSQLError())
								oModel:SetErrorMessage('PRAA808A',,,,,cErro )
								DisarmTransaction()
								lRet := .F.
							EndIF
	
							If lRet
								A808APAIID(idCliente)
	
								//libera acesso deste cliente 
								aResult := TCSPExec("proc_portal_usu_menu_info_wx",;
										   2,;                        //@w_operacao int
										   0,;                        //@w_pumi_id  int = null,
										   cPUCID,;                   //@w_puc_id   int,
										   cPAIID,;                    //@w_pai_id   int,
										   SDBDate(date(),time());    //@w_pumi_dt_cadastro   varchar(19) = null
										   )
	           
								IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
									cErro := AllTrim(TCSQLError())
									oModel:SetErrorMessage('PRAA808A',,,,,cErro )
									DisarmTransaction()
									lRet := .F.
								EndIF
	
								If lRet
									//se for transportadora
									if(oModel:GetValue("PRAA808A","ZZ1_GRUPO3") == .T.) .or. (oModel:GetValue("PRAA808A","ZZ1_GRUPO4") == .T.) .or.;
									  (oModel:GetValue("PRAA808A","ZZ1_GRUPO5") == .T.)
										   //libera acesso deste cliente 
										   aResult := TCSPExec("proc_diu_cli_transportadora_wx",;
													  2,;                        //@w_operacao int
													  idCliente,;                //@w_cli_id   char(6),
													  0,;                        //@w_trans_id int = null output,
													  '',;                       //@w_permisso varchar(5) = null,
													  1;                         //@w_status int  
													  )
			           
										   IF empty(aResult) .and. AllTrim(TCSQLError()) <> ''
												cErro := AllTrim(TCSQLError())
												oModel:SetErrorMessage('PRAA808A',,,,,cErro )
												DisarmTransaction()
												lRet := .F.
										   EndIF
									endif
	
									If lRet
										//select pelo cgc do cliente
										/*idCliente := PRAA808ARetorno(alltrim(oModel:getvalue("PRAA808A",'ZZ1_CNPJ')))
	
										IF idCliente <> ''
     										oModel:LoadValue('ZZ1_CODIGO',idCliente)
										EndIf*/
	
										FwFormCommit(oModel)
	
										EndTran()
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
Return lRet

Function PRAA808ARetorno(CPFCNPJ)

      Local cAlias := SGetNAlias()
      Local cQuery := "select cli_id from tab_clientes where cli_cgc = '"+CPFCNPJ+"' or cli_cpf = '"+CPFCNPJ+"'"
      Local uRet := nil

      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
      if (cAlias)->(!EOF())
            uRet := (cAlias)->(FieldGet(1))
      endif
      (cAlias)->(dbCloseArea())

return uRet

Function PRAA808ACPFCNPJ(CPFCNPJ)
   Local uRet := .F.
   
   if (CGC(CPFCNPJ,,.F.) == .F.)
       MsgStop("O CPF ou CNPJ informado é inválido.", "Aviso")
	   uRet := .F.
   else 
       uRet := .T.
   endif
   
return uRet 

Function A808APCMID()
    Local cAlias := SGetNAlias()
    Local cQuery := ""
    Local lRet := .T.

	cQuery += "select gru_id, cli_id, pcm_id from vw_portal_permissao_acesso "  
	cQuery += " where usu_id = 'c"+SCodUsr()+"'"
	cQuery += " and mod_id = 'SARA_WEB' "
	cQuery += " and mnu_id = '"+tpAgenda+"'"

    dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
    if (cAlias)->(!EOF())
          cGRUID := (cAlias)->(FieldGet(1))
          cCLIID := (cAlias)->(FieldGet(2))
          cPCMID := (cAlias)->(FieldGet(3))
    endif
    (cAlias)->(dbCloseArea())
Return lRet

Function A808APucID()
    Local cAlias := SGetNAlias()
    Local cQuery := ""
    Local lRet   := .T. 

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
Return lRet

Function A808APAIID(idCliente)
    Local cAlias := SGetNAlias()
    Local cQuery := ""
    Local lRet   := .T.
          cQuery += "select pai_id from tab_portal_acesso_info where cli_id = '"+idCliente+"'"
    dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
    if (cAlias)->(!EOF())
          cPAIID := (cAlias)->(FieldGet(1))
    endif
    (cAlias)->(dbCloseArea())
    
return lRet

