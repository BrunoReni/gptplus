#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

Static lGA756ConfTit := .F.

Function GTPA756()

    Local oBrowse := Nil

    If ( !FindFunction("GTPHASACCESS") .Or.; 
	    ( FindFunction("GTPHASACCESS") .And. GTPHasAccess() ) ) 
            
        If ( VldDic() )

            oBrowse := FWMBrowse():New()
            oBrowse:SetAlias('H6K')
            oBrowse:SetDescription("Processo de Conserto de Bagagens")

            oBrowse:AddLegend("H6K_STATUS == '1'", "BLUE",  "A Consertar pela Empresa",             "LEGENDA", .T.)
            oBrowse:AddLegend("H6K_STATUS == '2'", "YELLOW","Enviado Fornecedor",   "LEGENDA", .T.)
            oBrowse:AddLegend("H6K_STATUS == '3'", "GREEN", "Recebido na Ag�ncia",  "LEGENDA", .T.)
            oBrowse:AddLegend("H6K_STATUS == '4'", "ORANGE","A Reembolsar",         "LEGENDA", .T.)
            oBrowse:AddLegend("H6K_STATUS == '5' .AND. EMPTY(H6K_NUM)", "RED",   "Finalizado",           "LEGENDA", .T.)
            oBrowse:AddLegend("H6K_STATUS == '6'", "BLACK", "Documento de retirada impresso", "LEGENDA", .T.)
            oBrowse:AddLegend("(H6K_STATUS == '5' .AND. !EMPTY(H6K_NUM)  )", "PINK",   "Reembolso efetuado","LEGENDA", .T.)

            If ( ! isBlind() )
                oBrowse:Activate()
            EndIf
            
            oBrowse:Destroy()
            R756DCloseWord()    //Fecha a conex�o com o MS Word
    
        EndIf

    EndIf

Return()

Static Function ModelDef()

    Local oModel    := Nil
    Local oStrH6K   := Nil
    Local oStrH6L   := Nil
    
    Local bPreLine  := {|oMdl,nLine,cAction,cField,uValue| VldPreLine(oMdl,nLine,cAction,cField,uValue)}
    Local bCommit   := {|oModel| GA756Commit(oModel)}
    Local bSetPost  := {|oMdl| ValidAllOK(oMdl)}

    oModel := MpFormModel():New("GTPA756")//, bPreValidacao, bPosValid, bCommit, /*bCancel*/ )
    oModel:SetVldActivate({|| VldDic()})
    
    ModelStruct(@oStrH6K,@oStrH6L)

    oModel:SetPost(bSetPost)
    oModel:SetCommit(bCommit)
    oModel:AddFields('H6KMASTER',/*cOwner*/,oStrH6K)
    oModel:AddGrid('H6LDETAIL','H6KMASTER',oStrH6L,bPreLine,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*BLoad*/)
    
    oModel:SetRelation('H6LDETAIL',{{ 'H6L_FILIAL','xFilial("H6L")'},{'H6L_CODH6K','H6K_CODIGO'}},H6L->(IndexKey(1)))

    oModel:SetDescription("Processo de conserto de Bagagens")

    oModel:SetPrimaryKey({'H6K_FILIAL','H6K_CODIGO'})

    

Return(oModel)

Static Function ViewDef()

    Local oModel    := ModelDef()
    Local oView     := Nil
    Local oStrH6K   := Nil
    Local oStrH6L   := Nil

    ViewStruct(@oStrH6K,@oStrH6L)
    
    oView	:= FWFormView():New()
    
    oView:SetModel(oModel)

    oView:AddField("VIEW_H6K",      oStrH6K,"H6KMASTER")
    oView:AddGrid("VIEW_H6L",       oStrH6L,"H6LDETAIL")
    
    oView:CreateHorizontalBox("UPPER" , 60)
    oView:CreateHorizontalBox("BOTTOM", 40)

    oView:SetOwnerView("VIEW_H6K",      "UPPER")
    oView:SetOwnerView("VIEW_H6L",      "BOTTOM")    

    oView:SetDescription("Processo de conserto de Bagagens")

    // oView:EnableTitleView('VIEW_H6K' , "Informa��es para o conserto")
    oView:EnableTitleView('VIEW_H6L' , "Listagem das bagagens danificadas")

    oView:AddIncrementField('VIEW_H6L','H6L_ITEM')
    
Return(oView)

Static Function ModelStruct(oStrH6K,oStrH6L,lNoInit,lNoTrig,lNoValid)
    
    Local bInit		:= Nil
    Local bTrig		:= Nil
    Local bValid    := Nil
                        
    Default lNoInit := .F.
    Default lNoTrig := .F.
    Default lNoValid := .F.

    bInit	:= Iif(!lNoInit,{|oMdl,cField,nLine| FieldInit(oMdl,cField,nLine)},Nil)
    bTrig	:= Iif(!lNoTrig,{|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)},Nil)
    bValid  := Iif(!lNoValid,{|oMdl,cField,uNewValue,uOldValue|;
                ValidField(oMdl,cField,uNewValue,uOldValue) },Nil)

    oStrH6K := FWFormStruct(1,'H6K')
    oStrH6L := FWFormStruct(1,'H6L')

    //Cria��o dos campos virtuais para a estrutura de H6K
    oStrH6K:AddField(	"Desc. Linha",;	            // 	[01]  C   Titulo do campo 
				 		"Descri��o da Linha",;	    // 	[02]  C   ToolTip do campo
				 		"H6KDESGI2",;	            // 	[03]  C   Id do Field
				 		"C",;		                // 	[04]  C   Tipo do campo
				 		TamSx3("GI2_DESCRI")[1],;	// 	[05]  N   Tamanho do campo
				 		0,;			                // 	[06]  N   Decimal do campo
				 		Nil,;		                // 	[07]  B   Code-block de valida��o do campo
				 		Nil,;		                // 	[08]  B   Code-block de valida��o When do campo
				 		Nil,;		                //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		                //	[10]  L   Indica se o campo tem preenchimento obrigat�rio
				 		bInit,;		        //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		                //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		                //	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
				 		.T.)		                // 	[14]  L   Indica se o campo � virtual  
    
    oStrH6K:AddField(	"Desc.Emp.For",;	            // 	[01]  C   Titulo do campo 
				 		"Descri��o Emp. Fornecedor",;   // 	[02]  C   ToolTip do campo
				 		"H6KDEMPFOR",;	                // 	[03]  C   Id do Field
				 		"C",;		                    // 	[04]  C   Tipo do campo
				 		TamSx3("A2_NOME")[1],;	        // 	[05]  N   Tamanho do campo
				 		0,;			                    // 	[06]  N   Decimal do campo
				 		Nil,;		                    // 	[07]  B   Code-block de valida��o do campo
				 		Nil,;		                    // 	[08]  B   Code-block de valida��o When do campo
				 		Nil,;		                    //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		                    //	[10]  L   Indica se o campo tem preenchimento obrigat�rio
				 		bInit,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		                    //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		                    //	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
				 		.T.)		                    // 	[14]  L   Indica se o campo � virtual  
    
    oStrH6K:AddField(	"Desc.Pas.For",;	            // 	[01]  C   Titulo do campo 
				 		"Desc. Passageiro Fornecedor",;  // 	[02]  C   ToolTip do campo
				 		"H6KDPASFOR",;	                // 	[03]  C   Id do Field
				 		"C",;		                    // 	[04]  C   Tipo do campo
				 		TamSx3("A2_NOME")[1],;	        // 	[05]  N   Tamanho do campo
				 		0,;			                    // 	[06]  N   Decimal do campo
				 		Nil,;		                    // 	[07]  B   Code-block de valida��o do campo
				 		Nil,;		                    // 	[08]  B   Code-block de valida��o When do campo
				 		Nil,;		                    //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		                    //	[10]  L   Indica se o campo tem preenchimento obrigat�rio
				 		bInit,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		                    //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		                    //	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
				 		.T.)		                    // 	[14]  L   Indica se o campo � virtual  
    
    oStrH6K:AddField(	"Desc. Agencia",;	            // 	[01]  C   Titulo do campo 
				 		"Descri��o da Ag�ncia",;        // 	[02]  C   ToolTip do campo
				 		"H6KDESCAGE",;	                // 	[03]  C   Id do Field
				 		"C",;		                    // 	[04]  C   Tipo do campo
				 		TamSx3("GI6_DESCRI")[1],;	    // 	[05]  N   Tamanho do campo
				 		0,;			                    // 	[06]  N   Decimal do campo
				 		Nil,;		                    // 	[07]  B   Code-block de valida��o do campo
				 		Nil,;		                    // 	[08]  B   Code-block de valida��o When do campo
				 		Nil,;		                    //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		                    //	[10]  L   Indica se o campo tem preenchimento obrigat�rio
				 		bInit,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		                    //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		                    //	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
				 		.T.)		                    // 	[14]  L   Indica se o campo � virtual  
        
    oStrH6K:AddField(	"Usr. Processo",;	            // 	[01]  C   Titulo do campo 
				 		"Nome Usuario Processo",;       // 	[02]  C   ToolTip do campo
				 		"H6KUSRNOME",;	                // 	[03]  C   Id do Field
				 		"C",;		                    // 	[04]  C   Tipo do campo
				 		80,;	                        // 	[05]  N   Tamanho do campo
				 		0,;			                    // 	[06]  N   Decimal do campo
				 		Nil,;		                    // 	[07]  B   Code-block de valida��o do campo
				 		Nil,;		                    // 	[08]  B   Code-block de valida��o When do campo
				 		Nil,;		                    //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		                    //	[10]  L   Indica se o campo tem preenchimento obrigat�rio
				 		bInit,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		                    //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		                    //	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
				 		.T.)		                    // 	[14]  L   Indica se o campo � virtual  
    
    oStrH6K:AddField(	"Usr. Envio",;	            // 	[01]  C   Titulo do campo 
				 		"Nome Usuario Envio For",;       // 	[02]  C   ToolTip do campo
				 		"H6KUSENVNM",;	                // 	[03]  C   Id do Field
				 		"C",;		                    // 	[04]  C   Tipo do campo
				 		80,;	                        // 	[05]  N   Tamanho do campo
				 		0,;			                    // 	[06]  N   Decimal do campo
				 		Nil,;		                    // 	[07]  B   Code-block de valida��o do campo
				 		Nil,;		                    // 	[08]  B   Code-block de valida��o When do campo
				 		Nil,;		                    //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		                    //	[10]  L   Indica se o campo tem preenchimento obrigat�rio
				 		bInit,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		                    //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		                    //	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
				 		.T.)		                    // 	[14]  L   Indica se o campo � virtual  
    
    oStrH6K:AddField(	"Usr. Receb.",;	            // 	[01]  C   Titulo do campo 
				 		"Nome Usuario Recebimento",;       // 	[02]  C   ToolTip do campo
				 		"H6KUSRECNM",;	                // 	[03]  C   Id do Field
				 		"C",;		                    // 	[04]  C   Tipo do campo
				 		80,;	                        // 	[05]  N   Tamanho do campo
				 		0,;			                    // 	[06]  N   Decimal do campo
				 		Nil,;		                    // 	[07]  B   Code-block de valida��o do campo
				 		Nil,;		                    // 	[08]  B   Code-block de valida��o When do campo
				 		Nil,;		                    //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		                    //	[10]  L   Indica se o campo tem preenchimento obrigat�rio
				 		bInit,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		                    //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		                    //	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
				 		.T.)		                    // 	[14]  L   Indica se o campo � virtual  
    
    oStrH6K:AddField(	"Usr. Receb.",;	            // 	[01]  C   Titulo do campo 
				 		"Nome Usuario Recebimento",;       // 	[02]  C   ToolTip do campo
				 		"H6KUSRETNM",;	                // 	[03]  C   Id do Field
				 		"C",;		                    // 	[04]  C   Tipo do campo
				 		80,;	                        // 	[05]  N   Tamanho do campo
				 		0,;			                    // 	[06]  N   Decimal do campo
				 		Nil,;		                    // 	[07]  B   Code-block de valida��o do campo
				 		Nil,;		                    // 	[08]  B   Code-block de valida��o When do campo
				 		Nil,;		                    //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		                    //	[10]  L   Indica se o campo tem preenchimento obrigat�rio
				 		bInit,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		                    //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		                    //	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
				 		.T.)		                    // 	[14]  L   Indica se o campo � virtual  
    
    oStrH6K:AddField(	"Usr. Reemb.",;	                // 	[01]  C   Titulo do campo 
				 		"Nome Usuario Reembolso",;      // 	[02]  C   ToolTip do campo
				 		"H6KUSREENM",;	                // 	[03]  C   Id do Field
				 		"C",;		                    // 	[04]  C   Tipo do campo
				 		80,;	                        // 	[05]  N   Tamanho do campo
				 		0,;			                    // 	[06]  N   Decimal do campo
				 		Nil,;		                    // 	[07]  B   Code-block de valida��o do campo
				 		Nil,;		                    // 	[08]  B   Code-block de valida��o When do campo
				 		Nil,;		                    //	[09]  A   Lista de valores permitido do campo
				 		.F.,;		                    //	[10]  L   Indica se o campo tem preenchimento obrigat�rio
				 		bInit,;		            //	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		                    //	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		                    //	[13]  L   Indica se o campo pode receber valor em uma opera��o de update.
				 		.T.)		                    // 	[14]  L   Indica se o campo � virtual  

    //Gatilho(s) da estrutura de H6K
    If ( ValType(bTrig) <> "U" )

        oStrH6K:AddTrigger("H6K_CODGI2",    "H6KDESGI2",   { || .T. }, bTrig)
        oStrH6K:AddTrigger("H6K_FOREMP",    "H6KDEMPFOR",  { || .T. }, bTrig)
        oStrH6K:AddTrigger("H6K_LJFOEM",    "H6KDEMPFOR",  { || .T. }, bTrig)
        oStrH6K:AddTrigger("H6K_FORPAS",    "H6KDPASFOR",  { || .T. }, bTrig)
        oStrH6K:AddTrigger("H6K_LJFOPA",    "H6KDPASFOR",  { || .T. }, bTrig)
        oStrH6K:AddTrigger("H6K_USUAR",     "H6KUSRNOME",  { || .T. }, bTrig)
        oStrH6K:AddTrigger("H6K_USRENV",    "H6KUSENVNM",  { || .T. }, bTrig)
        oStrH6K:AddTrigger("H6K_USRECE",    "H6KUSRECNM",  { || .T. }, bTrig)
        oStrH6K:AddTrigger("H6K_USRETI",    "H6KUSRETNM",  { || .T. }, bTrig)
        oStrH6K:AddTrigger("H6K_USREEM",    "H6KUSREENM",  { || .T. }, bTrig)
        oStrH6K:AddTrigger("H6K_AGENCI",    "H6KDESCAGE",  { || .T. }, bTrig) 
        
        //Gatilho(s) da estrutura de H6L
        oStrH6L:AddTrigger('H6L_VALOR', 'H6L_VALOR',  { || .T. }, bTrig)

    EndIf
        
    //Retirar as valida��es metadados
    oStrH6K:SetProperty('*', MODEL_FIELD_VALID, bValid)

Return()

Static Function ViewStruct(oStrH6K,oStrH6L)

    oStrH6K := FWFormStruct(2,'H6K')
    oStrH6L := FWFormStruct(2,'H6L')

    oStrH6L:RemoveField("H6L_CODH6K")

    SetHeader(oStrH6K)
    
Return()


Static Function MenuDef()

    Local aRotina       := {}
    Local aEnvio        := {}
    Local aReembolso    := {}

    //----------------------------------------------------------------------------------------------------------
    // Manuten��o do cadastro
    //----------------------------------------------------------------------------------------------------------
    ADD OPTION aRotina TITLE "Visualizar"   ACTION 'GA756Handler('+cValToChar(OP_VISUALIZAR)+')'    OPERATION OP_VISUALIZAR     ACCESS 0 
    ADD OPTION aRotina TITLE "Incluir"      ACTION 'GA756Handler('+cValToChar(OP_INCLUIR)+')'       OPERATION OP_INCLUIR	    ACCESS 0 
    ADD OPTION aRotina TITLE "Alterar"      ACTION 'GA756Handler('+cValToChar(OP_ALTERAR)+')'       OPERATION OP_ALTERAR	    ACCESS 0 
    ADD OPTION aRotina TITLE "Excluir"      ACTION 'GA756Handler('+cValToChar(OP_EXCLUIR)+')'       OPERATION OP_EXCLUIR	    ACCESS 0 
 
    //----------------------------------------------------------------------------------------------------------
    // Origem Empresa
    //----------------------------------------------------------------------------------------------------------
    ADD OPTION aRotina TITLE "Origem Empresa"               ACTION aEnvio               OPERATION OP_ALTERAR	    ACCESS 0 
        
        ADD OPTION aEnvio TITLE "1) Enviar/Desfazer"        ACTION 'GA756SkinProc("1")' OPERATION OP_ALTERAR	    ACCESS 0 
        ADD OPTION aEnvio TITLE "2) Receber/Desfazer"       ACTION 'GA756SkinProc("2")' OPERATION OP_ALTERAR	    ACCESS 0 
        ADD OPTION aEnvio TITLE "3) Retirar/Desfazer"       ACTION 'GA756SkinProc("3")' OPERATION OP_ALTERAR	    ACCESS 0 
        ADD OPTION aEnvio TITLE "Imp. Doc Retirada"         ACTION 'A756RDocPrt()'      OPERATION OP_ALTERAR	    ACCESS 0 
    
    //----------------------------------------------------------------------------------------------------------
    // Origem Passageiro
    //----------------------------------------------------------------------------------------------------------
    ADD OPTION aRotina TITLE "Origem Passageiro"            ACTION aReembolso           OPERATION OP_ALTERAR	    ACCESS 0 
        
        ADD OPTION aReembolso TITLE "Reembolsar/Estornar"   ACTION 'GA756SkinProc("4")' OPERATION OP_ALTERAR	    ACCESS 0 
        ADD OPTION aReembolso TITLE "Finalizar/Desfazer"    ACTION 'GA756SkinProc("5")' OPERATION OP_ALTERAR	    ACCESS 0 
        ADD OPTION aReembolso TITLE "Visual. Tit. Pagar"    ACTION 'GA756SkinProc("6")' OPERATION OP_ALTERAR	    ACCESS 0 

Return(aRotina)


Static Function VldDic(cMsgErro)

    Local aFieldsH6K   := {}
    Local aFieldsH6L   := {}

    Local lRet          := .T.

    Default cMsgErro    := ""
        
    AAdd(aFieldsH6K,"H6K_FILIAL")
    AAdd(aFieldsH6K,"H6K_CODIGO")
    AAdd(aFieldsH6K,"H6K_CODGI2")
    AAdd(aFieldsH6K,"H6K_CODGID")
    AAdd(aFieldsH6K,"H6K_DTVIAG")
    AAdd(aFieldsH6K,"H6K_CODGIC")
    AAdd(aFieldsH6K,"H6K_NOMEPS")
    AAdd(aFieldsH6K,"H6K_TELEFO")
    AAdd(aFieldsH6K,"H6K_EMAIL")
    AAdd(aFieldsH6K,"H6K_RGPASS")
    AAdd(aFieldsH6K,"H6K_ENDPAS")
    AAdd(aFieldsH6K,"H6K_CPENPS")
    AAdd(aFieldsH6K,"H6K_CEPPAS")
    AAdd(aFieldsH6K,"H6K_DTOCOR")
    AAdd(aFieldsH6K,"H6K_DTSLA")
    AAdd(aFieldsH6K,"H6K_OBSERV")
    AAdd(aFieldsH6K,"H6K_ORICON")
    AAdd(aFieldsH6K,"H6K_DOC")
    AAdd(aFieldsH6K,"H6K_SERIE")
    AAdd(aFieldsH6K,"H6K_FOREMP")
    AAdd(aFieldsH6K,"H6K_LJFOEM")
    AAdd(aFieldsH6K,"H6K_DOCONS")
    AAdd(aFieldsH6K,"H6K_FORPAS")
    AAdd(aFieldsH6K,"H6K_LJFOPA")
    AAdd(aFieldsH6K,"H6K_VLRDOC")
    AAdd(aFieldsH6K,"H6K_STATUS")
    AAdd(aFieldsH6K,"H6K_AGENCI")
    AAdd(aFieldsH6K,"H6K_USUAR")
    AAdd(aFieldsH6K,"H6K_DTENVI")
    AAdd(aFieldsH6K,"H6K_HRENVI")
    AAdd(aFieldsH6K,"H6K_USRENV")
    AAdd(aFieldsH6K,"H6K_DTRECE")
    AAdd(aFieldsH6K,"H6K_HRRECE")
    AAdd(aFieldsH6K,"H6K_USRECE")
    AAdd(aFieldsH6K,"H6K_DTRETI")
    AAdd(aFieldsH6K,"H6K_HRRETI")
    AAdd(aFieldsH6K,"H6K_USRETI")
    AAdd(aFieldsH6K,"H6K_DTREEM")
    AAdd(aFieldsH6K,"H6K_HRREEM")
    AAdd(aFieldsH6K,"H6K_USREEM")

    AAdd(aFieldsH6L,"H6L_FILIAL")
    AAdd(aFieldsH6L,"H6L_CODH6K")
    AAdd(aFieldsH6L,"H6L_ITEM")
    AAdd(aFieldsH6L,"H6L_DESCIT")
    AAdd(aFieldsH6L,"H6L_VALOR")

    lRet := GTPxVldDic("H6K",aFieldsH6K,.T.,.T.,@cMsgErro) .AND. GTPxVldDic("H6L",aFieldsH6L,.T.,.T.,@cMsgErro)

    If ( !Empty(cMsgErro) )
        FwAlertError("Dicion�rio desatualizado!", cMsgErro)
    EndIf

Return(lRet)

Function GA756Handler(nOpc)

    If nOpc == OP_INCLUIR
        FWExecView("Incluir Conserto de bagagens","VIEWDEF.GTPA756A",MODEL_OPERATION_INSERT,,{|| .T.})//,,80) 
    ElseIf ( nOpc == OP_ALTERAR .And. H6K->H6K_STATUS $ "1|4" )
        FWExecView("Conserto de bagagens","VIEWDEF.GTPA756",MODEL_OPERATION_UPDATE,,{|| .T.})//,,80) 
    ElseIf ( nOpc == OP_EXCLUIR .And. H6K->H6K_STATUS $ "1|4" )
        FWExecView("Conserto de bagagens","VIEWDEF.GTPA756",MODEL_OPERATION_DELETE,,{|| .T.})//,,80) 
    ElseIf ( nOpc == OP_VISUALIZAR )
        FWExecView("Conserto de bagagens","VIEWDEF.GTPA756",MODEL_OPERATION_VIEW,,{|| .T.})//,,80) 
    EndIf

Return()

Function GA756SkinProc(cOption)

    Local cMsg  := ""

    Local lContinue := .t.

    If ( cOption == "1" )
        
        If ( H6K->H6K_STATUS $ "1|2" )   //Processo de Conserto Iniciado
            
            If ( H6K->H6K_STATUS == "1" )
                cMsg := "Deseja enviar o processo de conserto para o Fornecedor?"
            Else
                cMsg := "Deseja desfazer o envio ao fornecedor?"
            EndIf

            If ( MsgYesNo(cMsg) ) 
                
                If ( H6K->H6K_STATUS == "1" )               
                    FWExecView("Enviar para o Fornecedor","VIEWDEF.GTPA756B",MODEL_OPERATION_UPDATE,,{|| .T.})
                Else
                    CursorWait()
                    BackEnvio()
                    CursorArrow()
                EndIf

            EndIf
        
        Else
            
            cMsg := "Somente processos de conserto '1-A Consertar pela Empresa' "
            cMsg += "e '2-Enviado Fornecedor' podem passar por esta etapa do processo. "
        
            FwAlertHelp("Status incorreto", cMsg)

        EndIf    
        
    ElseIf ( cOption == "2" )
        
        If ( H6K->H6K_STATUS $ "2|3" )   //Processo de Conserto Iniciado
            
            If ( H6K->H6K_STATUS == "2" )
                cMsg := "Deseja receber o processo de conserto do Fornecedor?"
            Else
                cMsg := "Deseja desfazer o recebimento do fornecedor?"
            EndIf

            If ( MsgYesNo(cMsg) )

                If ( H6K->H6K_STATUS == "2" )
                    FWExecView("Recebimento do Fornecedor","VIEWDEF.GTPA756C",MODEL_OPERATION_UPDATE,,{|| .T.}) 
                Else
                    CursorWait()
                    BackReceb()
                    CursorArrow()
                EndIf    
            
            EndIf            
        
        Else
            
            cMsg := "Somente processos de conserto '2-Enviado Fornecedor' "
            cMsg += "e '3-Recebido na Ag�ncia' podem passar por esta etapa do processo. "
        
            FwAlertHelp("Status incorreto", cMsg)

        EndIf    

    ElseIf ( cOption == "3" )

        If ( H6K->H6K_STATUS $ "3|5|6" .And. H6K->H6K_ORICON == "1" )
            
            If ( H6K->H6K_STATUS == "3" )
                cMsg := "Deseja realizar a retirada do conserto de bagagem?"
            Else
                cMsg := "A retirada pelo passaeiro j� fora realizada. Deseja desfazer esta etapa?"
            EndIf

            If ( MsgYesNo(cMsg) )

                If ( H6K->H6K_STATUS == "3" )
                    
                    lRet := Finaliza(.t.)

                    If ( lRet )
                    
                        If ( MsgYesNo("Deseja imprimir o documento de retirada?") )
                            A756RDocPrt()
                        EndIf
                    
                    EndIf

                Else
                    CursorWait()
                    BackFinaliza(.t.)
                    CursorArrow()
                EndIf

            EndIf
        
        Else
            
            cMsg := "Somente processos de conserto '3-Recebido na Ag�ncia', "
            cMsg += "'5-Finalizado' e '6-Documento de retirada impresso' podem passar por esta etapa do processo. "
        
            FwAlertHelp("Status incorreto", cMsg)

        EndIf

    ElseIf ( cOption == "4" )
        
        If ( H6K->H6K_STATUS $ "4|5" .And. H6K->H6K_ORICON == "2" )
            
            If ( H6K->H6K_STATUS == "4" )
                cMsg := "Deseja realizar o reembolso do conserto de bagagem"
            ElseIf ( !Empty(H6K->H6K_NUM) )
                cMsg := "Reembolso j� fora realizado. Deseja estorn�-lo?"
            Else
                lContinue := .F.
            EndIf        

            If ( lContinue .And. MsgYesNo(cMsg) )

                If ( H6K->H6K_STATUS == "4" )
                    FWExecView("Recebimento do Fornecedor","VIEWDEF.GTPA756E",MODEL_OPERATION_UPDATE,,{|| .T.}) 
                Else
                    CursorWait()
                    BackReemb()
                    CursorArrow()
                    
                EndIf

            EndIf
        
        Else

            cMsg := "Somente os consertos, em que o passageiro dever� ser reembolsado, "
            cMsg += "status '4-A Reembolsar' e '5-Finalizado', "
            cMsg += "podem passar por esta etapa do processo. "
        
            FwAlertHelp("Status incorreto", cMsg)

        EndIf

    ElseIf ( cOption == "5" )
        
        If ( H6K->H6K_ORICON == "2" .And. H6K->H6K_STATUS $ "4|5" .And. Empty(H6K->H6K_NUM) )
    
            If ( H6K->H6K_STATUS == "4" )// .And. Empty(H6K->H6K_NUM) )
                cMsg := "Deseja finalizar o processo de conserto de bagagem?"
            Else//If ( H6K->H6K_STATUS == "5" .And. Empty(H6K->H6K_NUM) .And. !Empty(H6K->H6K_FORPAS) )
                cMsg := "Deseja desfazer a finaliza��o do processo de conserto de bagagem?"
            EndIf        

            If ( MsgYesNo(cMsg) )            

                If ( H6K->H6K_STATUS == "4" .And. Empty(H6K->H6K_NUM) )
                    CursorWait()
                    Finaliza()
                    CursorArrow() 
                Else   
                    CursorWait()
                    BackFinaliza()
                    CursorArrow() 
                    
                EndIf

            EndIf

        Else
                       
            cMsg := "Somente os consertos, em que o passageiro dever� ser reembolsado, "
            cMsg += "status '4-A Reembolsar' e '5-Finalizado', "
            cMsg += "podem passar por esta etapa do processo. "
        
            FwAlertHelp("Status incorreto", cMsg)            

        EndIf
    
    ElseIf ( cOption == "6" )        
        VerTituloPagar()
    EndIf    

Return()

Static Function Envio(oModel)

    Local lRet := .T.

    lRet := oModel:GetModel("H6KMASTER"):SetValue("H6K_DTENVI",dDataBase) .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_HRENVI",StrTran(Time(),":","")) .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_USRENV",RetCodUsr()) .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_STATUS","2") //Altera Status para Enviado Fornecedor

Return(lRet)

Static Function BackEnvio(oModel)

    Local lRet          := .t.
    Local lInternExec   := .F.

    Default oModel := FwLoadModel("GTPA756")

    If ( !(oModel:IsActive()) )
        
        lInternExec := .T.
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()

    EndIf

    lRet := oModel:GetModel("H6KMASTER"):SetValue("H6K_STATUS","1") .And.;//Volta para Iniciado
            oModel:GetModel("H6KMASTER"):SetValue("H6K_USRENV","")  .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_DTENVI",SToD("")) .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_HRENVI","") .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_FOREMP","") .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_LJFOEM","")

    If ( lRet .And. lInternExec )
        
        If ( oModel:VldData() )
            lRet := oModel:CommitData()
        EndIf

        oModel:DeActivate()

    EndIf

Return(lRet)

Static Function Recebe(oModel)

    Local lRet  := .T.

    lRet := oModel:GetModel("H6KMASTER"):SetValue("H6K_DTRECE",dDataBase)               .And.; 
            oModel:GetModel("H6KMASTER"):SetValue("H6K_HRRECE",StrTran(Time(),":",""))  .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_USRECE",RetCodUsr())             .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_STATUS","3") //Altera Status para Recebido Fornecedor

Return(lRet)

Static Function BackReceb(oModel)
    
    Local lRet          := .t.
    Local lInternExec   := .F.

    Default oModel := FwLoadModel("GTPA756")

    If ( !(oModel:IsActive()) )
        
        lInternExec := .T.
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()

    EndIf

    lRet := oModel:GetModel("H6KMASTER"):SetValue("H6K_STATUS","2")         .And.;  //Volta para enviado para fornecedor
            oModel:GetModel("H6KMASTER"):SetValue("H6K_USRECE","")          .And.;   
            oModel:GetModel("H6KMASTER"):SetValue("H6K_DTRECE",SToD(""))    .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_HRRECE","")          .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_DOC","")             .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_SERIE","")

    If ( lRet .And. lInternExec )
        
        If ( oModel:VldData() )
            lRet := oModel:CommitData()
        EndIf

        oModel:DeActivate()

    EndIf            

Return(lRet)

Static Function Reembolso(oModel)

    Local lRet  := .T.

    lRet := TituloReemb(oModel) .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_DTREEM",dDataBase)               .And.; 
            oModel:GetModel("H6KMASTER"):SetValue("H6K_HRREEM",StrTran(Time(),":",""))  .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_USREEM",RetCodUsr())             .And.;
            oModel:GetModel("H6KMASTER"):SetValue("H6K_STATUS","5")  //Altera o Status para Finalizado

Return(lRet)

Static Function BackReemb(oModel)

    Local lRet          := .t.
    Local lInternExec   := .F.
    
    Default oModel := FwLoadModel("GTPA756")

    If ( !(oModel:IsActive()) )
        
        lInternExec := .T.
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()        

    EndIf

    lRet := TituloReemb(oModel,"2") .And.;  //Exclui o t�tulo financeiro
        oModel:GetModel("H6KMASTER"):LoadValue("H6K_STATUS","4") .And.;  //Volta para enviado para fornecedor
        oModel:GetModel("H6KMASTER"):LoadValue("H6K_USREEM","")  .And.;   
        oModel:GetModel("H6KMASTER"):LoadValue("H6K_DTREEM",SToD("")) .And.; 
        oModel:GetModel("H6KMASTER"):LoadValue("H6K_HRREEM","")  .And.; 
        oModel:GetModel("H6KMASTER"):LoadValue("H6K_PREFIX","")  .And.; 
        oModel:GetModel("H6KMASTER"):LoadValue("H6K_NUM","")     .And.;
        oModel:GetModel("H6KMASTER"):LoadValue("H6K_PARCEL","")  .And.;
        oModel:GetModel("H6KMASTER"):LoadValue("H6K_TIPO","")    .And.;
        oModel:GetModel("H6KMASTER"):LoadValue("H6K_FORPAS","")  .And.; 
        oModel:GetModel("H6KMASTER"):LoadValue("H6K_LJFOPA","")

    If ( lRet .And. lInternExec )
        
        If ( oModel:VldData() )
            lRet := oModel:CommitData()
        EndIf

        oModel:DeActivate()

    EndIf 

Return(lRet)

Static Function Finaliza(lRetirada)
    
    Local oModel := FwLoadModel("GTPA756")
    
    Local lRet  := .t.

    Default lRetirada := .f.

    CursorWait()
    
    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()
    
    If ( lRetirada )
        
        lRet := oModel:GetModel("H6KMASTER"):SetValue("H6K_DTRETI",dDataBase) .And.;
                oModel:GetModel("H6KMASTER"):SetValue("H6K_HRRETI",StrTran(Time(),":","")) .And.;
                oModel:GetModel("H6KMASTER"):SetValue("H6K_USRETI",RetCodUsr()) 
    
    Else    //Finaliza Reembolso
        
        lRet := oModel:GetModel("H6KMASTER"):SetValue("H6K_DTREEM",dDataBase) .And.; 
                oModel:GetModel("H6KMASTER"):SetValue("H6K_HRREEM",StrTran(Time(),":","")) .And.;
                oModel:GetModel("H6KMASTER"):SetValue("H6K_USREEM",RetCodUsr())
        
    EndIf
    
    If ( lRet )
        lRet := oModel:GetModel("H6KMASTER"):SetValue("H6K_STATUS","5") //Altera o Status para Finalizado
    EndIf

    If ( lRet .And. oModel:VldData() )
        lRet := oModel:CommitData()
    EndIf

    CursorArrow()

    oModel:DeActivate()

Return(lRet)

Static Function BackFinaliza(lRetirada)
    
    Local lRet          := .T.
    
    Local oModel      := FwLoadModel("GTPA756")
    
    Default lRetirada   := .F.
    
    CursorWait()

    oModel:SetOperation(MODEL_OPERATION_UPDATE)
    oModel:Activate()

    If ( lRetirada )
        
        lRet := oModel:GetModel("H6KMASTER"):SetValue("H6K_STATUS","3") .And.;    //Recebido
                oModel:GetModel("H6KMASTER"):SetValue("H6K_DTRETI",SToD("")) .And.;
                oModel:GetModel("H6KMASTER"):SetValue("H6K_HRRETI","") .And.;
                oModel:GetModel("H6KMASTER"):SetValue("H6K_USRETI","")
    Else
    
        lRet := oModel:GetModel("H6KMASTER"):SetValue("H6K_STATUS","4") .and.;
                oModel:GetModel("H6KMASTER"):SetValue("H6K_DTREEM",SToD("")) .And.; 
                oModel:GetModel("H6KMASTER"):SetValue("H6K_HRREEM","") .And.;
                oModel:GetModel("H6KMASTER"):SetValue("H6K_USREEM","") //Altera o Status para Finalizado
    
    EndIf

    If ( lRet  )
        
        If ( oModel:VldData() )
            lRet := oModel:CommitData()
        EndIf

    EndIf             
    
    oModel:DeActivate()
    
    CursorArrow()

Return(lRet)

Static Function NomeUsuario(cId)

    Local cNome := UsrFullName(cId)

Return(cNome)

Static Function FieldInit(oMdl,cField,nLine)

    Local aFields   := {}
    
    Local nP        := 0

    Local xRet      := Nil

    If ( oMdl:GetModel():GetOperation() <> MODEL_OPERATION_INSERT )
        
        Do Case
        Case ( cField == "H6KUSRNOME" ) //Nome do Usu�rio do Processo
            xRet := NomeUsuario(H6K->H6K_USUAR)
        Case ( cField == "H6KUSENVNM" ) //Nome do Usu�rio do Envio para o fornecedor
            xRet := NomeUsuario(H6K->H6K_USRENV)
        Case ( cField == "H6KUSRECNM" ) //Nome do Usu�rio do recebimento na ag�ncia
            xRet := NomeUsuario(H6K->H6K_USRECE)
        Case ( cField == "H6KUSRETNM" ) //Nome do Usu�rio da retirada pelo usu�rio
            xRet := NomeUsuario(H6K->H6K_USRETI)
        Case ( cField == "H6KUSREENM" ) //Nome do Usu�rio do reenmbolso
            xRet := NomeUsuario(H6K->H6K_USREEM)
        Case ( cField == "H6KDESGI2" )
            xRet := TPNomeLinh(H6K->H6K_CODGI2)
        Case ( cField == "H6KDEMPFOR" ) 
            xRet := SA2->(GetAdvFVal("SA2","A2_NREDUZ",XFilial("SA2") + H6K->(H6K_FOREMP+H6K_LJFOEM),1,""))
        Case ( cField == "H6KDPASFOR" )
            xRet := SA2->(GetAdvFVal("SA2","A2_NREDUZ",XFilial("SA2") + H6K->(H6K_FORPAS+H6K_LJFOPA),1,""))
        Case ( cField == "H6KDESCAGE" )
            xRet := GI6->(GetAdvFVal("GI6","GI6_DESCRI",XFilial("GI6") + H6K->H6K_AGENCI,1,"")) //Posicione("GI6",1,XFilial("GI6")+FwFldGet("GZ0_CODGI6"),"GI6_DESCRI")    
        End Case
    Else
        
        aFields := aClone(oMdl:GetStruct():GetFields())        
        
        nP      := aScan(aFields,{|x| x[3] == cField})
        cTipo   := Iif(nP > 0, aFields[nP,4], "C")
        
        xRet    := GTPCastType(,cTipo)

    EndIf

Return(xRet)

Static Function FieldTrigger(oSubMdl,cField,uVal)

    Local xRet      := Nil

    Local aTitulo   := {}

    Do Case
    Case ( cField == 'H6K_CODGI2' ) //, 'H6KDESGI2',   { || .T. }, bTrig
        xRet := TPNomeLinh(uVal)
    Case ( cField == 'H6K_FOREMP' ) //, 'H6KDEMPFOR',  { || .T. }, bTrig
        
        If ( !Empty(oSubMdl:GetValue("H6K_LJFOEM")) .And. !Empty(uVal) )
            xRet := SA2->(GetAdvFVal("SA2","A2_NREDUZ",XFilial("SA2") + uVal + oSubMdl:GetValue("H6K_LJFOEM"),1,""))
        EndIf

    Case ( cField == 'H6K_LJFOEM' ) //, 'H6KDEMPFOR',  { || .T. }, bTrig
        
        If ( !Empty(oSubMdl:GetValue("H6K_FOREMP")) .And. !Empty(uVal) )
            xRet := SA2->(GetAdvFVal("SA2","A2_NREDUZ",XFilial("SA2") + oSubMdl:GetValue("H6K_FOREMP") + uVal,1,""))
        EndIf

    Case ( cField == 'H6K_FORPAS' ) //, 'H6KDPASFOR',  { || .T. }, bTrig
        
        If ( !Empty(oSubMdl:GetValue("H6K_LJFOPA")) .And. !Empty(uVal) )
            xRet := SA2->(GetAdvFVal("SA2","A2_NREDUZ",XFilial("SA2") + uVal + oSubMdl:GetValue("H6K_LJFOPA"),1,""))
        EndIf

    Case ( cField == 'H6K_LJFOPA' ) //, 'H6KDPASFOR',  { || .T. }, bTrig
        
        If ( !Empty(oSubMdl:GetValue("H6K_FORPAS")) .And. !Empty(uVal) )
            xRet := SA2->(GetAdvFVal("SA2","A2_NREDUZ",XFilial("SA2") + oSubMdl:GetValue("H6K_FORPAS") + uVal,1,""))
        EndIf

    Case ( cField == "H6K_USUAR" )  //, "H6KUSRNOME",  { || .T. }, bTrig)
        xRet := NomeUsuario(oSubMdl:GetValue("H6K_USUAR"))
    Case ( cField == "H6K_USRENV" ) //, "H6KUSENVNM",  { || .T. }, bTrig)
        xRet := NomeUsuario(oSubMdl:GetValue("H6K_USRENV"))
    Case ( cField == "H6K_USRECE" ) //, "H6KUSRECNM",  { || .T. }, bTrig)
        xRet := NomeUsuario(oSubMdl:GetValue("H6K_USRECE"))
    Case ( cField == "H6K_USRETI" ) //, "H6KUSRETNM",  { || .T. }, bTrig)
        xRet := NomeUsuario(oSubMdl:GetValue("H6K_USRETI"))
    Case ( cField == "H6K_USREEM" ) //, "H6KUSREENM",  { || .T. }, bTrig)
        xRet := NomeUsuario(oSubMdl:GetValue("H6K_USREEM"))
    Case ( cField == "H6K_AGENCI" ) //, "H6KDESCAGE",  { || .T. }, bTrig)
        xRet := GI6->(GetAdvFVal("GI6","GI6_DESCRI",XFilial("GI6") + uVal,1,"")) //Posicione("GI6",1,XFilial("GI6")+FwFldGet("GZ0_CODGI6"),"GI6_DESCRI")
    Case ( cField == 'H6L_VALOR' )  //, 'H6K_VLRDOC',  { || .T. }, bTrig
        UpdVlrDoc(oSubMdl)
        xRet := uVal
    End Case

    //Atualiza os dados do t�tulo a ser gerado para reembolso
    //do conserto da bagagem ao passageiro
    If ((cField == "H6K_FORPAS" .And. !Empty(oSubMdl:GetValue("H6K_LJFOPA"))) .Or.; 
        (cField == "H6K_LJFOPA" .And. !Empty(oSubMdl:GetValue("H6K_FORPAS"))) )
        
        aTitulo := KeyTitle()
        
        oSubMdl:SetValue("H6K_PREFIX",aTitulo[1])
        oSubMdl:SetValue("H6K_PARCEL",aTitulo[2])
        oSubMdl:SetValue("H6K_TIPO",  aTitulo[3])
        oSubMdl:SetValue("H6K_NUM",   aTitulo[4])

    EndIf

Return(xRet)

//Atualiza o valor total do processo de conserto
Static Function UpdVlrDoc(oSubMdl,cAction,nLine)

    Local lDelete   := .f.

    Local nI        := 0
    Local nTotal    := 0

    Local oSubHead := oSubMdl:GetModel():GetModel("H6KMASTER")

    Default cAction := ""
    Default nLine   := 0

    For nI := 1 to oSubMdl:Length()
        
        If ( cAction != "UNDELETE" )
        
            lDelete := ( oSubMdl:IsDeleted(nI) .Or.;
                        ( cAction == "DELETE" .And. nI == nLine ) )
        
        EndIf

        If ( !lDelete )
            nTotal += oSubMdl:GetValue("H6L_VALOR",nI)
        EndIf    

    Next nI

    oSubHead:LoadValue("H6K_VLRDOC",nTotal)

Return()

Static Function VldPreLine(oMdl,nLine,cAction,cField,uValue)

    Local lRet		:= .T.
    
    If ( "DELETE" $ cAction )
        UpdVlrDoc(oMdl,cAction,nLine)   

    EndIf    

Return lRet 

Static Function KeyTitle(cField)

    Local xRet := {}
        
    Aadd(xRet,GTPGetRules("PRECONSERT",,,""))          //[1] Prefixo
    Aadd(xRet,StrZero(1,TamSx3("E2_PARCELA")[1]))      //[2] Parcela
    Aadd(xRet,GTPGetRules("TIPCONSERT",,,"FT"))        //[3] Tipo
    
    GA756BackTit()
    Aadd(xRet,GA756TitNum('SE2', xRet[1], xRet[2], xRet[3]))
    
Return(xRet)

Static Function ValidField(oMdl,cField,uValue,uOldValue)
    
    Local oModel    := oMdl:GetModel()

    Local cMsgErro  := ""
    Local cMsgSolu  := ""

    Local lRet      := .T.

    If ( !Empty(uValue) )

        Do Case
        Case ( cField == "H6K_AGENCI" )

            lRet := !Empty(GI6->(GetAdvFVal("GI6","GI6_DESCRI",XFilial("GI6") + uValue,1,"")))

            If ( !lRet )

                cMsgErro := "N�o foi poss�vel identificar a ag�ncia pelo c�digo digitado."
                cMsgSolu := "Verifique o c�digo digitado."
            
            EndIf

        Case ( cField == "H6K_CODGID" )

            lRet := !Empty(GID->(GetAdvFVal("GID","GID_COD",XFilial("GID") + uValue,1,"")))

            If ( !lRet )

                cMsgErro := "N�o foi poss�vel identificar o servi�o (hor�rio) pelo c�digo digitado."
                cMsgSolu := "Verifique se foi digitado corretamente, "
                cMsgSolu += "ou se � necess�rio efetuar o cadastro deste servi�o."
            
            EndIf

        Case ( cField == "H6K_CODGIC" )
            
            lRet := !Empty(GIC->(GetAdvFVal("GIC","GIC_CODIGO",XFilial("GIC") + uValue,1,"")))
        
            If ( !lRet )

                cMsgErro := "N�o foi poss�vel localizar o bilhete pelo identificador digitado."
                cMsgSolu := "Verifique se o identificador est� correto, "
                cMsgSolu += "ou se existe este bilhete."
                
            EndIf

        Case ( cField == "H6K_CODGI2" )
            
            lRet := !Empty(GI2->(GetAdvFVal("GI2","GI2_COD",XFilial("GI2") + uValue,1,"")))

            If ( !lRet )

                cMsgErro := "N�o foi poss�vel localizar o bilhete pelo identificador digitado."
                cMsgSolu := "Verifique se o identificador est� correto, "
                cMsgSolu += "ou se existe este bilhete."

            EndIf

        Case ( cField $ "H6K_FOREMP|H6K_LJFOEM" )
            
            If ( cField == "H6K_FOREMP" .And. !Empty(oMdl:GetValue("H6K_LJFOEM")) )
                lRet := !Empty(SA2->(GetAdvFVal("SA2","A2_NOME",XFilial("SA2") + uValue + oMdl:GetValue("H6K_LJFOEM") ,1,"")))
            ElseIf ( cField == "H6K_LJFOEM" .And. !Empty(oMdl:GetValue("H6K_FOREMP")) )
                lRet := !Empty(SA2->(GetAdvFVal("SA2","A2_NOME",XFilial("SA2") + oMdl:GetValue("H6K_FOREMP") + uValue,1,"")))
            EndIf
            
            If ( !lRet )

                cMsgErro := "N�o foi poss�vel localizar o cadastro de fornecedor."
                cMsgSolu := "Verifique se foi digitado o c�digo correto, "
                cMsgSolu += "ou se � necess�rio efetuar o cadastro do fornecedor."

            EndIf
            
        Case ( cField $ "H6K_FORPAS|H6K_LJFOPA" )
            
            If ( cField == "H6K_FORPAS".And. !Empty(oMdl:GetValue("H6K_LJFOPA")) )
                lRet := !Empty(SA2->(GetAdvFVal("SA2","A2_NOME",XFilial("SA2") + uValue + oMdl:GetValue("H6K_LJFOPA") ,1,"")))
            ElseIf ( cField == "H6K_LJFOPA" .And. !Empty(oMdl:GetValue("H6K_FORPAS")) )
                lRet := !Empty(SA2->(GetAdvFVal("SA2","A2_NOME",XFilial("SA2") + oMdl:GetValue("H6K_FORPAS") + uValue,1,"")))
            EndIf

            If ( !lRet )

                cMsgErro := "N�o foi poss�vel localizar o cadastro de fornecedor."
                cMsgSolu := "Verifique se foi digitado o c�digo correto, "
                cMsgSolu += "ou se � necess�rio efetuar o cadastro do fornecedor."
                
            EndIf
        
        Case ( cField == "H6K_DTOCOR" )

            If ( !Empty(uValue) .And. !Empty(oMdl:GetValue("H6K_DTVIAG")) )
                
                If ( uValue < oMdl:GetValue("H6K_DTVIAG") )
                
                    lRet := .F.

                    cMsgErro := "A data de ocorr�ncia n�o pode ser inferior a data da viagem"
                    cMsgSolu := "Ou deixe a data de viagem em branco ou preencha uma data "
                    cMsgSolu += "de viagem igual ou inferior a data de ocorr�ncia"                    

                EndIf

            EndIf
        
        End Case

        If ( !lRet )
            oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"VldPreLine",cMsgErro,cMsgSolu,uValue,uOldValue)
        EndIf

    EndIf

Return(lRet)

Static Function ValidAllOK(oModel)

    Local lRet  := .T.
    
    If ( oModel:GetOperation() == MODEL_OPERATION_INSERT .Or.;
        oModel:GetOperation() == MODEL_OPERATION_UPDATE )
    
        lRet := ValidField(oModel:GetModel("H6KMASTER"),"H6K_DTOCOR",oModel:GetModel("H6KMASTER"):GetValue("H6K_DTOCOR"))
    
    EndIf

Return(lRet)

Function GA756Commit(oModel,cViewCall)

    Local lRet  := .T.
    // Local lFinaliza := FwIsInCallStack("Finaliza")

    Local nOpt  := oModel:GetOperation()

    Default cViewCall := "GTPA756"

    Begin Transaction

    If ( nOpt == MODEL_OPERATION_INSERT .or. nOpt == MODEL_OPERATION_UPDATE )

        If ( cViewCall $ "GTPA756|GTPA756A" ) //Se a View principal � GTPA756 (Lembrando que a view GTPA756A, funciona como inclus�o de GTPA756)
            
            If ( Empty(oModel:GetModel("H6KMASTER"):GetValue("H6K_USUAR")) )
                lRet := oModel:GetModel("H6KMASTER"):SetValue("H6K_USUAR",RetCodUsr())
            EndIf
            
            If ( lRet )

                //Somente ajusta o Status ou para "A Consertar pela empresa"
                //ou para "A Reembolsar"
                //quando for Inclus�o (H6K_STATUS vazio) ou Altera��o do cadastro,
                //nesse �ltimo caso, tenha sido alterado a origem do conserto
                If ( oModel:GetModel("H6KMASTER"):GetValue("H6K_STATUS") $ "1|4" .Or.;
                        Empty(oModel:GetModel("H6KMASTER"):GetValue("H6K_STATUS")) )
            
                    //Origem Empresa?
                    If ( oModel:GetModel("H6KMASTER"):GetValue("H6K_ORICON") <> "2" )
                        lRet := oModel:GetModel("H6KMASTER"):SetValue("H6K_STATUS","1") //Altera o Status para A Consertar pela empresa
                    Else    //Origem Passageiro?    
                        lRet := oModel:GetModel("H6KMASTER"):SetValue("H6K_STATUS","4") //Altera o Status para A Reembolsar
                    EndIf

                EndIf

            EndIf
        
        ElseIf ( cViewCall == "GTPA756B" )  //View de Envio para o Fornecedor
            
            If ( H6K->H6K_STATUS == "1" )       //Envia o processo de conserto para o Fornecedor
                lRet := Envio(oModel)
            EndIf
        
        ElseIf ( cViewCall == "GTPA756C" )  //View de Recebimento na Ag�ncia

            If ( H6K->H6K_STATUS == "2" )       //Recebe na Ag�ncia o conserto prestado pelo forncedor
                lRet := Recebe(oModel)
            EndIf

        ElseIf ( cViewCall == "GTPA756E")   //View de Reembolso para o Passageiro

            If ( H6K->H6K_STATUS == "4" )       //Ap�s Reembolso, o processo de conserto � finalizado
                lRet := Reembolso(oModel)//lRet := TituloReemb(oModel) .And. Reembolso(oModel)
            EndIf
            //Confirma ou faz rollback da numera��o autom�tica do n�mero de t�tulo
            IIf(lRet, GA756ConfTit(),GA756BackTit())

        EndIf

    EndIf

    If ( lRet  )

        If ( oModel:VldData() )
            lRet := FwFormCommit(oModel)
        EndIf        
    
    EndIf

    Iif(!lRet, DisarmTransaction(), Nil)

    End Transaction
    
Return(lRet)

//Gerar T�tulo a pagar de Reembolso para o Passageiro
//que arcou com o conserto da bagagem.
Static Function TituloReemb(oModel,cOperation)
    
    Local cPrefix   := ""
    Local cNumero   := ""
    Local cParcel   := ""
    Local cTipo     := ""
    Local cNaturez  := ""
    Local cHist     := ""
    Local cFornec   := ""
    Local cLoja     := ""
    Local cMsgErro  := ""
    Local cMsgSolu  := ""
    Local cPath     := GetSrvProfString("StartPath","")
    Local cFile     := "gtpa756_titulo_pagar_log.txt"

    Local nVlRemb   := 0
    Local nOpc      := 0

    Local aTitulo   := {}

    Local lRet      := .T.

    Private lMsErroAuto := .F.

    Default oModel      := FwModelActive()
    Default cOperation  := "1"

    cNaturez    := GTPGetRules("NATCONSERT",,,"")
    
    If ( !Empty(cNaturez) )

        If ( Valtype(oModel) == "O" .And. oModel:IsActive() )

            //cOperation 1, Inclusao, do contr�rio, exclus�o            
            nOpc        := Iif(cOperation == "1", 3, 5)
            
            cPrefix     := oModel:GetModel("H6KMASTER"):GetValue("H6K_PREFIX")
            cNumero     := oModel:GetModel("H6KMASTER"):GetValue("H6K_NUM")
            cParcel     := oModel:GetModel("H6KMASTER"):GetValue("H6K_PARCEL")
            cTipo       := oModel:GetModel("H6KMASTER"):GetValue("H6K_TIPO")
            cFornec     := oModel:GetModel("H6KMASTER"):GetValue("H6K_FORPAS")
            cLoja       := oModel:GetModel("H6KMASTER"):GetValue("H6K_LJFOPA")
                        
            nVlRemb     := oModel:GetModel("H6KMASTER"):GetValue("H6K_VLRDOC")

            cHist       := "REEMB. CONSERTO BAGAGENS - " + oModel:GetModel("H6KMASTER"):GetValue("H6K_CODIGO")

            If ( cOperation == "1" )

                aAdd( aTitulo,	{"E2_FILIAL" 	, XFilial("SE2")   , NIL 	} ) 
                aAdd( aTitulo,	{"E2_PREFIXO" 	, cPrefix   , NIL 	} ) 
                aAdd( aTitulo,	{"E2_NUM" 	    , cNumero  	, NIL 	} )
                aAdd( aTitulo,	{"E2_TIPO" 	    , cTipo 	, NIL 	} )  
                aAdd( aTitulo,	{"E2_PARCELA" 	, cParcel	, NIL 	} )
                aAdd( aTitulo,	{"E2_NATUREZ" 	, cNaturez  , NIL 	} ) 
                aAdd( aTitulo,	{"E2_FORNECE"	, cFornec   , NIL 	} )
                aAdd( aTitulo,	{"E2_LOJA"   	, cLoja     , NIL 	} )
                aAdd( aTitulo,	{"E2_EMISSAO"	, dDataBase	, NIL 	} )
                aAdd( aTitulo,	{"E2_VENCTO" 	, dDataBase , NIL 	} )			                        
                // aAdd( aTitulo, 	{"E2_VENCREA" 	, dDataBase , NIL 	} )			                        
                aAdd( aTitulo,	{"E2_MOEDA" 	, 1			, NIL 	} )
                aAdd( aTitulo,	{"E2_VALOR" 	, nVlRemb   , NIL 	} )
                aAdd( aTitulo,	{"E2_HIST"	    , cHist     , NIL   } ) 
                aAdd( aTitulo,	{"E2_ORIGEM" 	, 'GTPA756'	, NIL 	} )

            Else

                SE2->(DbSetOrder(1))
                
                If ( SE2->(DbSeek(xFilial("SE2") + cPrefix + cNumero + cParcel + cTipo)) )
                
                    aAdd( aTitulo,	{"E2_FILIAL" 	, SE2->E2_FILIAL    , NIL 	} ) 
                    aAdd( aTitulo,	{"E2_PREFIXO" 	, SE2->E2_PREFIXO   , NIL 	} ) 
                    aAdd( aTitulo,	{"E2_NUM" 	    , SE2->E2_NUM  	    , NIL 	} )
                    aAdd( aTitulo,	{"E2_TIPO" 	    , SE2->E2_TIPO 	    , NIL 	} )  
                    aAdd( aTitulo,	{"E2_PARCELA" 	, SE2->E2_PARCELA	, NIL 	} )
                    aAdd( aTitulo,	{"E2_NATUREZ" 	, SE2->E2_NATUREZ	, NIL 	} )
                    aAdd( aTitulo,	{"E2_FORNECE"	, SE2->E2_FORNECE   , NIL 	} )
                    aAdd( aTitulo,	{"E2_LOJA"   	, SE2->E2_LOJA      , NIL 	} )                
                    aAdd( aTitulo,	{"E2_EMISSAO"   	, SE2->E2_EMISSAO   , NIL 	} )                
                
                EndIf
     
            EndIf

            MsExecAuto( { |x,y,z| FINA050(x,y,z)} , aTitulo, ,nOpc ) // 3-Inclusao,4-Altera��o,5-Exclus�o

            If lMsErroAuto
            
                lRet := .F.
            
                cMsgErro    := MostraErro(cPath,cFile) + CRLF
                cMsgSolu    := "Verifique as informa��es para gera��o do t�tulo a pagar."

            EndIf

        EndIf

    EndIf

    If ( !lRet )
        FwAlertError(cMsgErro, cMsgSolu) 
    EndIf

Return(lRet)

Static Function SetHeader(oStrH6K)

    Local aFields := aClone(SetupFields())  //Configura os campos da estrutura conforme agrupamento, remo��o e edi��o de campos
    
    AddingFields(oStrH6K)           //Adiciona campos fakes 
    StructOrdering(oStrH6K,aFields) //Ordena os campos da view
    StructGrouping(oStrH6K,aFields) //configura a estrutura de oStrh6k conforme a agrupamentos

Return()

Static Function SetupFields()

    Local aFields   := {}
    //              campo         agrupaento     CANCHANGE  REMOVE FIELD
    AAdd(aFields,{"H6K_CODIGO",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_CODGI2",   "CONSERTO",   .T.,        .F.})
    AAdd(aFields,{"H6KDESGI2",    "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_CODGID",   "CONSERTO",   .T.,        .F.})
    AAdd(aFields,{"H6K_DTVIAG",   "CONSERTO",   .T.,        .F.})
    AAdd(aFields,{"H6K_CODGIC",   "CONSERTO",   .T.,        .F.})
    AAdd(aFields,{"H6K_NOMEPS",   "PASSAGEIRO", .T.,        .F.})
    AAdd(aFields,{"H6K_TELEFO",   "PASSAGEIRO", .T.,        .F.})
    AAdd(aFields,{"H6K_EMAIL",    "PASSAGEIRO", .T.,        .F.})
    AAdd(aFields,{"H6K_RGPASS",   "PASSAGEIRO", .T.,        .F.})
    AAdd(aFields,{"H6K_ENDPAS",   "PASSAGEIRO", .T.,        .F.})
    AAdd(aFields,{"H6K_CPENPS",   "PASSAGEIRO", .T.,        .F.})
    AAdd(aFields,{"H6K_CEPPAS",   "PASSAGEIRO", .T.,        .F.})
    AAdd(aFields,{"H6K_DTOCOR",   "CONSERTO",   .T.,        .F.})
    AAdd(aFields,{"H6K_DTSLA",    "CONSERTO",   .T.,        .F.})
    AAdd(aFields,{"H6K_ORICON",   "CONSERTO",   .T.,        .F.})
    AAdd(aFields,{"H6K_DOC",      "DOCUMENTO",  .F.,        .F.})
    AAdd(aFields,{"H6K_SERIE",    "DOCUMENTO",  .F.,        .F.})
    AAdd(aFields,{"H6K_FOREMP",   "DOCUMENTO",  .F.,        .F.})
    AAdd(aFields,{"H6K_LJFOEM",   "DOCUMENTO",  .F.,        .F.})
    AAdd(aFields,{"H6KDEMPFOR",   "DOCUMENTO",  .F.,        .F.})
    AAdd(aFields,{"H6K_DOCONS",   "DOC_PASSAG", .F.,        .F.})
    AAdd(aFields,{"H6K_FORPAS",   "DOC_PASSAG", .F.,        .F.})
    AAdd(aFields,{"H6K_LJFOPA",   "DOC_PASSAG", .F.,        .F.})
    AAdd(aFields,{"H6KDPASFOR",   "DOC_PASSAG", .F.,        .F.})
    AAdd(aFields,{"H6K_VLRDOC",   "CONSERTO",   .T.,        .F.})
    AAdd(aFields,{"H6K_OBSERV",   "CONSERTO",   .T.,        .F.})
    AAdd(aFields,{"H6K_STATUS",   "CONSERTO",   .F.,        .T.})
    AAdd(aFields,{"H6K_AGENCI",   "CONSERTO",   .T.,        .F.})
    AAdd(aFields,{"H6KDESCAGE",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_USUAR",    "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6KUSRNOME",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_DTENVI",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_HRENVI",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_USRENV",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6KUSENVNM",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_DTRECE",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_HRRECE",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_USRECE",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6KUSRECNM",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_DTRETI",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_HRRETI",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_USRETI",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6KUSRETNM",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_DTREEM",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_HRREEM",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_USREEM",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6KUSREENM",   "CONSERTO",   .F.,        .F.})
    AAdd(aFields,{"H6K_PREFIX",   "DOC_PASSAG", .F.,        .F.})
    AAdd(aFields,{"H6K_NUM",      "DOC_PASSAG", .F.,        .F.})
    AAdd(aFields,{"H6K_PARCEL",   "DOC_PASSAG", .F.,        .F.})
    AAdd(aFields,{"H6K_TIPO",     "DOC_PASSAG", .F.,        .F.})

Return(aFields)

Static Function AddingFields(oStrH6K)

    Local aFields := aClone(oStrH6K:GetFields())
    
    //inclus�o dos campos virtuais e "fakes"
    oStrH6K:AddField(  "H6KDESCAGE",;                   // [01] C Nome do Campo                                       
                        StrZero(Len(aFields)+1),;   	// [02] C Ordem
                        "Nome Ag�ncia",;                // [03] C Titulo do campo //"C�d.ECF"
                        "Nome Ag�ncia",;                // [04] C Descri��o do campo //"C�d.ECF"
                        {"Nome da Ag�ncia"}, ;          // [05] A Array com Help //"C�d.ECF"
                        "GET",;  	                    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	                    // [07] C Picture
                        NIL,;   	                    // [08] B Bloco de Picture Var
                        "",;	                        // [09] C Consulta F3
                        .F.,;    	                    // [10] L Indica se o campo � edit�vel
                        NIL,;                           // [11] C Pasta do campo
                        NIL,;    	                    // [12] C Agrupamento do campo
                        Nil,;  	                        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	                    // [14] N Tamanho Maximo da maior op��o do combo
                        NIL,;    	                    // [15] C Inicializador de Browse
                        .F.)    	                    // [16] L Indica se o campo � virtual
    
    oStrH6K:AddField(  "H6KDESGI2",;                  // [01] C Nome do Campo                                       
                        StrZero(Len(aFields)+10),;   	                    // [02] C Ordem
                        "Nome Linha",;                // [03] C Titulo do campo //"C�d.ECF"
                        "Nome da Linha",;                // [04] C Descri��o do campo //"C�d.ECF"
                        {"Nome da Linha"}, ;  // [05] A Array com Help //"C�d.ECF"
                        "GET",;  	                    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	                    // [07] C Picture
                        NIL,;   	                    // [08] B Bloco de Picture Var
                        "",;	                        // [09] C Consulta F3
                        .F.,;    	                    // [10] L Indica se o campo � edit�vel
                        NIL,;                           // [11] C Pasta do campo
                        NIL,;    	                    // [12] C Agrupamento do campo
                        Nil,;  	                        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	                    // [14] N Tamanho Maximo da maior op��o do combo
                        NIL,;    	                    // [15] C Inicializador de Browse
                        .F.)    	                    // [16] L Indica se o campo � virtual

    oStrH6K:AddField(  "H6KDEMPFOR",;                  // [01] C Nome do Campo                                       
                        StrZero(Len(aFields)+9),;   	                    // [02] C Ordem
                        "Nome Forn.Empres.",;                // [03] C Titulo do campo //"C�d.ECF"
                        "Nome Fornecedor Empresa",;                // [04] C Descri��o do campo //"C�d.ECF"
                        {"Nome do fornecedor que ",;
                        "da empresa"}, ;  // [05] A Array com Help //"C�d.ECF"
                        "GET",;  	                    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	                    // [07] C Picture
                        NIL,;   	                    // [08] B Bloco de Picture Var
                        "",;	                        // [09] C Consulta F3
                        .F.,;    	                    // [10] L Indica se o campo � edit�vel
                        NIL,;                           // [11] C Pasta do campo
                        NIL,;    	                    // [12] C Agrupamento do campo
                        Nil,;  	                        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	                    // [14] N Tamanho Maximo da maior op��o do combo
                        NIL,;    	                    // [15] C Inicializador de Browse
                        .F.)    	                    // [16] L Indica se o campo � virtual
                        
    oStrH6K:AddField(  "H6KDPASFOR",;                  // [01] C Nome do Campo                                       
                        StrZero(Len(aFields)+3),;   	                    // [02] C Ordem
                        "Nome Forn.Pass.",;                // [03] C Titulo do campo //"C�d.ECF"
                        "Nome Fornecedor Passageiro",;                // [04] C Descri��o do campo //"C�d.ECF"
                        {"Nome do fornecedor que",;
                        "� passageiro"}, ;  // [05] A Array com Help //"C�d.ECF"
                        "GET",;  	                    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	                    // [07] C Picture
                        NIL,;   	                    // [08] B Bloco de Picture Var
                        "",;	                        // [09] C Consulta F3
                        .F.,;    	                    // [10] L Indica se o campo � edit�vel
                        NIL,;                           // [11] C Pasta do campo
                        NIL,;    	                    // [12] C Agrupamento do campo
                        Nil,;  	                        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	                    // [14] N Tamanho Maximo da maior op��o do combo
                        NIL,;    	                    // [15] C Inicializador de Browse
                        .F.)    	                    // [16] L Indica se o campo � virtual
                        

    oStrH6K:AddField(  "H6KUSRNOME",;                  // [01] C Nome do Campo                                       
                        StrZero(Len(aFields)+4),;   	                    // [02] C Ordem
                        "Nome Usr. Proc.",;                // [03] C Titulo do campo //"C�d.ECF"
                        "Nome Usu�rio Processo",;                // [04] C Descri��o do campo //"C�d.ECF"
                        {"Nome do usu�rio do processo"}, ;  // [05] A Array com Help //"C�d.ECF"
                        "GET",;  	                    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	                    // [07] C Picture
                        NIL,;   	                    // [08] B Bloco de Picture Var
                        "",;	                        // [09] C Consulta F3
                        .F.,;    	                    // [10] L Indica se o campo � edit�vel
                        NIL,;                           // [11] C Pasta do campo
                        NIL,;    	                    // [12] C Agrupamento do campo
                        Nil,;  	                        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	                    // [14] N Tamanho Maximo da maior op��o do combo
                        NIL,;    	                    // [15] C Inicializador de Browse
                        .F.)    	                    // [16] L Indica se o campo � virtual
    
    oStrH6K:AddField(  "H6KUSENVNM",;                  // [01] C Nome do Campo                                       
                        StrZero(Len(aFields)+5),;   	                    // [02] C Ordem
                        "Nome Usr. Env.",;                // [03] C Titulo do campo //"C�d.ECF"
                        "Nome Usu�rio Envio",;                // [04] C Descri��o do campo //"C�d.ECF"
                        {"Nome do usu�rio do processo"}, ;  // [05] A Array com Help //"C�d.ECF"
                        "GET",;  	                    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	                    // [07] C Picture
                        NIL,;   	                    // [08] B Bloco de Picture Var
                        "",;	                        // [09] C Consulta F3
                        .F.,;    	                    // [10] L Indica se o campo � edit�vel
                        NIL,;                           // [11] C Pasta do campo
                        NIL,;    	                    // [12] C Agrupamento do campo
                        Nil,;  	                        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	                    // [14] N Tamanho Maximo da maior op��o do combo
                        NIL,;    	                    // [15] C Inicializador de Browse
                        .F.)    	                    // [16] L Indica se o campo � virtual
    
    oStrH6K:AddField(  "H6KUSRECNM",;                  // [01] C Nome do Campo                                       
                        StrZero(Len(aFields)+6),;   	                    // [02] C Ordem
                        "Nome Usr. Receb..",;                // [03] C Titulo do campo //"C�d.ECF"
                        "Nome Usu�rio Recebimento",;                // [04] C Descri��o do campo //"C�d.ECF"
                        {"Nome do usu�rio do recebimento"}, ;  // [05] A Array com Help //"C�d.ECF"
                        "GET",;  	                    // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	                    // [07] C Picture
                        NIL,;   	                    // [08] B Bloco de Picture Var
                        "",;	                        // [09] C Consulta F3
                        .F.,;    	                    // [10] L Indica se o campo � edit�vel
                        NIL,;                           // [11] C Pasta do campo
                        NIL,;    	                    // [12] C Agrupamento do campo
                        Nil,;  	                        // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	                    // [14] N Tamanho Maximo da maior op��o do combo
                        NIL,;    	                    // [15] C Inicializador de Browse
                        .F.)    	                    // [16] L Indica se o campo � virtual
     
    oStrH6K:AddField(  "H6KUSRETNM",;                       // [01] C Nome do Campo                                       
                        StrZero(Len(aFields)+7),;   	    // [02] C Ordem
                        "Nome Usr. Retira.",;               // [03] C Titulo do campo //"C�d.ECF"
                        "Nome Usu�rio Retirada",;           // [04] C Descri��o do campo //"C�d.ECF"
                        {"Nome do usu�rio do retirada"}, ;  // [05] A Array com Help //"C�d.ECF"
                        "GET",;  	                        // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	                        // [07] C Picture
                        NIL,;   	                        // [08] B Bloco de Picture Var
                        "",;	                            // [09] C Consulta F3
                        .F.,;    	                        // [10] L Indica se o campo � edit�vel
                        NIL,;                               // [11] C Pasta do campo
                        NIL,;    	                        // [12] C Agrupamento do campo
                        Nil,;  	                            // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	                        // [14] N Tamanho Maximo da maior op��o do combo
                        NIL,;    	                        // [15] C Inicializador de Browse
                        .F.)    	                        // [16] L Indica se o campo � virtual
    
    oStrH6K:AddField(  "H6KUSREENM",;                       // [01] C Nome do Campo                                       
                        StrZero(Len(aFields)+8),;           // [02] C Ordem
                        "Nome Usr. Reemb.",;                // [03] C Titulo do campo //"C�d.ECF"
                        "Nome Usu�rio Reembolso",;          // [04] C Descri��o do campo //"C�d.ECF"
                        {"Nome do usu�rio do reembolso"}, ; // [05] A Array com Help //"C�d.ECF"
                        "GET",;  	                        // [06] C Tipo do campo - GET, COMBO OU CHECK
                        "@!",;   	                        // [07] C Picture
                        NIL,;   	                        // [08] B Bloco de Picture Var
                        "",;	                            // [09] C Consulta F3
                        .F.,;    	                        // [10] L Indica se o campo � edit�vel
                        NIL,;                               // [11] C Pasta do campo
                        NIL,;    	                        // [12] C Agrupamento do campo
                        Nil,;  	                            // [13] A Lista de valores permitido do campo (Combo)
                        NIL,;   	                        // [14] N Tamanho Maximo da maior op��o do combo
                        NIL,;    	                        // [15] C Inicializador de Browse
                        .F.)    	                        // [16] L Indica se o campo � virtual
    
Return()

Static Function StructOrdering(oStrH6K,aFields)

    Local nI        := 0
    Local nOrder    := 0    
    
    For nI := 1 to Len(aFields)

        If ( oStrH6K:HasField(aFields[nI,1]) )
            
            nOrder++

            oStrH6K:SetProperty(aFields[nI,1], MVC_VIEW_ORDEM, StrZero(nOrder,2))

        EndIf

    Next nI

Return()

Static Function StructGrouping(oStrH6K,aFields)
    
    Local cDescGroup:= ""

    Local nI        := 0
    
    Local aLidos    := {}
    
    For nI := 1 to Len(aFields)
    
        If ( AScan(aLidos,{|x| x == aFields[nI,2]}) == 0 )

            If ( aFields[nI,2] == "CONSERTO" )
                cDescGroup := "Dados do Conserto da bagagem"
            ElseIf ( aFields[nI,2] == "PASSAGEIRO" )
                cDescGroup := "Dados do Passageiro"
            ElseIf ( aFields[nI,2] == "DOCUMENTO" )
                cDescGroup := "Dados do conserto pela empresa"
            ElseIf ( aFields[nI,2] == "DOC_PASSAG" )
                cDescGroup := "Dados do conserto pelo passageiro"
            EndIf

            oStrH6K:AddGroup(aFields[nI,2], cDescGroup, "" , 2 )  //Ag�ncia

            aAdd(aLidos,aFields[nI,2])

        EndIf
        
        If ( oStrH6K:HasField(aFields[nI,1]) )
	        oStrH6K:SetProperty(aFields[nI,1], MVC_VIEW_GROUP_NUMBER, aFields[nI,2])
	        oStrH6K:SetProperty(aFields[nI,1], MVC_VIEW_CANCHANGE, aFields[nI,3])
        EndIf    
        
        If ( aFields[nI,4] ) //remove campo?
            oStrH6K:RemoveField(aFields[nI,1])
        EndIf

    Next nI
	//Define uma consulta padr�o (F3) para Ag�ncia
    oStrH6K:SetProperty("H6K_AGENCI", MVC_VIEW_LOOKUP , "GI6")

Return()

Function A756RDocPrt()

    Local oMdl756 := Nil

    Local cMsg  := ""

    Local lOk   := .F.

    If ( H6K->(H6K_STATUS $ '5|6') .And. !Empty(H6K->H6K_FOREMP) )
        
        R756DCloseWord()
        
        lOk := GTPR756D(H6K->H6K_CODIGO,.T.) 
        
        //Atualiza o status do conserto para documento de retirada impresso
        //caso n�o tenha sido impresso anteriormente.
        If ( lOk .And. H6K->H6K_STATUS == "5" )
                
            oMdl756 := FwLoadModel("GTPA756")
            oMdl756:SetOperation(MODEL_OPERATION_UPDATE)
            oMdl756:Activate()    
            
            lOk := oMdl756:GetModel("H6KMASTER"):LoadValue("H6K_STATUS","6") .and. oMdl756:VldData()
            
            If ( lOk )
                lOk := oMdl756:CommitData()
            EndIf

            oMdl756:DeActivate()                
            
        EndIf

    Else
        
        cMsg := "Somente documentos de retirada de consertos de bagagens que ou foram "
        cMsg += "'5-Finalizado' ou foram '6-Doc. Impresso' poder�o ser (re)impressos."

        FwAlertHelp("Status incorreto", cMsg)
    
    EndIf    

Return()

Function GA756TitNum(cAlias, cPrefixo, cParcela, cTipo)
    
    Local cField		:= Iif(cAlias == 'SE1','E1_NUM', 'E2_NUM')
    Local cNum 			:= GetSxEnum(cAlias, cField, cEmpAnt+xFilial(cAlias)+cPrefixo+cParcela+cTipo) 

    Default cPrefixo	:= ""
    Default cParcela	:= ""
    Default cTipo		:= ""
        
    lGA756ConfTit := .F.
	
    (cAlias)->(dbSetOrder(1))

	While (cAlias)->(dbSeek(xFilial(cAlias)+cPrefixo+cNum+cParcela+cTipo))		
		cNum := GetSxEnum(cAlias, cField, cEmpAnt+xFilial(cAlias)+cPrefixo+cParcela+cTipo)		
	End While

    If ( !Empty(cNum) )
        lGA756ConfTit := .t.
    EndIf

Return(cNum)

Function GA756ConfTit()
	
    If ( lGA756ConfTit )
        ConfirmSX8()
    EndIf

Return()

Function GA756BackTit()
    
    If ( lGA756ConfTit )
	    RollBackSX8()
    EndIf

Return()
        
Static Function VerTituloPagar()
    
    Local cMsg  := ""

    Private cCadastro := "T�tulo Contas a Pagar"

    If ( H6K->(H6K_STATUS $ '4|5' .And. !Empty(H6K_NUM)) )
            
        SE2->(DbSetOrder(1))
        
        If ( SE2->(DbSeek(xFilial("SE2") + H6K->(H6K_PREFIX + H6K_NUM + H6K_PARCEL + H6K_TIPO) )) )
            Fc050Con()	
        EndIf 
    
    Else

        cMsg := "Somente os consertos de bagagens, cujo o passageiro "
        cMsg += "foi reembolsado, podem ter os t�tulos a pagar visualizados."        
    
        FwAlertHelp("Status incorreto", cMsg)
    EndIf

Return()