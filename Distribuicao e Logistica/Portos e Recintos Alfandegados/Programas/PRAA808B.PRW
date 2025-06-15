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

Function PRAA808B(cnpj_cpf,cTipoModal)
	Private cCgcExt := cnpj_cpf
	Static nTpModal := 0
	
	If cTipoModal == 'F'
	   nTpModal := 12 
	ElseIf cTipoModal == 'V'
	   nTpModal := 0 
	EndIf
	
	CriaTab()
	FwExecView('Novo motorista','PRAA808B',MODEL_OPERATION_INSERT)
Return Nil

Static Function CriaTab()
    Local aCampos := {{'ZZ1_ID'		,'N',01,0},;
					  {'ZZ1_NOME'	,'C',50,0},;
					  {'ZZ1_RG'		,'C',15,0},;
					  {'ZZ1_RGUF'	,'C',02,0},;
					  {'ZZ1_TPDOC'	,'C',01,0},;
					  {'ZZ1_PAIS'	,'C',30,0},;
					  {'ZZ1_CPF'	,'C',11,0},;
					  {'ZZ1_CNH'	,'C',20,0},;
					  {'ZZ1_EMISS'	,'D',01,0},;
					  {'ZZ1_ORGAO'	,'C',20,0},;
					  {'ZZ1_DTCNH'	,'D',01,0},;
					  {'ZZ1_CONTAT'	,'C',50,0}}
				  

	If Select("ZZ1PESSOAS") == 0
		CriaTabTmp(aCampos,{'ZZ1_ID'},"ZZ1PESSOAS")
		dbSelectArea("ZZ1PESSOAS")
	EndIf
	
Return 

Static Function ModelDef()
	Local oModel  	 := Nil
	Local oStructZZ1 := FWFormModelStruct():New()
	
	oStructZZ1:AddTable("ZZ1PESSOAS", {'ZZ1_ID'},"Cadastros")
	oStructZZ1:AddIndex(1,'01','ZZ1_ID','Indice 1','','',.T.)
	
	oStructZZ1:AddField("Nome",              "Nome",              'ZZ1_NOME'		,'C',50  ,0,Nil,{||.T.},Nil,.T.,,.F.,.F.,.F.)
	oStructZZ1:AddField("Tipo de documento", "Tipo de documento", 'ZZ1_TPDOC'       ,'C',1   ,0,{||.T.} ,{||.T.},{'1=RG','2=CNH','3=CTPS', '4=PASSAPORTE', '5=OUTROS', '6=FUNCIONAL'},.F.,,.F.,.F.,.F.)
	oStructZZ1:AddField("RG",                "RG",                'ZZ1_RG' 			,'C',15  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructZZ1:AddField("Orgão Emissor",     "Orgão Emissor",     'ZZ1_ORGAO'       ,'C',20  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructZZ1:AddField("Data de emissão",   "Data de emissão",   'ZZ1_EMISS'       ,'D',10  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructZZ1:AddField("UF",                "UF",                'ZZ1_RGUF'		,'C',16  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	oStructZZ1:AddField("País",              "País",              'ZZ1_PAIS'  		,'C',30  ,0,Nil,{||.T.},Nil,.F.,{|| 'BRASIL'},.F.,.F.,.F.)
	oStructZZ1:AddField("CPF",               "CPF",               'ZZ1_CPF'         ,'C',11  ,0,Nil,{||.T.},Nil,.T.,,.F.,.F.,.F.)
	oStructZZ1:AddField("Habilitação",       "Habilitação",       'ZZ1_CNH'         ,'C',30  ,0,Nil,{||.T.},Nil,.T.,,.F.,.F.,.F.)
	oStructZZ1:AddField("Data de validade",  "Data de validade",  'ZZ1_DTCNH'       ,'D',10  ,0,Nil,{||.T.},Nil,.T.,,.F.,.F.,.F.)
	oStructZZ1:AddField("Como contatar",     "Como contatar",     'ZZ1_CONTAT'      ,'C',50  ,0,Nil,{||.T.},Nil,.F.,,.F.,.F.,.F.)
	
	oModel := MPFormModel():New('PRAA808B',,{|oModel|A808BPOS(oModel)},{|oModel|A808BCOMMIT(oModel)},{|| FWFORMCANCEL(SELF)})
	
	oModel:SetDescription("Cadastros")
	oModel:AddFields('PRAA808B', Nil, oStructZZ1,,,)
	oModel:GetModel('PRAA808B'):SetDescription("Registros")
	oModel:SetPrimaryKey({'ZZ1_ID'})
	oModel:SetActivate({|oModel|A808BLOAD(oModel)})
   
Return oModel

Static Function ViewDef()
	Local oModel := FWLoadModel('PRAA808B')
	Local oStructZZ1	:= FWFormViewStruct():New()
	Local oView := Nil
	Local aArPais:= {''}
	Local aArUF  := {''}
	Local oChk := Nil
    Private lChk := .F.
    
    A808BUF(@aArUF)
	A808BPA(@aArPais)
	
	oStructZZ1:AddField("ZZ1_NOME",   "01","Nome",                    "Nome",                    /*aHelp*/,"C",   "@!",/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.F./*LINSERTLINE*/)
	oStructZZ1:AddField('ZZ1_TPDOC',  '03','Tipo de Documento',       'Tipo de Documento',       Nil,      'C',   "@!",Nil,Nil,.T.,Nil,Nil,{'1=RG','2=CNH','3=CTPS', '4=PASSAPORTE', '5=OUTROS', '6=FUNCIONAL'},Nil,nil,.F.,Nil,.F.)
	oStructZZ1:AddField("ZZ1_RG",     "04","Documento Identificação", "Documento Identificação", /*aHelp*/,"C",   "@!",/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.F./*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_ORGAO",  "05","Orgão",                   "Orgão",                   /*aHelp*/,"C",   "@!",/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_EMISS",  "06","Data de Emissão",         "Data de Emissão",         Nil,      'D',   "@!",Nil,Nil,.T.,Nil,'',nil,nil,Nil,.F.,Nil,.F.)
	oStructZZ1:AddField('ZZ1_RGUF',   '07',"UF",                      "UF",                      Nil,      'C',   "@!",Nil,Nil,.T.,Nil,'',aArUF,2,Nil,.F.,Nil,.F.)
	oStructZZ1:AddField('ZZ1_PAIS',   '08',"País",                    "País",                    Nil,      'C',   "@!",Nil,Nil,.T.,Nil,'',aArPais,30,Nil,.F.,Nil,.T.)
	oStructZZ1:AddField("ZZ1_CPF",    "02","CPF",                     "CPF",                     /*aHelp*/,"C",   "@R 999.999.999-99",Nil,""/*LOOKUP*/,/*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.T./*LINSERTLINE*/)
	oStructZZ1:AddField("ZZ1_CNH",    "09","Habilitação",             "Habilitação",             Nil,      'C',   "@!",Nil,Nil,.T.,Nil,'',nil,nil,Nil,.F.,Nil,.F.)
	oStructZZ1:AddField("ZZ1_DTCNH",  "10","Validade Habilitação",    "Validade Habilitação",    Nil,      'D',   "@!",Nil,Nil,.T.,Nil,'',nil,nil,Nil,.F.,Nil,.T.)                                
	oStructZZ1:AddField("ZZ1_CONTAT", "11","Como Contatar",           "Como Contatar",           /*aHelp*/,"C",   "@!",/*BPIC*/,/*LOOKUP*/,.T./*LCANCHANGE*/,/*CFOLDER*/,/*CGROUP*/,/*ACOMBOVALUES*/,/*NMAXLENCOMBO*/,/*CINIBRW*/,/*LVIRTUAL*/,/*CPICTVAR*/,.F./*LINSERTLINE*/)
	
    oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:CreateHorizontalBox( 'SUPERIOR' , 100,,,,)
	
	//TABELA PRINCIPAL
	oView:AddField('PRAA808B' , oStructZZ1)
	oView:SetOwnerView('PRAA808B', 'SUPERIOR')
	//Caso Alterar a situação, verificar se a nova faz parte do parâmetro de pesquisa
    //oView:SetCloseOnOk({|oModel|A804ViewClose(oModel)})
Return oView

//Validações do modelo de dados
Function A808BPOS(oModel)
	Local oModelTab := oModel:GetModel("PRAA808B")
	Local motoristacpf := AllTrim(oModelTab:GetValue("ZZ1_CPF"))
	
	If VerificaMotorista(motoristacpf) <> Nil
		oModel:SetErrorMessage('PRAA808B',,,,,"O motorista já está cadastrado no sistema." )
		Return .F.
	EndIf
	
	if( PRAA808BCPFCNPJ(AllTrim(oModelTab:GetValue("ZZ1_CPF"))) == .F.)
		lRet := .F. 
	endif
	
Return .T.

Function A808BLOAD(oModel)
	Local oModelForm := oModel:GetModel("PRAA808B")
	
 	oModelForm:LoadValue('ZZ1_CPF',cCgcExt)
Return .T.
//Gravação do modelo de daddos

Static Function A808BCOMMIT(oModel)
	Local lRet := .T.
	Local aResult := {}
	Local cErro
	Local aResult := {}
	Local cQueryConsulta := ''
	Local cAliasConsulta := SGetNAlias()
	Local cFunTipo  := ''
	Local cDocum    := ''
	Local nComita := 1
	Local oModelTab := oModel:GetModel("PRAA808B")
	Local dDataCnh := oModel:GetValue("PRAA808B","ZZ1_DTCNH")
	Local dDataEmis := oModel:GetValue("PRAA808B","ZZ1_EMISS")
	
	If Empty(dDataCnh)
		dDataCnh := ''
	Else
		dDataCnh := SDBDate(dDataCnh,"")
	EndIf
	
	If Empty(dDataEmis)
		dDataEmis := ''
	Else
		dDataEmis := SDBDate(dDataEmis,"")
	EndIf
	
	
    aResult := TCSPExec("proc_diu_pessoas_ws",;
						 2,;											          //@w_operacao            int
						 0,;                                                      //@w_pes_id              int          = null
						 AllTrim(oModel:GetValue("PRAA808B","ZZ1_NOME")),;        //@w_pes_nome            varchar(50)  = NULL,       
						 AllTrim(oModel:GetValue("PRAA808B","ZZ1_RG")),;          //@w_pes_rg              varchar(15)  = NULL,    
						 AllTrim(oModel:GetValue("PRAA808B","ZZ1_RGUF")),;        //@w_pes_rg_uf           char(2)      = NULL,    
						 nTpModal,;                                               //@w_pes_funcao          integer      = NULL, 
						 0,;                                                      //@w_pes_bloqueio        bit          = 0,     
						 val(AllTrim(oModel:GetValue("PRAA808B","ZZ1_TPDOC"))),;  //@w_pes_tipo_doc        int          = NULL, 
						 AllTrim(oModel:GetValue("PRAA808B",'ZZ1_PAIS')),;        //@w_pes_pais            char(30)     = NULL,    
						 AllTrim(oModel:GetValue("PRAA808B","ZZ1_CPF")),;         //@w_pes_cpf             char(11), 
						 AllTrim(oModel:GetValue("PRAA808B","ZZ1_CNH")),;         //@w_pes_cnh             varchar(20), 
						 dDataEmis,; //@w_pes_dt_emissao       datetime,  
						 AllTrim(oModel:GetValue("PRAA808B","ZZ1_ORGAO")),;       //@w_pes_orgao_emissor   varchar(20),   
						 dDataCnh,; //@w_pes_dt_cnh           datetime     = NULL, 
						 AllTrim(oModel:GetValue("PRAA808B","ZZ1_CONTAT")))       //@w_pes_contato         varchar(255) = NULL 
						
			      		 IF empty(aResult) .And. !Empty(TCSQLError())
							cErro := AllTrim(TCSQLError())
							oModel:SetErrorMessage('PRAA808B',,,,,cErro )
							Return .F.
						 End IF

  
Return .T.


Function PRAA808BRetorno(CPFCNPJ)

      Local cAlias := SGetNAlias()
      Local cQuery := "select cli_id from tab_clientes where cli_cgc = '"+CPFCNPJ+"' or cli_cpf = '"+CPFCNPJ+"'"
      Local uRet := nil

      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
      if (cAlias)->(!EOF())
            uRet := (cAlias)->(FieldGet(1))
      endif
      (cAlias)->(dbCloseArea())

return uRet

Function PRAA808BTransp(CPFCNPJ)

      Local cAlias := SGetNAlias()
      Local cQuery := "select cli_id from tab_clientes where cli_cgc = '"+CPFCNPJ+"' or cli_cpf = '"+CPFCNPJ+"'"
      Local uRet := nil

      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
      if (cAlias)->(!EOF())
            uRet := (cAlias)->(FieldGet(1))
      endif
      (cAlias)->(dbCloseArea())

return uRet

static Function A808BUF(aArUF)
	local cAliasUF := ''

	cAliasUF := SGetNAlias()
	cQuery := " select uf_id from tab_estado "
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasUF, .F., .T.)

	//Carga Combo Estado
	While (cAliasUF)->(!Eof())
		aAdd( aArUF, (cAliasUF)->(FieldGet(1)))
  		(cAliasUF)->(dbSkip())
	EndDo
Return .T.

static Function A808BPA(aArPais)
   local cAliasP := ''

	cAliasP := SGetNAlias()
	cQuery := " select pais_nome from tab_pais "
	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAliasP, .F., .T.)

    //Carga combo Pais
	While (cAliasP)->(!Eof())
		aAdd( aArPais,alltrim((cAliasP)->(FieldGet(1))))
  		(cAliasP)->(dbSkip())
	EndDo
Return .T.

Function VerificaMotorista(CPF)

      Local cAlias := SGetNAlias()
      Local cQuery := "select pes_id from tab_pessoas where pes_cpf = '"+CPF+"'"
      Local uRet := nil 

      dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery),cAlias, .F., .T.)
      if (cAlias)->(!EOF())
            uRet := (cAlias)->(FieldGet(1))
      endif
      (cAlias)->(dbCloseArea())
      
      /*if (uRet <> Nil)
	    uRet := 0
	  endif*/

return uRet

Function PRAA808BCPFCNPJ(CPFCNPJ)
   Local uRet := .F.
   
   if (CGC(CPFCNPJ,,.F.) == .F.)
       MsgStop("O CPF informado é inválido.","Aviso")
	   uRet := .F.
   else 
       uRet := .T.
   endif
   
return uRet
