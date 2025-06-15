#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "RMIPROCESSO.CH"

//Defini��es do array aProcessos
#DEFINE MIMFUNCOES  7
#DEFINE MHNGATILH   8

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiCadProc
Processos

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiCadProc()

	Local oBrowse := Nil
    If AmIIn(12)// Acesso apenas para modulo e licen�a do Varejo
    
        //Carrega registros padr�es
        Processa( {|| RmiCargaPr()}, STR0010, STR0011 )   //"Carregando Processos Padr�es"   //"Aguarde. . ."
        
        oBrowse := FWMBrowse():New()
        
        oBrowse:SetDescription(STR0001)   //"Processos"
        oBrowse:SetAlias("MHN")
        oBrowse:SetLocate()
        oBrowse:Activate()
    else
        MSGALERT(STR0020)// "Esta rotina deve ser executada somente pelo m�dulo 12 (Controle de Lojas)"
    EndIf
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transa��o a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Altera��o sem inclus�o de registros
7 - C�pia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0002, "PesqBrw"           , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.RMICADPROC", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.RMICADPROC", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.RMICADPROC", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.RMICADPROC", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.RMICADPROC", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Base da Decis�o

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView      := Nil
	Local oModel     := FWLoadModel("RMICADPROC")
	Local oStructMHN := FWFormStruct(2, "MHN")
    Local oStructMHS := FWFormStruct(2, "MHS")
    Local oStructMIM := Nil
    Local lMIM       := FwAliasInDic("MIM")
    Local aTamanho   := {40, 60}
    Local aEtapaCmb  := {}

    If lMIM
        oStructMIM := FWFormStruct(2, "MIM")
        oStructMIM:RemoveField("MIM_CPROCE")

        If MIM->( ColumnPos("MIM_DESCRI") ) > 0 .And. !oStructMIM:HasField("MIM_DESCRI")
            oStructMIM:AddField("MIM_DESCRI", GetSx3Cache("MIM_DESCRI", "X3_ORDEM"), RetTitle("MIM_DESCRI"), "", {}, "C", "", Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
        EndIf

        aEtapaCmb := StrTokArr( GetSx3Cache("MIM_ETAPA", "X3_CBOX"), ";" )

        If Len(aEtapaCmb) < 3
            Aadd(aEtapaCmb, "3=P�s Publica��o")

            oStructMIM:SetProperty("MIM_ETAPA", MVC_VIEW_COMBOBOX, aEtapaCmb)
        EndIf

        aTamanho   := {30, 35, 35}
    EndIf

    oStructMHS:RemoveField("MHS_CPROCE")
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription(STR0001)   //"Processos"

	oView:AddField("MHNVIEW", oStructMHN, "MHNMASTER")
	oView:CreateHorizontalBox("MHNFIELD"  , aTamanho[1])
	oView:SetOwnerView("MHNVIEW", "MHNFIELD")
    oView:EnableTitleView("MHNVIEW", STR0001)           //"Processos"

   	oView:AddGrid("MHSVIEW", oStructMHS, "MHSDETAIL")
    oView:CreateHorizontalBox("MHSGRID", aTamanho[2])
    oView:SetOwnerView("MHSVIEW", "MHSGRID")
    oView:EnableTitleView("MHSVIEW", STR0008)           //"Tabelas Secund�rias"

    If lMIM
        oView:AddGrid("MIMVIEW", oStructMIM, "MIMDETAIL")
        oView:CreateHorizontalBox("MIMGRID", aTamanho[3])
        oView:SetOwnerView("MIMVIEW", "MIMGRID")
        oView:EnableTitleView("MIMVIEW", STR0023)       //"Fun��es"
    EndIf

	oView:EnableControlBar(.T.)

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Base da Decis�o

@author  Rafael Tenorio da Costa
@since   24/09/19
@version 1.0

@obs MHNMASTER - Processos
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := Nil
	Local oStructMHN := FWFormStruct(1, "MHN")
    Local oStructMHS := FWFormStruct(1, "MHS")
    Local oStructMIM := Nil
    Local lMIM       := FwAliasInDic("MIM")
    Local aEtapaCmb  := {}

    If lMIM
        oStructMIM := FWFormStruct(1, "MIM")

        If MIM->( ColumnPos("MIM_DESCRI") ) > 0 .And. !oStructMIM:HasField("MIM_DESCRI")
            oStructMIM:AddField(RetTitle("MIM_DESCRI"), "", "MIM_DESCRI" , "C", TamSx3("MIM_DESCRI")[1], 0, Nil, Nil, Nil, Nil, Nil, Nil, Nil, .T.)
        EndIf

        aEtapaCmb := StrTokArr( GetSx3Cache("MIM_ETAPA", "X3_CBOX"), ";" )

        If Len(aEtapaCmb) < 3
            Aadd(aEtapaCmb, "3=P�s Publica��o")

            oStructMIM:SetProperty("MIM_ETAPA", MODEL_FIELD_VALUES, aEtapaCmb)
        EndIf
    EndIf

    If MHS->(ColumnPos("MHS_TIPO")) > 0 
        oStructMHS:SetProperty("MHS_TIPO", MODEL_FIELD_WHEN, {|| FwFldGet('MHS_TABELA') == 'MIL'})
    EndIf
	
	//-----------------------------------------
	//Monta o modelo do formul�rio
	//-----------------------------------------
	oModel:= MPFormModel():New( "RMICADPROC", /*Pre-Validacao*/, {|oModel| RmiVldCmp(oModel)}, /*Commit*/, /*Cancel*/)
	oModel:SetDescription( STR0009 )    //"Modelo de Processo"

	oModel:AddFields( "MHNMASTER", NIL, oStructMHN, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:GetModel( "MHNMASTER" ):SetDescription( STR0001 )    //"Processos"

    oModel:AddGrid("MHSDETAIL", "MHNMASTER", oStructMHS, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/)
	oModel:GetModel("MHSDETAIL"):SetDescription(STR0008)  //"Tabelas Secund�rias"
    iF !MHS->(ColumnPos("MHS_TIPO")) > 0 
        oModel:GetModel("MHSDETAIL"):SetUniqueLine( {"MHS_TABELA"})    
    else
        oModel:GetModel("MHSDETAIL"):SetUniqueLine( {"MHS_TABELA", "MHS_TIPO" } )    
    EndIf
	oModel:SetRelation("MHSDETAIL", { { "MHS_FILIAL", "MHN_FILIAL" }, { "MHS_CPROCE", "MHN_COD" } }, MHS->( IndexKey(1) ))  //MHS_FILIAL+MHS_CPROCE+MHS_TABELA
    oModel:SetOptional("MHSDETAIL", .T.)

    If lMIM
        oModel:AddGrid("MIMDETAIL", "MHNMASTER", oStructMIM, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/)
        oModel:GetModel("MIMDETAIL"):SetDescription(STR0023)  //"Fun��es"
        oModel:GetModel("MIMDETAIL"):SetUniqueLine( {"MIM_ETAPA", "MIM_FUNCAO"} )
        oModel:SetRelation("MIMDETAIL", { { "MIM_FILIAL", "MHN_FILIAL" }, { "MIM_CPROCE", "MHN_COD" } }, MIM->( IndexKey(1) ))  //MIM_FILIAL+MIM_CPROCE+MIM_ETAPA
        oModel:SetOptional("MIMDETAIL", .T.)
    EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiCargaPr
Rotina que ira efetuar a carga inicial caso n�o exist�o registros na tabela.

@author  Rafael Tenorio da Costa
@since   04/10/19
@version 1.0
/*/
//-------------------------------------------------------------------
Function RmiCargaPr()

    Local aArea      := GetArea()
    Local aProcessos := {}
    Local aTabSecund := {}
    Local aFuncoes   := {}
    Local nProc      := 1
    Local nCont      := 1
    Local lCmpMhnFil := MHN->( ColumnPos("MHN_FILTRO")  ) > 0
    Local lCmpMhsFil := MHS->( ColumnPos("MHS_FILTRO")  ) > 0
    Local lCmpMhnSec := MHN->( ColumnPos("MHN_SECOBG")  ) > 0
    Local lFieldPub  := MHS->( ColumnPos("MHS_CONPUB")  ) > 0
    Local lFieldTipo := MHS->( ColumnPos("MHS_TIPO")    ) > 0
    Local lMIM       := FwAliasInDic("MIM")
    Local lCmpDescri := .F.
    Local lCmpAtivo  := .F.

    If lMIM
        lCmpDescri := MIM->( ColumnPos("MIM_DESCRI") ) > 0
        lCmpAtivo  := MIM->( ColumnPos("MIM_ATIVO" ) ) > 0
    EndIf

    aTabSecund := {}
    Aadd(aTabSecund, {"MEU", "MEU_FILIAL+MEU_CODIGO","","1"})  
    Aadd(aTabSecund, {"MEV", "MEV_FILIAL+MEV_CODKIT","","1"})
    Aadd(aTabSecund, {"ACV", "ACV_FILIAL+ACV_CODPRO","","1"})
    Aadd(aTabSecund, {"SB5", "B5_FILIAL+B5_COD"     ,"","1"})
    If lFieldTipo
        Aadd(aTabSecund, {"MIL", "MIL_FILIAL+MIL_ENTRAD","MIL_TIPREL = 'FECP'"      ,"1", "FECP"        })
        Aadd(aTabSecund, {"MIL", "MIL_FILIAL+MIL_ENTRAD","MIL_TIPREL = 'ICMS'"      ,"1", "ICMS"        })
        Aadd(aTabSecund, {"MIL", "MIL_FILIAL+MIL_ENTRAD","MIL_TIPREL = 'PIS/COFINS'","1", "PIS/COFINS"  })
    EndIf
    aFuncoes := {}
    Aadd(aFuncoes  , {"2", "RMIPUBGRAD", STR0026, "1"})     //"Publica a varia��o da grade do produto"
    Aadd(aFuncoes  , {"1", "RMIIMPPRO" , STR0027, "2"})     //"Gera impostos na tabela auxiliar"
    Aadd(aFuncoes  , {"3", "RMIMIXPROD", STR0030, "2"}) //"Mix de Produto - Motor de promo��es"
    Aadd(aFuncoes  , {"3", "RMISITPROD", STR0031,"2"})//"Situa��o do Produto - Motor de promo��es"
    Aadd(aFuncoes  , {"1", "RMIMARCA", STR0036,"2"})//"Publica�ao de marca do produto - Venda Digital"
    Aadd(aProcessos, {"PRODUTO", "SB1", "B1_FILIAL+B1_COD", aClone(aTabSecund), "", "", aClone(aFuncoes)})

    aTabSecund := {}
    Aadd(aProcessos, {"CLIENTE", "SA1", "A1_FILIAL+A1_COD+A1_LOJA", aTabSecund})

    aTabSecund := {}
    Aadd(aTabSecund, {"DA0"    , "DA0_FILIAL+DA0_CODTAB"})
    Aadd(aProcessos, {"PRECO"  , "DA1", "DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_ITEM", aClone(aTabSecund) } )

    aTabSecund := {}
    Aadd(aTabSecund, {"SL2", "L2_FILIAL+L2_NUM"})
    Aadd(aTabSecund, {"SL4", "L4_FILIAL+L4_NUM"})                      	
    Aadd(aProcessos, {"VENDA"  , "SL1", "L1_FILIAL+L1_NUM" ,aClone(aTabSecund)})

    aTabSecund := {}
    Aadd(aTabSecund, {"SL2", "L2_FILIAL+L2_NUM"})
    Aadd(aTabSecund, {"SL4", "L4_FILIAL+L4_NUM"})                      	
    Aadd(aProcessos, {"PEDIDO", "SL1", "L1_FILIAL+L1_NUM", aClone(aTabSecund)})

    aTabSecund := {}
    aFuncoes   := {}    
    Aadd(aProcessos, {"CONFIRMA PAGTO", "SL1", "L1_FILIAL+L1_NUM", aClone(aTabSecund), "", "", aClone(aFuncoes), ""})

    aTabSecund := {}
    aFuncoes   := {}
    Aadd(aFuncoes  , {"2", "RMIPUBSTPE", STR0028, "1"})     //"Publica o status do pedido"
    Aadd(aProcessos, {"STATUS PEDIDO", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "STATUSPEDIDO"})

    aTabSecund := {}
    Aadd(aTabSecund, {"CLK", "CLK_FILIAL+CLK_CODNCM","&RMIFiltPro('NCM')","1"})
    Aadd(aProcessos, {"NCM","SYD","YD_FILIAL+YD_TEC",aTabSecund,,"1"})
    
    aTabSecund := {}
    Aadd(aProcessos, {"CATEGORIA","ACU","ACU_FILIAL+ACU_COD",aTabSecund})

    aTabSecund := {}
    Aadd(aProcessos, {"UN MEDIDA","SAH","AH_FILIAL+AH_UNIMED",aTabSecund})

    aTabSecund := {}
    Aadd(aProcessos, {"CEST","F0G","F0G_FILIAL+F0G_CEST",aTabSecund})
    
    aTabSecund := {}
    Aadd(aProcessos, {"OPERADOR CAIXA","SA6","A6_FILIAL+A6_COD",aTabSecund})

    aTabSecund := {}
    Aadd(aProcessos, {"INVENTARIO","SB7","B7_FILIAL+B7_DATA+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE",aTabSecund})
    
    aTabSecund := {}
    Aadd(aProcessos, {"IMPOSTO PROD","XXX","PROCESSO EXCLUSIVO DO SISTEMA",aTabSecund})

    aTabSecund := {}
    Aadd(aProcessos, {"IMPOSTO VENDA","YYY","PROCESSO EXCLUSIVO DO SISTEMA",aTabSecund})

    aTabSecund  := {}
    Aadd(aTabSecund, {"MEN", "MEN_FILIAL+MEN_CODADM"})
    aFuncoes    := {}
    Aadd(aFuncoes  , {"3", "RMIPUBCNPG", STR0029, "2"})     //"Publica a Condi��o de Pagamento"
    Aadd(aProcessos, {"ADMINISTRADORA", "SAE", "AE_FILIAL+AE_COD", aClone(aTabSecund), "", "", aClone(aFuncoes), ""})

    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"CONDICAO PAGTO", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "CONDICAOPAGTO"})

    aTabSecund := {}
    aFuncoes   := {}
    Aadd(aProcessos, {"SANGRIA"     , "SE5", "", aClone(aTabSecund), "", "", aClone(aFuncoes), ""})

    aTabSecund := {}
    aFuncoes   := {}
    Aadd(aProcessos, {"SUPRIMENTO"  , "SE5", "", aClone(aTabSecund), "", "", aClone(aFuncoes), ""})    

    aTabSecund := {}
    Aadd(aProcessos, {"FORNECEDOR", "SA2", "A2_FILIAL+A2_COD+A2_LOJA", aTabSecund})

    aTabSecund := {}
    Aadd(aTabSecund, {"SD1", "D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA"})
    Aadd(aProcessos, {"NOTA DE ENTRADA" , "SF1", "F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA", aClone(aTabSecund), "F1_CHVNFE <> '' AND F1_ORIGEM <> 'SMARTCON' AND D_E_L_E_T_ = ' '"})
    
    aTabSecund := {}
    Aadd(aTabSecund, {"SD2", "D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA"})
    Aadd(aProcessos, {"NOTA DE SAIDA"   , "SF2", "F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA", aClone(aTabSecund), "F2_CHVNFE <> '' AND D_E_L_E_T_ = ' '"})

    aTabSecund := {}
    Aadd(aTabSecund, {"SD2", "D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA", "D_E_L_E_T_ = '*'"})
    Aadd(aProcessos, {"NOTA SAIDA CANC" , "SF2", "F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA", aClone(aTabSecund), "F2_CHVNFE <> '' AND D_E_L_E_T_ = '*'"})

    If FwAliasInDic("MIH")
        aTabSecund := {}
        Aadd(aProcessos, {"PERFIL OPERADOR" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("PERFIL DE OPERADOR" , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        Aadd(aProcessos, {"OPERADOR LOJA"   , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("OPERADOR DE LOJA"   , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        Aadd(aProcessos, {"FORMA PAGAMENTO" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("FORMA DE PAGAMENTO" , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        aFuncoes   := {}
        Aadd(aFuncoes  , {"1", "RmiPubPais",STR0032, "2"}) // "Publica Pais Motor de Promo��es"
        Aadd(aFuncoes  , {"1", "RmiPubEst", STR0033, "2"})   // "Publica Estado Motor de Promo��es"
        Aadd(aFuncoes  , {"1", "RmiPubCid",  STR0034, "2"})   //"Publica Cidade Motor de Promo��es"
        Aadd(aFuncoes  , {"1", "RmiPubRegi",STR0035 , "2"})   //"Publica Regi�o Motor de Promo��es"
        Aadd(aProcessos, {"CADASTRO LOJA" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("CADASTRO DE LOJA" , TamSX3("MIH_TIPCAD")[1] ) + "'","",aClone(aFuncoes)})

        aTabSecund := {}
        aFuncoes   := {}
        Aadd(aProcessos, {"GRUPO DE LOJAS" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("GRUPO DE LOJAS" , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        aFuncoes   := {}
        Aadd(aProcessos, {"COMPARTILHAMENT" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("COMPARTILHAMENTOS" , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        Aadd(aProcessos, {"ICMS" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("ICMS" , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        Aadd(aProcessos, {"PIS/COFINS" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("PIS/COFINS" , TamSX3("MIH_TIPCAD")[1] ) + "'"})
    
        aTabSecund := {}
        Aadd(aProcessos, {"MARCAS" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("MARCAS" , TamSX3("MIH_TIPCAD")[1] ) + "'"})

        aTabSecund := {}
        Aadd(aProcessos, {"COMPL PAGAMENTO" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("COMPLEM PAGAMENTO" , TamSX3("MIH_TIPCAD")[1] ) + "'"})
    
        aTabSecund  := {}
        aFuncoes    := {}
        Aadd(aProcessos, {"PRACA" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("PRACA" , TamSX3("MIH_TIPCAD")[1] ) + "'","",aClone(aFuncoes)})
    
    EndIf
    
    aTabSecund := {}
    Aadd(aProcessos, {"SALDO ESTOQUE", "SB2", "B2_FILIAL+B2_LOCAL+B2_COD", aTabSecund})
    
    aTabSecund := {}
    Aadd(aProcessos, {"CONF VENDA","", "", aTabSecund})

    aTabSecund := {}
    Aadd(aProcessos, {"GRADE", "SBV", "BV_FILIAL+BV_TABELA+BV_CHAVE", aTabSecund})

    aTabSecund := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"EMBALAGEM","SLK","LK_FILIAL+LK_CODBAR",aTabSecund})

    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"PAIS", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "PAIS"})
    
    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"ESTADO", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "ESTADO"})
    
    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"CIDADE", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "CIDADE"})

    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"MIX DE PRODUTO", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "MIXPROD"})

    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"SITUACAO PRODUT", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "SITPROD"})
    
    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"PRACA" , "MIH", "MIH_FILIAL+MIH_TIPCAD+MIH_DESC", aClone(aTabSecund), "MIH_TIPCAD = '" + PadR("PRACA" , TamSX3("MIH_TIPCAD")[1] ) + "'","",aClone(aFuncoes)})

    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"REGIAO", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "REGIAO"})

    aTabSecund  := {}
    Aadd(aFuncoes  , {"2", "RMIPUBCONF","Cria��o de publica��o de conferencia", "2"}) // "Cria��o de publica��o de conferencia"
    Aadd(aProcessos, {"CONFERENCIA", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "CONFERENCIA"})
    aTabSecund  := {}
    aFuncoes    := {}
    Aadd(aProcessos, {"PROMOCOES", "", "", aClone(aTabSecund), "", "", aClone(aFuncoes), "PROMOCOES"})    

    MHN->( DBSetOrder(1) )  //MHN_FILIAL+MHN_COD
    ProcRegua(3)
    
    Begin Transaction

        For nProc:=1 To Len(aProcessos)

            IncProc()
            
            If !MHN->( Dbseek( xFilial("MHN") + PadR(aProcessos[nProc][1], TamSx3("MHN_COD")[1]) ) )

                RecLock("MHN", .T.)
                    MHN->MHN_FILIAL := xFilial("MHN")
                    MHN->MHN_COD    := aProcessos[nProc][1]
                    MHN->MHN_TABELA := aProcessos[nProc][2]
                    MHN->MHN_CHAVE  := aProcessos[nProc][3]

                    If lCmpMhnFil  .And. Len(aProcessos[nProc]) > 4
                        MHN->MHN_FILTRO := aProcessos[nProc][5]
                    EndIf

                    If lCmpMhnSec  .And. Len(aProcessos[nProc]) > 5
                        MHN->MHN_SECOBG := aProcessos[nProc][6]
                    EndIf

                    If MHN->( ColumnPos("MHN_GATILH") ) > 0 .And. Len(aProcessos[nProc]) >= MHNGATILH
                        MHN->MHN_GATILH := aProcessos[nProc][MHNGATILH]
                    EndIf
                MHN->( MsUnLock() )

                //Inclui Tabelas Secund�rias
                aTabSecund := aProcessos[nProc][4]

                For nCont:=1 To Len(aTabSecund)

                    RecLock("MHS", .T.)
                        MHS->MHS_FILIAL := MHN->MHN_FILIAL
                        MHS->MHS_CPROCE := MHN->MHN_COD
                        MHS->MHS_TABELA := aTabSecund[nCont][1]
                        MHS->MHS_CHAVE  := aTabSecund[nCont][2]

                        If lCmpMhsFil  .And. Len(aTabSecund[nCont]) > 2
                            MHS->MHS_FILTRO := aTabSecund[nCont][3]
                        EndIf

                        // -- Indica se considera secund�ria na publica�ao
                        If lFieldPub .And. Len(aTabSecund[nCont]) > 3
                            MHS->MHS_CONPUB := aTabSecund[nCont][4]
                        EndIf

                        If lFieldTipo .And. Len(aTabSecund[nCont]) > 4
                            MHS->MHS_TIPO := aTabSecund[nCont][5]
                        EndIf

                    MHS->( MsUnLock() )
                Next nCont

                //Inclui Fun��es
                If lMIM .And. Len( aProcessos[nProc] ) >= MIMFUNCOES

                    aFuncoes := aProcessos[nProc][MIMFUNCOES]

                    For nCont:=1 To Len(aFuncoes)

                        RecLock("MIM", .T.)

                            MIM->MIM_FILIAL := MHN->MHN_FILIAL
                            MIM->MIM_CPROCE := MHN->MHN_COD
                            MIM->MIM_ETAPA  := aFuncoes[nCont][1]
                            MIM->MIM_FUNCAO := aFuncoes[nCont][2]

                            If lCmpDescri
                                MIM->MIM_DESCRI := aFuncoes[nCont][3]
                            EndIf

                            If lCmpAtivo
                                MIM->MIM_ATIVO  := aFuncoes[nCont][4]
                            EndIf
                        MIM->( MsUnLock() )

                    Next nCont
                EndIf

            EndIf
        Next nProc

    End Transaction

    FwFreeArray(aProcessos)
    FwFreeArray(aTabSecund)
    FwFreeArray(aFuncoes  )

    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiVldCmp
Rotina que ira efetuar a valida��o de todos os campos chaves, tanto
do cabe�alho quanto das tabelas secundarias

@author  Bruno Almeida
@since   13/11/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function RmiVldCmp(oModel)

Local lRet      := .T. //Variavel de retorno
Local oCab      := oModel:GetModel('MHNMASTER') //Model do cabecalho
Local oItens    := oModel:GetModel('MHSDETAIL') //Model dos itens
Local nX        := 0 //Variavel de loop
Local nI        := 0 //Variavel de loop
Local aCab      := {} //Campos do cabecalho
Local aItens    := {} //Campos de itens
Local cTabela   := "" //Tabela
Local nOperation:= oModel:GetOperation() //Operacao executada no modelo de dados.
Local lIsDelete := nOperation == MODEL_OPERATION_DELETE

If lIsDelete .OR. nOperation == MODEL_OPERATION_UPDATE
    If Alltrim(oCab:GetValue('MHN_TABELA')) == "XXX" .OR. Alltrim(oCab:GetValue('MHN_COD')) == "IMPOSTO PROD"
        lRet := .F.
        Help( ,, 'HELP',, oCab:GetValue('MHN_CHAVE'), 1, 0)//"� necessario preencher o campo Chave da tabela "
    EndIf

    If lRet .And. lIsDelete

        lRet := MsgNoYes( STR0021, Upper(STR0022) )     //"Ser� excluida a informa��o cadastrada na tabela MHP - Assinantes X Processos. Deseja prosseguir com a exclus�o ?"    "Confirma Exclus�o?"

        If lRet
            lRet := RMCPDelMHP(AllTrim(oCab:GetValue('MHN_COD')))
        EndIf
    EndIf
EndIf

If lRet .And. ( nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE )

    //Valida os campos do cabecalho
    If !Empty(oCab:GetValue('MHN_CHAVE')) .AND. !Empty(oCab:GetValue('MHN_TABELA'))

        aCab    := Separa(oCab:GetValue('MHN_CHAVE'),'+')
        cTabela := oCab:GetValue('MHN_TABELA')

        For nX := 1 To Len(aCab)
            If (cTabela)->(ColumnPos(aCab[nX])) == 0
                lRet := .F.
                MsgAlert(STR0012 + AllTrim(aCab[nX]) + STR0013 + cTabela) //"O campo " # " n�o existe na tabela "
                Exit
            EndIf

        Next nX

    EndIf

    //Valida os campos das tabelas secundarias
    If lRet

        For nX := 1 To oItens:Length()
            oItens:GoLine(nX)
            If !Empty(oItens:GetValue('MHS_TABELA'))
                If !Empty(oCab:GetValue('MHN_CHAVE'))
                    If !Empty(oItens:GetValue('MHS_CHAVE'))
                        aItens  := Separa(oItens:GetValue('MHS_CHAVE'),'+')
                        cTabela := oItens:GetValue('MHS_TABELA')

                        For nI := 1 To Len(aItens)
                            If (cTabela)->(ColumnPos(aItens[nI])) == 0
                                lRet := .F.
                                Help( ,, 'HELP',, STR0012 + AllTrim(aItens[nI]) + STR0013 + cTabela, 1, 0)//"O campo " # " n�o existe na tabela "
                                Exit
                            EndIf

                        Next nX
                    Else
                        lRet := .F.
                        Help( ,, 'HELP',, STR0014 + oItens:GetValue('MHS_TABELA'), 1, 0)//"� necessario preencher o campo Chave da tabela "
                    EndIf
                Else
                    lRet := .F.
                    Help( ,, 'HELP',, STR0014 + oCab:GetValue('MHN_TABELA'), 1, 0)//"� necessario preencher o campo Chave da tabela "
                EndIf

                If !lRet
                    Exit
                EndIf

            EndIf

        Next nX
    EndIf

    If lRet

        If oCab:HasField("MHN_GATILH")

            If Empty( oCab:GetValue("MHN_TABELA") ) .And. Empty( oCab:GetValue("MHN_GATILH") )
                lRet := .F.            
                oModel:SetErrorMessage("MHNMASTER", , , , , STR0024)    //"Processo inv�lido, um dos campos, tabela ou gatilho deve ser preenchido."
            EndIf
        Else

            If Empty( oCab:GetValue("MHN_TABELA") )
                lRet := .F.            
                oModel:SetErrorMessage("MHNMASTER", , , , , STR0025)    //"Processo inv�lido, campo tabela deve ser preenchido."
            EndIf
        EndIf
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RmiVldFilt
Essa fun��o tem o objetivo de validar os campos que foram digitados no 
filtro.

@author  Bruno Almeida
@since   02/07/2020
@version 1.0

/*/
//-------------------------------------------------------------------
Function RmiVldFilt(oCab, oItens)

Local lRet      := .T.  //Variavel de retorno
Local aFiltro   := {}   //Recebe os campos que foram digitados no filtro
Local nI        := 0    //Variavel de loop
Local nX        := 0    //Variavel de loop
Local cTags     := "AND|OR|=|D_E_L_E_T_|R_E_C_N_O_|R_E_C_D_E_L_" //Tags que n�o fazem parte da compara��o

Default oCab    := Nil
Default oItens  := Nil

If ValType(oCab) == "O" .AND. ValType(oItens) == "O"
    If !Empty(oCab:GetValue('MHN_FILTRO'))
        //Transforma em um array o conteudo do filtro
        aFiltro := Separa(AllTrim(oCab:GetValue('MHN_FILTRO'))," ")

        //Caso o array aFiltro n�o seja no minimo um tamanho de 3 posi��es,
        //significa que o filtro n�o � valido.
        If Len(aFiltro) >= 3
            If !(AllTrim(aFiltro[1]) $ 'AND|OR')
                //Percorre cada uma das posi��es do array para validar todos os campos
                For nI := 1 To Len(aFiltro)

                    //Caso a posi��o do array seja um espa�o em branco ou algumas das palavras listados no cont�m, n�o � necessario validar
                    If !Empty(aFiltro[nI]) .AND. !(AllTrim(aFiltro[nI]) $ cTags)

                        //Pega o conteudo do array e tenta verificar se � um campo
                        If (AllTrim(SubStr(aFiltro[nI],4,1)) == "_" ) .OR. (AllTrim(SubStr(aFiltro[nI],3,1)) == "_")
                            
                            If (oCab:GetValue('MHN_TABELA'))->(ColumnPos(aFiltro[nI])) == 0
                                lRet := .F.
                                Help( ,, 'HELP',, STR0012 + AllTrim(aFiltro[nI]) + STR0013 + AllTrim(oCab:GetValue('MHN_TABELA')), 1, 0,,,,,,{STR0015 + AllTrim(oCab:GetValue('MHN_FILTRO'))})//"O campo " # " n�o existe na tabela " # "Por favor, corrija o filtro -> "
                                Exit
                            EndIf

                        EndIf
                    EndIf
                Next nI
            Else
                lRet := .F.
                Help( ,, 'HELP',, STR0018 + AllTrim(oCab:GetValue('MHN_TABELA')) + STR0019, 1, 0,,,,,,{STR0015 + AllTrim(oCab:GetValue('MHN_FILTRO'))})//"O filtro da tabela " # " n�o pode iniciar com as palavras AND ou OR." # "Por favor, corrija o filtro -> "
            EndIf
        Else
            lRet := .F.
            Help( ,, 'HELP',, STR0016 + AllTrim(oCab:GetValue('MHN_TABELA')) + STR0017, 1, 0,,,,,,{STR0015 + AllTrim(oCab:GetValue('MHN_FILTRO'))}) //"O filtro informado para a tabela " # " n�o � valido." # "Por favor, corrija o filtro -> "
        EndIf
    EndIf

    If lRet
        //L� cada linha do grid
        For nX := 1 To oItens:Length()
            oItens:GoLine(nX)
            
            If !Empty(oItens:GetValue('MHS_FILTRO'))

                //Transforma em um array o conteudo do filtro
                aFiltro := Separa(AllTrim(oItens:GetValue('MHS_FILTRO'))," ")
                
                //Para o filtro, deve-se haver pelo menos tr�s posi��es 
                //para considerar um filtro valido
                If Len(aFiltro) >= 3
                    If !(AllTrim(aFiltro[1]) $ 'AND|OR')

                        //Loop para percorrer cada uma das posi��es
                        For nI := 1 To Len(aFiltro)

                            //Caso n�o seja nenhuma das palavras abaixo, ent�o entra no IF
                            If !Empty(aFiltro[nI]) .AND. !(AllTrim(aFiltro[nI]) $ cTags)

                                If (AllTrim(SubStr(aFiltro[nI],4,1)) == "_") .OR. (AllTrim(SubStr(aFiltro[nI],3,1)) == "_")

                                    If (oItens:GetValue('MHS_TABELA'))->(ColumnPos(aFiltro[nI])) == 0
                                        lRet := .F.
                                        Help( ,, 'HELP',, STR0012 + AllTrim(aFiltro[nI]) + STR0013 + AllTrim(oItens:GetValue('MHS_TABELA')), 1, 0,,,,,,{STR0015 + AllTrim(oItens:GetValue('MHS_FILTRO'))})//"O campo " # " n�o existe na tabela " # "Por favor, corrija o filtro -> "
                                        Exit
                                    EndIf
                                EndIf
                            EndIf
                        Next nI
                    Else
                        lRet := .F.
                        Help( ,, 'HELP',, STR0018 + AllTrim(oItens:GetValue('MHS_TABELA')) + STR0019, 1, 0,,,,,,{STR0015 + AllTrim(oItens:GetValue('MHS_FILTRO'))})//"O filtro da tabela " # " n�o pode iniciar com as palavras AND ou OR." # "Por favor, corrija o filtro -> "
                    EndIf
                Else
                    lRet := .F.
                    Help( ,, 'HELP',, STR0016 + AllTrim(oItens:GetValue('MHS_TABELA')) + STR0017, 1, 0,,,,,,{STR0015 + AllTrim(oItens:GetValue('MHS_FILTRO'))}) //"O filtro informado para a tabela " # " n�o � valido." # "Por favor, corrija o filtro -> "
                EndIf
                If !lRet
                    Exit
                EndIf
            EndIf
        Next nX
    EndIf

EndIf

Return lRet

/*/{Protheus.doc} RMCPDelMHP
    Usado para deletar o dado que est� associado na tabela MHP
    @type  Function
    @author Julio.Nery
    @since 12/01/2021
    @version 12
    @param cProcesso, caracter, processo que ser� pesquisado
    @return lRet, l�gico, se excluiu ou n�o
/*/
Static Function RMCPDelMHP(cProcesso)
Local lRet  := .F.
Local cQuery:= ""
Local cTabela:= "XTABMHP"

If !Empty(cProcesso)
    LjGrvLog("RMICADPROC","Inicio do processo de dele��o da MHP associada a MHN")
    cQuery := " SELECT R_E_C_N_O_ REC "
    cQuery += " FROM " + RetSqlName("MHP")
    cQuery += " WHERE MHP_FILIAL = '" + xFilial("MHP") + "' AND MHP_CPROCE = '" + cProcesso + "'"
    cQuery += " AND D_E_L_E_T_ = '' "
    DbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cTabela, .T., .F.)

    If (cTabela)->(Eof())
        LjGrvLog("RMICADPROC","N�o existe MHP associada a MHN")
    EndIf

    While (cTabela)->(!Eof())
        MHP->(DBGoTo((cTabela)->REC))
        RecLock("MHP",.F.)
            MHP->(DBDelete())
        MHP->(DBUnlock())
        LjGrvLog("RMICADPROC","Registro MHP Deletado com sucesso - Processo [" + cProcesso + "]" +;
                            " / Recno [" + cValToChar((cTabela)->REC) + "]")
        (cTabela)->( DbSkip() )
    EndDo

    (cTabela)->( DbCloseArea() )
    lRet := .T.
    LjGrvLog("RMICADPROC","T�rmino do processo de dele��o da MHP associada a MHN")
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RMIFiltPro
Rotina para armazenar os filtros padr�o dos processos cadastrados.

@author  Evandro Pattaro
@since   27/07/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function RMIFiltPro(cProce)
    Local cFilter := ""
    Local cEndFis := ""
    Local cEst    := ""
    
    
    Do Case
        Case cProce == 'NCM'

            cEndFis := IIf(SuperGetMv("MV_SPEDEND",, .F.),"M0_ESTCOB","M0_ESTENT")		// Se estiver como F refere-se ao endere�o de Cobran�a se estiver T  ao  endere�o de Entrega.
            cEst := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt  ,{cEndFis})[1][2]
            cFilter :=  "(CLK_DTINIV <= '"+DTOS(DATE())+"' AND CLK_DTFIMV >= '"+ DTOS(DATE())+"') AND CLK_UF = '"+cEst+"' "
            
            If Empty(cEst)
                LjGrvLog("RMICADPROC","Campo "+cEndFis+" vazio! Verifique o parametro MV_SPEDEND")
            EndIf

    End Case

Return cFilter
