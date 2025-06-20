#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA316.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Fun��o responsavel pela defini��o do browse da Amarra��o de Recurso x Documento
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param , character, (Descri��o do par�metro)
@return oBrowse, retorna o objeto de browse
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse       := FWMBrowse():New()

oBrowse:SetAlias('G6V')

oBrowse:AddLegend("G6V_STATUS == '1'"   ,"GREEN"   ,STR0001    )//"Validar"    
oBrowse:AddLegend("G6V_STATUS == '2'"   ,"BLACK"   ,STR0002    )//"N�o Validar"
oBrowse:AddLegend("G6V_STATUS == '3'"   ,"RED"     ,STR0003    )//"Bloquear"   

Return oBrowse

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Fun��o responsavel pela defini��o do modelo
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrG6V	:= FWFormStruct(1,'G6V')
Local oStrG6W	:= FWFormStruct(1,'G6W')

SetModelStruct(oStrG6V,oStrG6W)

oModel := MPFormModel():New('GTPA316', /*bPreValidacao*/, {|oMdl| ModelPosValid(oMdl)}/*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('G6VMASTER',/*cOwner*/,oStrG6V)
oModel:AddGrid('G6WDETAIL','G6VMASTER',oStrG6W,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,{|oMdl| LoadModel(oMdl) }/*BLoad*/)

oModel:SetRelation('G6WDETAIL',{{ 'G6W_FILIAL','xFilial("G6W")'},{'G6W_CODIGO','G6V_CODIGO' }},G6W->(IndexKey(1)))

oModel:SetDescription(STR0004) //'Amarra��o do Recurso x Documento'

oModel:GetModel('G6VMASTER'):SetDescription(STR0005)	//'Dados do Recurso'
oModel:GetModel('G6WDETAIL'):SetDescription(STR0006)	//'Documentos'

oModel:SetPrimaryKey({'G6V_FILIAL','G6V_CODIGO'})

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} LoadModel
Fun��o responsavel pelo load do modelo
@type Static Function
@author jacomo.fernandes
@since 25/07/2019
@version 1.0
@param oModel, object, (Descri��o do par�metro)
@return aRet, retorno da lista de itens
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function LoadModel(oModel)
Local aRet      := {}
Local cTmpAlias := GetNextAlias()
Local cFields   := "%" + GTPFld2Str(oModel:GetStruct(),.F.) + "%" 
Local cCodigo   := G6V->G6V_CODIGO

cFields := StrTran(cFields,"G6W_STATUS","(Case WHEN G6W_STATUS <> '2' AND G6W_DTFIM < '"+DtoS(dDataBase)+"' THEN '3' ELSE G6W_STATUS END) AS G6W_STATUS")
cFields := StrTran(cFields,"G6W_LEGEND","(Case WHEN G6W_STATUS <> '2' AND G6W_DTFIM < '"+DtoS(dDataBase)+"' THEN 'BR_LARANJA' WHEN G6W_STATUS = '2' THEN 'BR_VERMELHO' ELSE 'BR_VERDE' END) AS G6W_LEGEND")
cFields := StrTran(cFields,"ANEXO,","")
        
BeginSql Alias cTmpAlias
    COLUMN G6W_DTINI AS DATE
    COLUMN G6W_DTFIM AS DATE
    COLUMN G6W_DTMAX AS DATE

    Select 
        %Exp:cFields%, 
        G6W.R_E_C_N_O_
    From %Table:G6W% G6W
        Inner Join %Table:G6U% G6U on
            G6U.G6U_FILIAL = %xFilial:G6U%
            AND G6U_CODIGO = G6W.G6W_CODG6U
            AND G6U.%NotDel%
    Where
        G6W.G6W_FILIAL = %xFilial:G6W%
        AND G6W.G6W_CODIGO = %Exp:cCodigo%
        AND G6W.%NotDel%
    ORDER BY G6W_FILIAL, G6W_CODIGO, G6W_SEQ
EndSql

aRet := FWLoadByAlias(oModel, cTmpAlias)

(cTmpAlias)->(DbCloseArea())

Return aRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} ModelPosValid
Fun��o responsavel pela valida��o do modelo completa
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param oModel, object, (Descri��o do par�metro)
@return lRet, Retorno l�gico
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function ModelPosValid(oModel)
Local lRet      := .T.

If !VldRegEncav(oModel)
    lRet    := .F.
Endif

If lRet .and. !VldDocVenc(oModel)
    lRet    := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldRegEncav
Fun��o responsaval para verificar os registros que possuirem algum registro com datas encavaladas do mesmo tipo de documento
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param oModel, object, (Descri��o do par�metro)
@return lRet, returno logico
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldRegEncav(oModel)
Local lRet      := .T.
Local oMdlG6W   := oModel:GetModel('G6WDETAIL')
Local n1        := 0

For n1  := 1 To oMdlG6W:Length()
    If !oMdlG6W:IsDeleted(n1) .and. oMdlG6W:GetValue('G6W_STATUS') <> '2' //N�o Deletado e ativo
        cSeq      := oMdlG6W:GetValue('G6W_SEQ',n1)
        dDtIni    := oMdlG6W:GetValue('G6W_DTINI',n1)
        dDtFim    := oMdlG6W:GetValue('G6W_DTFIM',n1)
        cTpDoc    := oMdlG6W:GetValue('G6W_CODG6U',n1)
        If !VldDocEncavalado(oModel,cSeq,dDtIni,dDtFim,cTpDoc)
            lRet := .F.
            Exit
        Endif
    Endif
Next

Return lRet
//------------------------------------------------------------------------------
/* /{Protheus.doc} VldDocVenc
Fun��o responsavel pela valida��o dos documentos vencidos
@type Static Function
@author jacomo.fernandes
@since 10/07/2019
@version 1.0
@param oModel, object, (Descri��o do par�metro)
@return lRet, retorno l�gico
/*/
//------------------------------------------------------------------------------
Static Function VldDocVenc(oModel)
Local lRet      := .T.
Local oMdlG6w   := oModel:GetModel('G6WDETAIL')
Local cMdlId    := oModel:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

IF oMdlG6W:SeekLine({{'G6W_STATUS',"3"}})

    If IsBlind() .or. (!IsBlind() .and. FwAlertNoYes(STR0007,STR0008))//'Foram encontrados registros vencidos, deseja inativa-los?'##"Aten��o!!!"
        While oMdlG6W:SeekLine({{'G6W_STATUS',"3"}})
            If !oMdlG6W:SetValue('G6W_STATUS','2')
                lRet    := .F.
            Endif
        End
    ElseIf !FwAlertYesNo(STR0009,STR0008)//'Deseja salvar mesmo assim?'##"Aten��o!!!"
        lRet        := .F.
        cMsgErro    := STR0010//"Foram encontrados registro vencidos"
        cMsgSol     := STR0011//"Inative-os antes de concluir o cadastros"
    Endif
Endif

If !lRet .and. !Empty(cMsgErro)
    oModel:SetErrorMessage(cMdlId,'',cMdlId,'',"VldDocEncavalado",cMsgErro,cMsgSol)
Endif    

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} VldDocEncavalado
Fun��o responsaval para verificar se possui algum registro com datas encavaladas do mesmo tipo de documento
@type Function
@author 
@since 10/07/2019
@version 1.0
@param oModel, character, (Descri��o do par�metro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function VldDocEncavalado(oModel,cSeq,dDtIni,dDtFim,cTpDoc,lAuto)
Local lRet      := .T.
Local oMdlG6W   := oModel:GetModel('G6WDETAIL')
Local cMdlId	:= oMdlG6W:GetId()
Local nLine     := oMdlG6W:GetLine()
Local cSeek     := ""
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Default lAuto := .F.

cSeek   += "#1 <> '"+cSeq+"' "//Diferente da sequencia posicionada

//Verifica os campos de datas se a data do registro posicionado est� encavalando
cSeek   += " .AND. ("
cSeek   += " (StoD('"+DtoS(dDtIni)+"') >= #2 .and. StoD('"+DtoS(dDtIni)+"') < #3)"
cSeek   += " .or. (StoD('"+DtoS(dDtFim)+"') > #2 .and. StoD('"+DtoS(dDtFim)+"') <= #3)"
cSeek   += " .or. (#2 >= StoD('"+DtoS(dDtIni)+"') .and. #2 < StoD('"+DtoS(dDtFim)+"') )"
cSeek   += " .or. (#3 > StoD('"+DtoS(dDtIni)+"') .and. #3 <= StoD('"+DtoS(dDtFim)+"') )"
cSeek   += " ) "

cSeek   += " .and. #4 <> '2' "//G6W_STATUS <> inativo
cSeek   += " .and. #5 == '"+cTpDoc+"' "//Que seja o mesmo tipo de documento

IF GTPxSeekLine(oMdlG6W,cSeek,{'G6W_SEQ','G6W_DTINI','G6W_DTFIM','G6W_STATUS','G6W_CODG6U'},.F.,.T.)
    lRet        := .F.
    cMsgErro    := STR0012+oMdlG6W:GetValue('G6W_SEQ')//"Foi encontrado o mesmo tipo de documento ativo na sequencia: "
    cMsgSol     := STR0013
Endif


If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,'',cMdlId,'',"VldDocEncavalado",cMsgErro,cMsgSol)
Endif    

If !lAuto
    oMdlG6W:GoLine(nLine)
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
Fun��o responsavel pela estrutura de dados do modelo
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param oStrG6V, object, (Descri��o do par�metro)
@param oStrG6W, object, (Descri��o do par�metro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrG6V,oStrG6W)
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bInit		:= {|oMdl,cField,uVal,nLine,uOldValue| FieldInit(oMdl,cField,uVal,nLine,uOldValue)}
Local bWhen		:= {|oMdl,cField,uVal| FieldWhen(oMdl,cField,uVal)}

If ValType(oStrG6V) == "O"
    
    oStrG6V:SetProperty('G6V_STATUS'    ,MODEL_FIELD_INIT	    ,bInit)

    oStrG6V:SetProperty('G6V_STATUS'    ,MODEL_FIELD_VALUES     ,GetComboBox('G6V_STATUS'))
  
    oStrG6V:AddTrigger('G6V_RECURS'     ,'G6V_RECURS'	        ,{||.T.}, bTrig)

    oStrG6V:SetProperty('G6V_RECURS'    ,MODEL_FIELD_VALID	    ,bFldVld)

Endif

If ValType(oStrG6W) == "O"
    GTPxCriaCpo(oStrG6W,{'G6U_TPVIGE','G6U_TEMPVI','G6U_TPTOLE','G6U_TEMPTO','G6U_DESCRI'},.T.)
    
    oStrG6W:AddField('','',"ANEXO"      ,"BT", 15,0,,,,.F.,{|| SetIniFld()}, .F., .F., .T.)
    oStrG6W:AddField('','','G6W_LEGEND' ,"BT",1,,,,,,,,,.T.,)

    oStrG6W:SetProperty('G6W_STATUS'    ,MODEL_FIELD_VALUES     ,GetComboBox('G6W_STATUS'))
   
    oStrG6W:SetProperty('G6W_LEGEND'	,MODEL_FIELD_INIT	    ,bInit)
    oStrG6W:SetProperty('G6W_STATUS'	,MODEL_FIELD_INIT	    ,bInit)
    
    oStrG6W:AddTrigger('G6W_CODG6U'	,'G6W_CODG6U'	,{||.T.}, bTrig)
    oStrG6W:AddTrigger('G6W_DTINI'	,'G6W_DTINI'	,{||.T.}, bTrig)
    oStrG6W:AddTrigger('G6W_DTFIM'	,'G6W_DTFIM'	,{||.T.}, bTrig)
    oStrG6W:AddTrigger('G6W_STATUS'	,'G6W_STATUS'	,{||.T.}, bTrig)

    oStrG6W:SetProperty('G6W_DTFIM' 	,MODEL_FIELD_WHEN	    ,bWhen)
    oStrG6W:SetProperty('G6W_DTMAX'     ,MODEL_FIELD_WHEN	    ,bWhen)

    oStrG6W:SetProperty('G6W_CODG6U'   ,MODEL_FIELD_VALID	    ,bFldVld)
    oStrG6W:SetProperty('G6W_DTINI'    ,MODEL_FIELD_VALID	    ,bFldVld)
    oStrG6W:SetProperty('G6W_DTFIM'    ,MODEL_FIELD_VALID	    ,bFldVld)
    oStrG6W:SetProperty('G6W_STATUS'   ,MODEL_FIELD_VALID	    ,bFldVld)
Endif

Return nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid(oMdl,cField,uNewValue,uOldValue)
Fun��o responsavel pela valida��o dos campos
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param oMdl, character, (Descri��o do par�metro)
@param cField, character, (Descri��o do par�metro)
@param uNewValue, character, (Descri��o do par�metro)
@param uOldValue, character, (Descri��o do par�metro)
@return lRet, retorno logico dizendo se a valida��o � com sucesso ou erro
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
    Case Empty(uNewValue)
		lRet := .T.
    Case cField == "G6V_RECURS"
        If !GTPExistCpo(If(oMdl:GetValue('G6V_TRECUR') == "1","GYG","ST9"),uNewValue,1)
            lRet		:= .F.
            cMsgErro	:= STR0014//"Registro n�o existe ou se encontra bloqueado"
            cMsgSol		:= STR0015//"Verifique se o mesmo se encontra cadastrado e ativo para uso"
        Endif

        If lRet .and. !VldExistRec(oMdl)
            lRet		:= .F.
            cMsgErro	:= STR0016//"Recurso informado j� cadastrado"
            cMsgSol		:= STR0017//"Verifique se o c�digo informado esta correto ou altere o registro do recurso informado"
        Endif
    Case cField == "G6W_CODG6U"
        If !GTPExistCpo('G6U',uNewValue,1)
            lRet		:= .F.
            cMsgErro	:= STR0014//"Registro n�o existe ou se encontra bloqueado"
            cMsgSol		:= STR0015//"Verifique se o mesmo se encontra cadastrado e ativo para uso"
        ElseIf Posicione('G6U',1,FWxFilial('G6U')+uNewValue,"G6U_TRECUR") <> oModel:GetModel('G6VMASTER'):GetValue('G6V_TRECUR')
            lRet		:= .F.
            cMsgErro	:= STR0028 //"Tipo de Documento Invalido"
            cMsgSol		:= STR0029 //"Informe um tipo de documento que seja do mesmo tipo do recurso"
        ElseIf !ExistTpDoc(oMdl,uNewValue)
            lRet		:= .F.
            cMsgErro	:= STR0030 //"J� possui o mesmo Tipo de Documento informado ativo"
            cMsgSol		:= STR0031 //"Informe outro registro ou inative o registro anterior"
        Endif

    Case cField == "G6W_DTINI"
        If !VldDocEncavalado(oModel,oMdl:GetValue('G6W_SEQ'),uNewValue,oMdl:GetValue('G6W_DTFIM'),oMdl:GetValue('G6W_CODG6U'))
            lRet := .F.
        Endif
    Case cField == "G6W_DTFIM"
        If !VldDocEncavalado(oModel,oMdl:GetValue('G6W_SEQ'),oMdl:GetValue('G6W_DTINI'),uNewValue,oMdl:GetValue('G6W_CODG6U'))
            lRet := .F.
        Endif
    Case cField == "G6W_STATUS"
        If !VldDocEncavalado(oModel,oMdl:GetValue('G6W_SEQ'),oMdl:GetValue('G6W_DTINI'),oMdl:GetValue('G6W_DTFIM'),oMdl:GetValue('G6W_CODG6U'))
            lRet := .F.
        ElseIf uNewValue <> '2' .and. !ExistTpDoc(oMdl,oMdl:GetValue('G6W_CODG6U'))
            lRet		:= .F.
            cMsgErro	:= STR0030 //"J� possui o mesmo Tipo de Documento informado ativo"
            cMsgSol		:= STR0031 //"Informe outro registro ou inative o registro anterior"
        Endif
EndCase        

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Fun��o responsavel pelo gatilho dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param , character, (Descri��o do par�metro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)
Local oView := FwViewActive()

Do Case
    Case cField == "G6V_RECURS"
        oMdl:SetValue('G6V_DRECUR',GTPGetRecDesc(uVal,oMdl:GetValue('G6V_TRECUR')))

    Case cField == "G6W_CODG6U"
        SetFieldG6U(oMdl,uVal)
        oMdl:SetValue('G6W_DTINI',StoD(''))
    Case cField == "G6W_DTINI"
        oMdl:SetValue('G6W_DTFIM',GetDtVigencia(uVal,oMdl:GetValue('G6U_TPVIGE'),oMdl:GetValue('G6U_TEMPVI')))

    Case cField == "G6W_DTFIM"
        oMdl:SetValue('G6W_DTMAX',GetDtVigencia(uVal,oMdl:GetValue('G6U_TPTOLE'),oMdl:GetValue('G6U_TEMPTO')))
        If uVal >= dDataBase
            oMdl:SetValue('G6W_STATUS','1',.T.)
        Else
            oMdl:SetValue('G6W_STATUS','3',.T.)
        Endif
    Case cField == "G6W_STATUS"
        oMdl:SetValue('G6W_LEGEND',GetLegenda(oMdl,.F.))
EndCase

If !IsBlind() .and. ValType(oView) == "O" .and. oView:IsActive()
    oView:Refresh()
Endif

Return uVal
//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Fun��o responsavel pela inicializa��o dos campos
@type Static Function
@author 
@since 08/07/2019
@version 1.0
@param , character, (Descri��o do par�metro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Local uRet      := uVal
Local lInsert   := oMdl:GetOperation() == MODEL_OPERATION_INSERT

Do Case 
	//Inicializadores da tabela G6V
	Case cField == "G6V_STATUS"
        uRet := "1"
  
    Case cField == "G6W_STATUS"
        uRet := "1"
    
    Case cField == "G6W_LEGEND"
        uRet := If(!lInsert,GetLegenda(oMdl,.F.),"BR_VERDE")

EndCase

Return uRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldWhen
Fun��o responsavel pelo When dos Campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param uVal, character, (Descri��o do par�metro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldWhen(oMdl,cField,uVal)
Local lRet		:= .T.
Local lTrig		:= FwIsInCallStack('FIELDTRIGGER')

Do Case
	Case lTrig
		lRet := .T.
    Case cField == "G6W_DTFIM"
        lRet := oMdl:GetValue("G6U_TPVIGE") == "4"
    Case cField == "G6W_DTMAX"
        lRet := oMdl:GetValue("G6U_TPTOLE") == "4"
EndCase

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Fun��o responsavel pela defini��o da view
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA316')
Local oStrG6V	:= FWFormStruct(2, 'G6V')
Local oStrG6W	:= FWFormStruct(2, 'G6W')
Local bDblClick := {{|oGrid,cField,nLineGrid,nLineModel| SetDblClick(oGrid,cField,nLineGrid,nLineModel)}}

SetViewStruct(oStrG6V,oStrG6W)

oView:SetModel(oModel)

oView:AddField('VIEW_G6V'   ,oStrG6V,'G6VMASTER')
oView:AddGrid('VIEW_G6W'    ,oStrG6W,'G6WDETAIL')

oView:CreateHorizontalBox('UPPER'   , 20)
oView:CreateHorizontalBox('BOTTOM'  , 80)

oView:SetOwnerView('VIEW_G6V','UPPER')
oView:SetOwnerView('VIEW_G6W','BOTTOM')

oView:SetDescription(STR0004) //'Amarra��o do Recurso x Documento'

oView:AddIncrementField('VIEW_G6W','G6W_SEQ')


oView:AddUserButton(STR0018,"", {|oView| GetLegenda(oView,.T.) })//"Legenda" 

oView:SetViewProperty("VIEW_G6W", "GRIDDOUBLECLICK", {{|oGrid,cField,nLineGrid,nLineModel| SetDoubleClick(oGrid,cField,nLineGrid,nLineModel)}})

oView:SetViewProperty("VIEW_G6W", "GRIDDOUBLECLICK", bDblClick)

Return oView


//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
Fun��o responsavel pela estrutura de dados da view
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param oStrG6V, object, (Descri��o do par�metro)
@param oStrG6W, object, (Descri��o do par�metro)
@return nil, retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrG6V,oStrG6W)

If ValType(oStrG6V) == "O"
    
    oStrG6V:RemoveField('G6V_CODIGO')
    oStrG6V:RemoveField('G6V_TRECUR')
    
    oStrG6V:SetProperty('G6V_STATUS'    ,MVC_VIEW_COMBOBOX  ,GetComboBox('G6V_STATUS'))

    oStrG6V:SetProperty("G6V_RECURS"	,MVC_VIEW_ORDEM		, '01' )
    oStrG6V:SetProperty("G6V_DRECUR"	,MVC_VIEW_ORDEM		, '02' )
    oStrG6V:SetProperty("G6V_STATUS"	,MVC_VIEW_ORDEM		, '03' )
Endif

If ValType(oStrG6W) == "O"
    GTPxCriaCpo(oStrG6W,{'G6U_DESCRI'},.F.)
    oStrG6W:AddField("ANEXO","00","Anexos","Anexos",{""},"GET","@BMP",Nil,"",.T.,Nil,"",Nil,Nil,Nil,.T.,Nil,.F.) // "Anexos"
    oStrG6W:AddField("G6W_LEGEND","01","","",{},"BT","",Nil,Nil,.F.,"",Nil,Nil,Nil,Nil,.T.,Nil)

    oStrG6W:SetProperty('G6W_STATUS'    ,MVC_VIEW_COMBOBOX     ,GetComboBox('G6W_STATUS'))

    oStrG6W:SetProperty('G6U_DESCRI'    ,MVC_VIEW_CANCHANGE     ,.F.)

    oStrG6W:SetProperty("ANEXO"	        ,MVC_VIEW_ORDEM		, '01' )
    oStrG6W:SetProperty("G6W_LEGEND"	,MVC_VIEW_ORDEM		, '02' )
    oStrG6W:SetProperty("G6W_SEQ"	    ,MVC_VIEW_ORDEM		, '03' )
    oStrG6W:SetProperty("G6W_CODG6U"	,MVC_VIEW_ORDEM		, '04' )
    oStrG6W:SetProperty("G6U_DESCRI"	,MVC_VIEW_ORDEM		, '05' )
    oStrG6W:SetProperty("G6W_DTINI" 	,MVC_VIEW_ORDEM		, '06' )
    oStrG6W:SetProperty("G6W_DTFIM" 	,MVC_VIEW_ORDEM		, '07' )
    oStrG6W:SetProperty("G6W_DTMAX"	    ,MVC_VIEW_ORDEM		, '08' )
    oStrG6W:SetProperty("G6W_STATUS"	,MVC_VIEW_ORDEM		, '09' )
    
Endif

Return nil
//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA316F3
Fun��o responsavel para filtrar a consulta padr�o conforme o tipo de recurso
@type Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param , character, (Descri��o do par�metro)
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPA316F3()
Local cRet          := "@#"
Local oModel        := FwModelActive()
Local cTpRecurso    := ""

If oModel:GetId() == 'GTPA316'

    cTpRecurso := oModel:GetValue('G6VMASTER','G6V_TRECUR')

    cRet += " G6U->G6U_TRECUR = '"+cTpRecurso+"' .AND. G6U->G6U_MSBLQL <>'1' "

    cRet+= "@#"

Endif

Return cRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} GetComboBox
Fun��o Responsavel para retornar o array contendo os valores do ComboBox
@type Static Function
@author jacomo.fernandes
@since 04/07/2019
@version 1.0
@param cField, character, (Descri��o do par�metro)
@return aRetCBox, array contendo os valores do ComboBox
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GetComboBox(cField)
Local aRetCBox   := {}
        
Do Case
    Case cField == 'G6V_STATUS'
        aAdd(aRetCBox,"1="+STR0001)//"Validar"
        aAdd(aRetCBox,"2="+STR0002)//"N�o Validar"
        aAdd(aRetCBox,"3="+STR0003)//"Bloquear"

    Case cField == "G6W_STATUS"
        aAdd(aRetCBox,"1="+STR0019)//"Ativo"
        aAdd(aRetCBox,"2="+STR0020)//"Inativo"
        aAdd(aRetCBox,"3="+STR0021)//"Vencido"

EndCase

Return aRetCBox

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetFieldG6U
Fun��o responsavel pelo preenchimento dos campos do tipo de documento
@type Static Function
@author jacomo.fernandes
@since 08/07/2019
@version 1.0
@param oMdl, object, (Descri��o do par�metro)
@param cCodG6U, character, (Descri��o do par�metro)
@return nil, retorna nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetFieldG6U(oMdl,cCodG6U)
Local aAreaG6U  := G6U->(GetArea())

G6U->(DbSetOrder(1))//G6U_FILIAL+G6U_CODIGO
If G6U->(DbSeek(xFilial('G6U')+cCodG6U))

    oMdl:SetValue('G6U_TPVIGE',G6U->G6U_TPVIGE)
    oMdl:SetValue('G6U_TEMPVI',G6U->G6U_TEMPVI)
    oMdl:SetValue('G6U_TPTOLE',G6U->G6U_TPTOLE)
    oMdl:SetValue('G6U_TEMPTO',G6U->G6U_TEMPTO)
    oMdl:SetValue('G6U_DESCRI',G6U->G6U_DESCRI)

Endif

RestArea(aAreaG6U)
GtpDestroy(aAreaG6U)
Return nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetDtVigencia
Fun��o responsavel para calcular a proxima data
@type Static Function
@author jacomo.fernandes
@since 08/07/2019
@version 1.0
@param dDtIni, date, (Descri��o do par�metro)
@param cTpVigen, character, (Descri��o do par�metro)
@param nTempVig, numeric, (Descri��o do par�metro)
@return dDtFim, retorna a proxima data de acordo com os parametros informados
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GetDtVigencia(dDtIni,cTpVigen,nTempVig)
Local dDtFim    := dDtIni

Do Case
    Case cTpVigen == "1" //Dia
        dDtFim  := DaySum(dDtIni,nTempVig)
    Case cTpVigen == "2" //Mes
        dDtFim  := MonthSum(dDtIni,nTempVig)
    Case cTpVigen == "3" //Ano
        dDtFim  := YearSum(dDtIni,nTempVig)
EndCase

Return dDtFim

//------------------------------------------------------------------------------
/* /{Protheus.doc} GetLegenda

@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param oObj, object, (Descri��o do par�metro)
@param lTela, boolean, (Descri��o do par�metro)
@return uRet, Retorno indefinido
/*/
//------------------------------------------------------------------------------
Static Function GetLegenda(oObj,lTela)
Local uRet      := nil
Local oLegenda	:= FWLegend():New()
Local oModel    := oObj:GetModel()
Local oMdlG6W   := oModel:GetModel('G6WDETAIL')
Local lModel    := !lTela .and. oMdlG6W:GetLine() > 0 

oLegenda:Add({||If(lModel,oMdlG6W:GetValue('G6W_STATUS'),G6W->G6W_STATUS) == '1'},"GREEN"   ,STR0019)//"Ativo"
oLegenda:Add({||If(lModel,oMdlG6W:GetValue('G6W_STATUS'),G6W->G6W_STATUS) == '2'},"RED"     ,STR0020)//"Inativo"
oLegenda:Add({||If(lModel,oMdlG6W:GetValue('G6W_STATUS'),G6W->G6W_STATUS) == '3'},"ORANGE"  ,STR0021)//"Vencido"

oLegenda:Activate()

If lTela
	oLegenda:View()
Else
    uRet := oLegenda:Execute()
Endif

oLegenda:DeActivate()

GTPDestroy(oLegenda) //Destroi o objeto

Return uRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} SetDoubleClick
(long_description)
@type function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param oGrid, objeto, (Descri��o do par�metro)
@param cField, character, (Descri��o do par�metro)
@param nLineGrid, num�rico, (Descri��o do par�metro)
@param nLineModel, num�rico, (Descri��o do par�metro)
/*/
//------------------------------------------------------------------------------
Static Function SetDoubleClick(oGrid,cField,nLineGrid,nLineModel)

If cField == "G6W_LEGEND"
    GetLegenda(oGrid,.T.)
Endif

Return .T. 


//------------------------------------------------------------------------------
/* /{Protheus.doc} VldExistRec
Fun��o responsavel para verificar se o recurso informado j� possui cadastro
@type Static Function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param oMdl, object, (Descri��o do par�metro)
@return lRet, Retorno L�gico
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function VldExistRec(oMdl)
Local lRet          := .T.
Local cAliasTmp     := GetNextAlias()
Local cCodigo       := oMdl:GetValue('G6V_CODIGO')
Local cTpRecurso    := oMdl:GetValue('G6V_TRECUR')
Local cCodRecurso   := oMdl:GetValue('G6V_RECURS')

BeginSql Alias cAliasTmp
    Select COUNT(G6V_RECURS) AS TOTAL
    From %Table:G6V% G6V
    Where
        G6V.G6V_FILIAL = %xFilial:G6V%
        AND G6V.G6V_TRECUR = %Exp:cTpRecurso%
        AND G6V.G6V_RECURS = %Exp:cCodRecurso%
        AND G6V.G6V_CODIGO <> %Exp:cCodigo%
        AND G6V.%NotDel%
EndSql

lRet := (cAliasTmp)->TOTAL == 0

(cAliasTmp)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} ExistTpDoc
Fun��o responsavel para verificar se existe o mesmo tipo de documento ativo
@type Static Function
@author jacomo.fernandes
@since 17/07/2019
@version 1.0
@param oMdlG6W, object, (Descri��o do par�metro)
@param cCodG6U, character, (Descri��o do par�metro)
@return lRet, Retorno logico
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function ExistTpDoc(oMdlG6W,cCodG6U)
Local lRet  := .T.
Local nLine := oMdlG6W:GetLine()
Local cSeek := ""

cSeek   += "#1 <> '"+oMdlG6W:GetValue('G6W_SEQ')+"' "//Diferente da sequencia posicionada
cSeek   += " .AND. #2 == '"+cCodG6U+"' " //G6W_CODG6U
cSeek   += " .AND. #3 <> '2' "

IF GTPxSeekLine(oMdlG6W,cSeek,{'G6W_SEQ','G6W_CODG6U','G6W_STATUS'},.F.,.T.)
    If IsBlind() .or. (!IsBlind() .and. FwAlertYesNo(I18n(STR0032,{oMdlG6W:GetValue('G6W_SEQ')}),STR0008) ) //'Tipo de Documento informado se encontra ativo na sequencia #1. Deseja Inativar o registro?' ## "Aten��o!!!"
        oMdlG6W:SetValue('G6W_STATUS',"2")
    Else
        lRet := .F.
    Endif
Endif
oMdlG6W:GoLine(nLine)

Return lRet

/*/{Protheus.doc} SetIniFld()
(long_description)
@type  Static Function
@author flavio.martins
@since 18/10/2022
@version 1.0@param , param_type, param_descr
@return cValor
@example
(examples)
@see (links_or_references)
/*/
Static Function SetIniFld()
Local cValor := ''

AC9->(dbSetOrder(2))

If AC9->(dbSeek(xFilial('AC9')+'G6W'+xFilial('G6W')+xFilial('G6W')+G6W->G6W_CODIGO+G6W->G6W_SEQ))
    cValor := "F5_VERD"
Else
    cValor := 'F5_VERM'
Endif

Return cValor

/*/{Protheus.doc} AttachDocs(oView)
(long_description)
@type  Static Function
@author flavio.martins
@since 28/09/2022
@version 1.0@param , param_type, param_descr
@return nil
@example
(examples)
@see (links_or_references)
/*/
Static Function AttachDocs(oView)
Local nRecno := oView:GetModel():GetModel('G6WDETAIL'):GetDataId()

MsDocument('G6W' , G6W->(nRecno),3)

oView:GetModel():GetModel('G6WDETAIL'):LoadValue("ANEXO", SetIniFld())
oView:Refresh()

Return 

/*/{Protheus.doc} SetDblClick(oGrid,cField,nLineGrid,nLineModel)
(long_description)
@type  Static Function
@author flavio.martins
@since 30/09/2022
@version 1.0@param , param_type, param_descr
@return nil
@example
(examples)
@see (links_or_references)
/*/
Static Function SetDblClick(oGrid,cField,nLineGrid,nLineModel)
Local oView := FwViewActive()

If cField == 'ANEXO'
    AttachDocs(oView)
Endif

Return .T.
