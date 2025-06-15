#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PCPA136.CH"

/*/{Protheus.doc} PCPA136Atu
Abre a tela de Atualiza��o das demandas
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@return Nil
/*/
Function PCPA136Atu()

	Local aArea     := GetArea()
	Local oAtuDeman := AtualizaDemandas():New()

	oAtuDeman:AbreTela()
	oAtuDeman:Destroy()

	RestArea(aArea)

Return

/*/{Protheus.doc} AtualizaDemandas
Tela para atualiza��o das demandas (reimporta��o em lote)
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
/*/
CLASS AtualizaDemandas FROM LongClassName

	DATA oModel     AS OBJECT
	DATA oView      AS OBJECT
	DATA oParam     AS OBJECT

	METHOD New() CONSTRUCTOR
	METHOD AbreTela()
	METHOD Destroy()
	METHOD MarcaTodos()
	METHOD AcaoBotao(nOpcao)
	METHOD ProcessaAtualizacao()

ENDCLASS

/*/{Protheus.doc} New
Construtor da classe para a Limpeza da Base do MRP
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@return Self, objeto, classe AtualizaDemandas
/*/
METHOD New() CLASS AtualizaDemandas

	//Carrega os �ltimos par�metros do Pergunte de importa��o
	Pergunte("PCP136IMP", .F.)

	Self:oParam := JsonObject():New()
	Self:oParam["checkPDV"            ] := IIf(MV_PAR01 == 1, .T., .F.)
	Self:oParam["checkPRV"            ] := IIf(MV_PAR02 == 1, .T., .F.)
	Self:oParam["checkPMP"            ] := IIf(MV_PAR03 == 1, .T., .F.)
	Self:oParam["checkEMP"            ] := IIf(MV_PAR04 == 1, .T., .F.)
	Self:oParam["produtoDe"           ] := MV_PAR07
	Self:oParam["produtoAte"          ] := MV_PAR08
	Self:oParam["tipoMaterialDe"      ] := MV_PAR09
	Self:oParam["tipoMaterialAte"     ] := MV_PAR10
	Self:oParam["grupoMaterialDe"     ] := MV_PAR11
	Self:oParam["grupoMaterialAte"    ] := MV_PAR12
	Self:oParam["documnentoDe"        ] := MV_PAR13
	Self:oParam["documnentoAte"       ] := MV_PAR14
	Self:oParam["consideraPVBloqueio" ] := IIf(MV_PAR15 == 1, .T., .F.)
	Self:oParam["descontaPV"          ] := IIf(MV_PAR16 == 1, .T., .F.)
	Self:oParam["periodicidade"       ] := cValToChar(MV_PAR17)
	Self:oParam["direcao"             ] := MV_PAR18
	Self:oParam["dataPedidosFaturados"] := MV_PAR20
	Self:oParam["consideraArmazem"    ] := MV_PAR21

Return Self

/*/{Protheus.doc} Destroy
M�todo para limpar da mem�ria os objetos utilizados pela classe
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@return Nil
/*/
METHOD Destroy() CLASS AtualizaDemandas

	FreeObj(Self:oParam)
	Self:oParam := Nil

Return

/*/{Protheus.doc} AbreTela
M�todo para abrir a tela
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@return Nil
/*/
METHOD AbreTela() CLASS AtualizaDemandas

	Local aButtons  := { {.F.,Nil},    {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
	                     {.T.,STR0123},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} } //"Atualizar"
	Local oViewExec := FWViewExec():New()	

	Self:oModel := ModelDef()
	Self:oView  := ViewDef(Self)

	oViewExec:setModel(Self:oModel)
	oViewExec:setView(Self:oView)
	oViewExec:setTitle(STR0122) //"Atualizar Demandas"
	oViewExec:setOperation(MODEL_OPERATION_UPDATE)
	oViewExec:setButtons(aButtons)
	oViewExec:setCancel({|| Self:AcaoBotao(1)})
	oViewExec:openView(.F.)

Return

/*/{Protheus.doc} ModelDef
Defini��o do Modelo
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@return oModel, objeto, modelo definido
/*/
Static Function ModelDef()

	Local oModel    := MPFormModel():New('PCPA136Atu')
	Local oStruCab  := FWFormModelStruct():New()
	Local oStruGrid := FWFormStruct(1,"SVB")

	Local cFiliais 	:= VldFiliais() 

	StrGridPrc(@oStruGrid, .T.)

	//Cria campo para o modelo invis�vel
	oStruCab:AddField(STR0123, STR0123, "ARQ", "C", 1, 0, , , {}, .T., , .F., .F., .F., , ) //"Atualizar"

	//FLD_INVISIVEL - Modelo "invis�vel"
	oModel:addFields('FLD_INVISIVEL', /*cOwner*/, oStruCab, , , {|| LoadMdlFld()})
	oModel:GetModel("FLD_INVISIVEL"):SetDescription(STR0122) //"Atualizar Demandas"
	oModel:GetModel("FLD_INVISIVEL"):SetOnlyQuery(.T.)

	//GRID - Grid das Demandas	
	oModel:AddGrid("GRID", "FLD_INVISIVEL", oStruGrid)
	oModel:GetModel("GRID"):SetDescription(STR0001) //"Demandas do MRP"
	oModel:GetModel("GRID"):SetOptional(.T.)
	oModel:GetModel("GRID"):SetOnlyQuery(.T.)
	oModel:GetModel("GRID"):SetNoInsertLine(.T.)
	oModel:GetModel("GRID"):SetNoDeleteLine(.T.)

	oModel:GetModel("GRID"):SetLoadFilter( NIL , "VB_FILIAL IN ("+cFiliais+")" , NIL )		

	oModel:SetRelation("GRID",{{'1','1'}}, SVB->(IndexKey(1)))

	oModel:SetDescription(STR0122) //"Atualizar Demandas"
	oModel:SetPrimaryKey({})

Return oModel


/*/{Protheus.doc} VldFiliais()
	Retorna as filiais permitidas no configurador para o usu�rio logado.
	@type  Static Function
	@author mauricio.joao	
	@since 20/09/2022
	@version 1.0
	@return cFiliais, Char, filiais permitidas.

	@see (links_or_references)
/*/
Static Function VldFiliais()
	Local cFiliais 	:= ""
	Local nFilial 	:= 0
	
	aFiliais := FWLoadSM0() //Carrega todas as filiais.	
	lInicio := .T.

	For nFilial := 1 to Len(aFiliais)		
		//Verifica se a filial est� permitida para o usu�rio.
		If aFiliais[nFilial,11] 
			If lInicio
				cFiliais += "'"+aFiliais[nFilial,2]+"'"
				lInicio := .F.
			Else
				cFiliais += ",'"+aFiliais[nFilial,2]+"'"
			EndIf
		EndIf
			
	Next nFilial

Return cFiliais


/*/{Protheus.doc} ViewDef
Defini��o da View
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@return oView, objeto, view definida
/*/
Static Function ViewDef(oSelf)

	Local oStruGrid := FWFormStruct(2,"SVB", , , , .T.)
	Local oView     := FWFormView():New()
	Local oModel    := FWLoadModel("PCPA136Atu")

	StrGridPrc(@oStruGrid, .F.)

	//Defini��es da View
	oView:SetModel(oModel)

	//Adiciona Other Object com os par�metros
	oView:AddOtherObject("V_PARAM", {|oPanel| MontaParam(oPanel, oSelf) })
	oView:EnableTitleView("V_PARAM", STR0124) //"Par�metros"

	//V_GRID - View da Grid das demandas
	oView:AddGrid("V_GRID", oStruGrid, "GRID")
	oView:EnableTitleView("V_GRID", STR0125) //"Sele��o de Demandas para Atualiza��o"

	//Relaciona a SubView com o Box
	oView:CreateHorizontalBox("BOX_PARAM", 180, , .T.)
	oView:CreateHorizontalBox("BOX_GRID" , 100)

	//Vincula View aos BOX
	oView:SetOwnerView("V_PARAM", 'BOX_PARAM')
	oView:SetOwnerView("V_GRID" , 'BOX_GRID' )

	//Habilita os bot�es padr�es de filtro e pesquisa
	oView:SetViewProperty("V_GRID", "GRIDFILTER", {.T.} )
	oView:SetViewProperty("V_GRID", "GRIDSEEK"  , {.T.} )

	//Fun��o chamada ap�s ativar a View
    oView:SetAfterViewActivate({|oView| AfterView(oView, oSelf)})

	//Adiciona um bot�o para fechar a tela
	oView:AddUserButton(STR0126, "", {|| oSelf:AcaoBotao(0)}, , , , .T.) //"Cancelar"

	//Seta a��o ap�s o checkbox
	oView:SetFieldAction("CHECK", {|| AfterCheck(oSelf) })

Return oView

/*/{Protheus.doc} StrGridPrc
Monta a estrutura do grid
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@param 01 oStruGrid, objeto, objeto da tela de consulta
@param 02 lModel   , l�gico, Indica se a chamada � para o model ou view.
@return oStruGrid  , objeto, defini��o dos campos do grid
/*/
Static Function StrGridPrc(oStruGrid, lModel)

	If lModel
		//Campos do ModelDef
		oStruGrid:AddField(""     ,; //[01]  C  Titulo do campo
						   ""     ,; //[02]  C  ToolTip do campo
						   "CHECK",; //[03]  C  Id do Field
						   "L"    ,; //[04]  C  Tipo do campo
						   6      ,; //[05]  N  Tamanho do campo
						   0      ,; //[06]  N  Decimal do campo
						   NIL    ,; //[07]  B  Code-block de valida��o do campo
						   NIL    ,; //[08]  B  Code-block de valida��o When do campo
						   {}     ,; //[09]  A  Lista de valores permitido do campo
						   .F.    ,; //[10]  L  Indica se o campo tem preenchimento obrigat�rio
						   Nil    ,; //[11]  B  Code-block de inicializacao do campo
						   NIL    ,; //[12]  L  Indica se trata-se de um campo chave
						   NIL    ,; //[13]  L  Indica se o campo pode receber valor em uma opera��o de update.
						   .T.)      //[14]  L  Indica se o campo � virtual

		oStruGrid:SetProperty("VB_FILIAL", MODEL_FIELD_NOUPD, .T.)
		oStruGrid:SetProperty("VB_DTINI" , MODEL_FIELD_NOUPD, .T.)
		oStruGrid:SetProperty("VB_DTFIM" , MODEL_FIELD_NOUPD, .T.)
	Else
		oStruGrid:AddField("CHECK",; //[01]  C  Nome do Campo
						   "00"   ,; //[02]  C  Ordem
                           ""     ,; //[03]  C  Titulo do campo
                           ""     ,; //[04]  C  Descricao do campo
                           NIL    ,; //[05]  A  Array com Help
                           "L"    ,; //[06]  C  Tipo do campo
                           Nil    ,; //[07]  C  Picture
                           NIL    ,; //[08]  B  Bloco de PictTre Var
                           NIL    ,; //[09]  C  Consulta F3
                           .T.    ,; //[10]  L  Indica se o campo � alteravel
                           NIL    ,; //[11]  C  Pasta do campo
                           NIL    ,; //[12]  C  Agrupamento do campo
                           NIL    ,; //[13]  A  Lista de valores permitido do campo (Combo)
                           NIL    ,; //[14]  N  Tamanho maximo da maior op��o do combo
                           NIL    ,; //[15]  C  Inicializador de Browse
                           .T.    ,; //[16]  L  Indica se o campo � virtual
                           NIL    ,; //[17]  C  Picture Variavel
                           NIL)      //[18]  L  Indica pulo de linha ap�s o campo
	EndIf

Return oStruGrid

/*/{Protheus.doc} AfterView
Fun��o executada ap�s ativar a view
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@param 01 oView, objeto, objeto da View
@param 02 oSelf, objeto, inst�ncia da classe atual (AtualizaDemandas)
@return Nil
/*/
Static Function AfterView(oView, oSelf)

	//Seta funcionalidade de marcar/desmarcar todos clicando no cabe�alho
	oView:GetSubView("V_GRID"):oBrowse:aColumns[1]:bHeaderClick := {|| oSelf:MarcaTodos()}

Return

/*/{Protheus.doc} MarcaTodos
Marca todas as demandas
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@return Nil
/*/
METHOD MarcaTodos() CLASS AtualizaDemandas

	Local oGrid    := Self:oModel:GetModel("GRID")
	Local lChecked := oGrid:GetValue("CHECK", 1)
	Local nIndex   := 0
	Local nTotal   := oGrid:Length(.F.)

	For nIndex := 1 To nTotal
		oGrid:GoLine(nIndex)
		oGrid:LoadValue("CHECK", !lChecked)
	Next nIndex

	AfterCheck(Self)
	oGrid:GoLine(1)
	Self:oView:Refresh()

Return

/*/{Protheus.doc} MontaParam
Monta os par�metros na tela
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@param 01 oPanel, objeto, painel onde ser�o montados os parametros
@param 02 oSelf , objeto, inst�ncia da classe atual (AtualizaDemandas)
@return Nil
/*/
Static Function MontaParam(oPanel, oSelf)

	Local aDesc      := {}
	Local aPeriod    := {}
	Local aDirecao   := {}
	Local aDataPed   := {}
	Local oCheckPDV  := Nil
	Local oCheckPRV  := Nil
	Local oCheckPMP  := Nil
	Local oCheckEMP  := Nil
	Local oCheckPVB1 := Nil
	Local oComboDes1 := Nil
	Local oComboPer1 := Nil
	Local oGroup1    := Nil
	Local oGroup2    := Nil
	Local oGroup3    := Nil
	Local oRadioDir1 := Nil
	Local oRadioDat1 := Nil
	Local oSayProd1  := Nil
	Local oSayProd2  := Nil
	Local oSayTipo1  := Nil
	Local oSayTipo2  := Nil
	Local oSayGrp1   := Nil
	Local oSayGrp2   := Nil
	Local oSayDoc1   := Nil
	Local oSayDoc2   := Nil
	Local oSayDes1   := Nil
	Local oSayPer1   := Nil
	Local oSayDir1   := Nil
	Local oSayDat1   := Nil
	Local oTGetProd1 := Nil
	Local oTGetProd2 := Nil
	Local oTGetTipo1 := Nil
	Local oTGetTipo2 := Nil
	Local oTGetGrp1  := Nil
	Local oTGetGrp2  := Nil
	Local oTGetDoc1  := Nil
	Local oTGetDoc2  := Nil
	Local oCheckAmz := Nil

	aDesc    := {"1=" + STR0127, ; //"Colocados"
                 "2=" + STR0128, ; //"Faturados"
                 "3=" + STR0129, ; //"Ambos"
                 "4=" + STR0130}   //"N�o"

	aPeriod  := {"1=" + STR0131, ; //"Di�rio"
	             "2=" + STR0132, ; //"Semanal"
			     "3=" + STR0133, ; //"Quinzenal"
			     "4=" + STR0134}   //"Mensal"

	aDirecao := {STR0135, ; //"Para frente"
	             STR0136}   //"Ambas"

	aDataPed := {STR0137, ; //"Entrega"
	             STR0138}   //"Faturamento"
	

	oGroup1     := TGroup():New(16,   2,  84,  85, STR0139, oPanel, , , .T.) //"Tipo Demanda"
	oGroup2     := TGroup():New(16,  90,  84, 297, STR0140, oPanel, , , .T.) //"Filtros"
	oGroup3     := TGroup():New(16, 302,  84, 575, STR0141, oPanel, , , .T.) //"Outros"

	oCheckPDV   := TCheckBox():New(25, 8, STR0142, {|u| If(PCount() == 0, oSelf:oParam["checkPDV"], oSelf:oParam["checkPDV"] := u)}, oGroup1, 80, 40, , , , , , , , .T., , , ) //"Pedido de venda"
	oCheckPRV   := TCheckBox():New(40, 8, STR0143, {|u| If(PCount() == 0, oSelf:oParam["checkPRV"], oSelf:oParam["checkPRV"] := u)}, oGroup1, 80, 40, , , , , , , , .T., , , ) //"Previs�o de Venda"
	oCheckPMP   := TCheckBox():New(55, 8, STR0144, {|u| If(PCount() == 0, oSelf:oParam["checkPMP"], oSelf:oParam["checkPMP"] := u)}, oGroup1, 80, 40, , , , , , , , .T., , , ) //"Plano mestre"
	oCheckEMP   := TCheckBox():New(70, 8, STR0145, {|u| If(PCount() == 0, oSelf:oParam["checkEMP"], oSelf:oParam["checkEMP"] := u)}, oGroup1, 80, 40, , , , , , , , .T., , , ) //"Empenhos de Projeto"

	oSayProd1   := TSay():New(25,  85, {|| STR0146}, oGroup2, , , , , , .T., , , 70, 20) //"Produto de:"
	oTGetProd1  := TGet():New(23, 156, {|u| If(PCount() == 0, oSelf:oParam["produtoDe" ], oSelf:oParam["produtoDe" ] := u)}, oGroup2, 59, 10, PesqPict("SB1","B1_COD"),,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SB1",oSelf:oParam["produtoDe" ],,,,.T.)
	oSayProd2   := TSay():New(25, 205, {|| STR0147}, oGroup2, , , , , , .T., , , 20, 20) //"at�:"
	oTGetProd2  := TGet():New(23, 226, {|u| If(PCount() == 0, oSelf:oParam["produtoAte"], oSelf:oParam["produtoAte"] := u)}, oGroup2, 59, 10, PesqPict("SB1","B1_COD"),,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SB1",oSelf:oParam["produtoAte"],,,,.T.)
	oSayProd1:SetTextAlign(1, 0)
	oSayProd2:SetTextAlign(1, 0)

	oSayTipo1   := TSay():New(40,  85, {|| STR0148}, oGroup2, , , , , , .T., , , 70, 20) //"Tipo de Material de:"
	oTGetTipo1  := TGet():New(38, 156, {|u| If(PCount() == 0, oSelf:oParam["tipoMaterialDe" ], oSelf:oParam["tipoMaterialDe" ] := u)}, oGroup2, 59, 10, PesqPict("SB1","B1_TIPO"),,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"02",oSelf:oParam["tipoMaterialDe" ],,,,.T.)
	oSayTipo2   := TSay():New(40, 205, {|| STR0147}, oGroup2, , , , , , .T., , , 20, 20) //"at�:"
	oTGetTipo2  := TGet():New(38, 226, {|u| If(PCount() == 0, oSelf:oParam["tipoMaterialAte"], oSelf:oParam["tipoMaterialAte"] := u)}, oGroup2, 59, 10, PesqPict("SB1","B1_TIPO"),,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"02",oSelf:oParam["tipoMaterialAte"],,,,.T.)
	oSayTipo1:SetTextAlign(1, 0)
	oSayTipo2:SetTextAlign(1, 0)

	oSayGrp1    := TSay():New(55,  85, {|| STR0149}, oGroup2, , , , , , .T., , , 70, 20) //"Grupo de Material de:"
	oTGetGrp1   := TGet():New(53, 156, {|u| If(PCount() == 0, oSelf:oParam["grupoMaterialDe" ], oSelf:oParam["grupoMaterialDe" ] := u)}, oGroup2, 59, 10, PesqPict("SB1","B1_GRUPO"),,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SBM",oSelf:oParam["grupoMaterialDe" ],,,,.T.)
	oSayGrp2    := TSay():New(55, 205, {|| STR0147}, oGroup2, , , , , , .T., , , 20, 20) //"at�:"
	oTGetGrp2   := TGet():New(53, 226, {|u| If(PCount() == 0, oSelf:oParam["grupoMaterialAte"], oSelf:oParam["grupoMaterialAte"] := u)}, oGroup2, 59, 10, PesqPict("SB1","B1_GRUPO"),,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SBM",oSelf:oParam["grupoMaterialAte"],,,,.T.)
	oSayGrp1:SetTextAlign(1, 0)
	oSayGrp2:SetTextAlign(1, 0)

	oSayDoc1    := TSay():New(70,  85, {|| STR0150}, oGroup2, , , , , , .T., , , 70, 20) //"Documento de:"
	oTGetDoc1   := TGet():New(68, 156, {|u| If(PCount() == 0, oSelf:oParam["documnentoDe" ], oSelf:oParam["documnentoDe" ] := u)}, oGroup2, 47, 10, PesqPict("SVR","VR_DOC"),,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,oSelf:oParam["documnentoDe" ],,,,.T.)
	oSayDoc2    := TSay():New(70, 205, {|| STR0147}, oGroup2, , , , , , .T., , , 20, 20) //"at�:"
	oTGetDoc2   := TGet():New(68, 226, {|u| If(PCount() == 0, oSelf:oParam["documnentoAte"], oSelf:oParam["documnentoAte"] := u)}, oGroup2, 47, 10, PesqPict("SVR","VR_DOC"),,,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,oSelf:oParam["documnentoAte"],,,,.T.)
	oSayDoc1:SetTextAlign(1, 0)
	oSayDoc2:SetTextAlign(1, 0)

	oSayDes1    := TSay():New(25, 308, {|| STR0151}, oGroup3, , , , , , .T., , , 70, 20) //"Desconta PV da Previs�o:"
	oComboDes1  := TComboBox():New(23, 380, {|u| If(PCount() > 0, oSelf:oParam["descontaPV"] := u, oSelf:oParam["descontaPV"])}, aDesc, 59, 13, oGroup3,,{||.T.},,,,.T.,,,,,,,,,'oSelf:oParam["descontaPV"]')
	oSayDes1:SetTextAlign(1, 0)

	oSayPer1    := TSay():New(25, 433, {|| STR0152}, oGroup3, , , , , , .T., , , 70, 20) //"Periodicidade:"
	oComboPer1  := TComboBox():New(23, 505, {|u| If(PCount() > 0, oSelf:oParam["periodicidade"] := u, oSelf:oParam["periodicidade"])}, aPeriod, 59, 13, oGroup3,,{||.T.},,,,.T.,,,,,,,,,'oSelf:oParam["periodicidade"]')
	oSayPer1:SetTextAlign(1, 0)

	oSayDir1    := TSay():New(41, 308, {|| STR0153}, oGroup3, , , , , , .T., , , 70, 20) //"Dire��o:"
	oRadioDir1  := TRadMenu():New(40, 380, aDirecao, {|u| If(PCount() == 0, oSelf:oParam["direcao"], oSelf:oParam["direcao"] := u)}, oGroup3, , , , , , , , 60, 40, , , , .T.)
	oSayDir1:SetTextAlign(1, 0)

	oSayDat1    := TSay():New(41, 433, {|| STR0154}, oGroup3, , , , , , .T., , , 70, 20) //"Data Pedidos Faturados:"
	oRadioDat1  := TRadMenu():New(40, 505, aDataPed, {|u| If(PCount() == 0, oSelf:oParam["dataPedidosFaturados"], oSelf:oParam["dataPedidosFaturados"] := u)}, oGroup3, , , , , , , , 60, 40, , , , .T.)
	oSayDat1:SetTextAlign(1, 0)

	oCheckPVB1  := TCheckBox():New(70, 315, STR0155, {|u| If(PCount() == 0, oSelf:oParam["consideraPVBloqueio"], oSelf:oParam["consideraPVBloqueio"] := u)}, oGroup3, 150, 40, , , , , , , , .T., , , ) //"Considera PV com bloqueio de cr�dito?"
	
	oCheckAmz   := TCheckBox():New(70, 450, STR0168, {|u| If(PCount() == 0, oSelf:oParam["consideraArmazem"], oSelf:oParam["consideraArmazem"] := u)}, oGroup3, 150, 40, , , , , , , , .T., , , ) // "Considera armaz�m origem?"

Return

/*/{Protheus.doc} LoadMdlFld
Carga do modelo mestre (invis�vel)
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@return aLoad, array, array de load do modelo preenchido
/*/
Static Function LoadMdlFld()

	Local aLoad := {}

	aAdd(aLoad, {"A"}) //Dados
	aAdd(aLoad, 1    ) //Recno

Return aLoad

/*/{Protheus.doc} AcaoBotao
M�todo chamado ao pressionar algum bot�o da tela
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@param 01 nOpcao  , num�rico, indicador do bot�o clicado (0-Cancelar; 1-Atualizar)
@return lFechaTela, l�gico  , indicador para fechar a tela
/*/
METHOD AcaoBotao(nOpcao) CLASS AtualizaDemandas

	Local lFechaTela := .F.

	Self:oModel:lModify := .F.
	If nOpcao == 1
		lFechaTela := Self:ProcessaAtualizacao()
	Else
		Self:oView:CloseOwner()
	EndIf

	Self:oModel:lModify := .F.

Return lFechaTela

/*/{Protheus.doc} AfterCheck
M�todo chamado ao pressionar algum bot�o da tela
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@param 01 oSelf   , objeto  , inst�ncia da classe atual (AtualizaDemandas)
@param 02 nOpcao  , num�rico, indicador do bot�o clicado
@return lFechaTela, l�gico  , indicador para fechar a tela
/*/
Static Function AfterCheck(oSelf)

	oSelf:oModel:lModify := .F.
	oSelf:oView:lModify  := .F.

Return .T.

/*/{Protheus.doc} ProcessaAtualizacao
Prepara e processa a atualiza��o
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@return lFechaTela, l�gico, indica se a tela deve ser fechada
/*/
METHOD ProcessaAtualizacao() CLASS AtualizaDemandas

	Local oGrid      := Self:oModel:GetModel("GRID")
	Local lFechaTela := .T.

	Pergunte("PCP136IMP", .F.)

	MV_PAR01 := IIf(Self:oParam["checkPDV"            ], 1, 2) //Importa pedidos de venda?    - 1-Sim; 2-N�o.
	MV_PAR02 := IIf(Self:oParam["checkPRV"            ], 1, 2) //Importa previs�o de vendas?  - 1-Sim; 2-N�o.
	MV_PAR03 := IIf(Self:oParam["checkPMP"            ], 1, 2) //Importa plano mestre?        - 1-Sim; 2-N�o.
	MV_PAR04 := IIf(Self:oParam["checkEMP"            ], 1, 2) //Importa empenhos de projeto? - 1-Sim; 2-N�o.
	MV_PAR07 :=     Self:oParam["produtoDe"           ]        //De produto?                  - Range inicial de produto.
	MV_PAR08 :=     Self:oParam["produtoAte"          ]        //At� produto?                 - Range final de produto.
	MV_PAR09 :=     Self:oParam["tipoMaterialDe"      ]        //De tipo de material?         - Range inicial de tipo de produto. (B1_TIPO)
	MV_PAR10 :=     Self:oParam["tipoMaterialAte"     ]        //At� tipo de material?        - Range final de tipo de produto.   (B1_TIPO)
	MV_PAR11 :=     Self:oParam["grupoMaterialDe"     ]        //De grupo de material?        - Range inicial de grupo de produto.(B1_GRUPO)
	MV_PAR12 :=     Self:oParam["grupoMaterialAte"    ]        //At� grupo de material?       - Range final de grupo de produto.  (B1_GRUPO)
	MV_PAR13 :=     Self:oParam["documnentoDe"        ]        //De documento PV/PMP?         - Range inicial de documentos.
	MV_PAR14 :=     Self:oParam["documnentoAte"       ]        //At� documento PV/PMP?        - Range final de documentos.
	MV_PAR15 := IIf(Self:oParam["consideraPVBloqueio" ], 1, 2) //Considera PV Bloq. Cr�dito?  - Considera pedidos com bloqueio de cr�dito? 1-Sim; 2-N�o.
	MV_PAR16 := Val(Self:oParam["descontaPV"          ])       //Desconta PV da Previs�o?     - Se desconta Pedido de venda da previs�o. 1-Colocados;2-Faturados;3-Ambos;4-N�o.
	MV_PAR17 := Val(Self:oParam["periodicidade"       ])       //Periodicidade                - 1-Di�rio; 2-Semanal; 3-Quinzenal; 4-Mensal; 5-Trimestral; 6-Semestral.
	MV_PAR18 :=     Self:oParam["direcao"             ]        //Dire��o                      - 1-Para frente; 2-Ambas.
	MV_PAR19 := 2                                              //Exibe inconsist�ncias?       - Abre a tela com os registros que n�o ser�o importados? 1-Sim; 2-N�o.
	MV_PAR20 :=     Self:oParam["dataPedidosFaturados"]        //Considera Data?              - 1-Entrega; 2-Faturamento
	MV_PAR21 := Iif(Self:oParam["consideraArmazem"], 1, 2)     //Utiliza armaz�m origem?      - 1-Sim;2-N�o

	P136SetOri(3)
	Processa({|| lFechaTela := ProcessAtu(oGrid)}, STR0156, STR0050, .F.) //"Atualizando as demandas", "Aguarde..."

Return lFechaTela

/*/{Protheus.doc} ProcessAtu
Processa a atualiza��o das demandas selecionadas
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@param oGrid, objeto, modelo de dados da grid de demandas
@return lFechaTela, l�gico, indica se a tela deve ser fechada
/*/
Static Function ProcessAtu(oGrid)
	Local aMensagens := {}
	Local aProcessa  := {}
	Local cCodDeman  := ""
	Local cFilBkp    := cFilAnt
	Local cMensagem  := ""
	Local lStatus    := .T.
	Local lFechaTela := .T.
	Local nIndex     := 1
	Local nTotal     := oGrid:Length(.F.)

	//Verifica quais linhas foram marcadas para processar
	For nIndex := 1 To nTotal
		If oGrid:GetValue("CHECK", nIndex)
			aAdd(aProcessa, nIndex)
		EndIf
	Next nIndex

	nTotal := Len(aProcessa)
	If nTotal > 0
		ProcRegua(nTotal + 1)
		//Percorre as demandas chamando a importa��o do PCPA136 (PCPA136Imp)
		For nIndex := 1 To nTotal
			cFilAnt   := oGrid:GetValue("VB_FILIAL", aProcessa[nIndex])
			cCodDeman := oGrid:GetValue("VB_CODIGO", aProcessa[nIndex])

			IncProc(STR0158 + AllTrim(cCodDeman)) //"Atualizando a demanda "

			MV_PAR05 := oGrid:GetValue("VB_DTINI", aProcessa[nIndex]) //Data inicial? - Range inicial de data.
			MV_PAR06 := oGrid:GetValue("VB_DTFIM", aProcessa[nIndex]) //Data final?   - Range final de data.

			//Executa a importa��o
			P136Import(cCodDeman, @lStatus, 1, @cMensagem)

			If Empty(cMensagem)
				cMensagem := STR0159 //"Atualizada com sucesso."
			EndIf

			//Carrega o array com as demandas processadas e a mensagem do processamento
			aAdd(aMensagens, {cFilAnt, cCodDeman, cMensagem})

			cMensagem := ""
		Next nIndex

		cFilAnt := cFilBkp

		IncProc(STR0160) //"Exibindo o resultado..."
		ResultProc(aMensagens)
	Else
		lFechaTela := .F.
		Help(' ', 1, "Help", , STR0161,; //"Nenhuma demanda foi selecionada."
			 2, 0 , , , , , , {STR0162}) //"Selecione ao menos uma demanda para atualizar."
	EndIf

Return lFechaTela

/*/{Protheus.doc} ResultProc
Abre tela com o resumo do processamento
@author marcelo.neumann
@since 04/02/2021
@version P12.1.33
@param aMensagens, array, array com as demandas processadas e a mensagem do processamento
@return Nil
/*/
Static Function ResultProc(aMensagens)
	Local oDlgResult := Nil
	Local oBrowse    := Nil

	DEFINE DIALOG oDlgResult TITLE STR0163 FROM 0,0 TO 300,500 PIXEL //"Resultado"

	oBrowse := TWBrowse():New(01,01,250,135, ,{STR0165, STR0157, STR0164},{20, 30, 140},oDlgResult,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,) //"Filial", "Demanda","Mensagem"
	oBrowse:SetArray(aMensagens)

	oBrowse:bLine := {|| { aMensagens[oBrowse:nAt,1], aMensagens[oBrowse:nAt,2], aMensagens[oBrowse:nAt,3]}}

	DEFINE SBUTTON FROM 138, 225 TYPE 1 ACTION (oDlgResult:End()) ENABLE OF oDlgResult

	ACTIVATE MSDIALOG oDlgResult CENTERED

Return
